require_relative '../objects/player'
require_relative '../wall_map'
require_relative '../floor_map'


class Level < Scene 
  attr_reader :frame_time, :floor_map, :player, :timer
  
  ZOOM = 8
  WALL_MAP_ROWS = 3
  FLOOR_MAP_ROWS = 6

  FONT_SIZE = 32
  
  def setup
    @dynamic_objects = [] # Objects that need #update

    level_data = YAML::load_file(File.expand_path(File.join(__FILE__, "../../../config/levels/1.yml")))
    @wall_map = WallMap.new self, level_data['wall'].split("\n")
    @floor_map = FloorMap.new self, level_data['floor'].split("\n")

    # Create a camera for displaying the wall map
    @wall_camera = window.default_view
    @wall_camera.zoom_by ZOOM
    @wall_camera.center = @wall_camera.size / 2

    # Create a camera for displaying the floor map (which has origin set in the view)
    @floor_camera = @wall_camera.dup
    @floor_camera.y -= @wall_map.to_rect.height
    
    @player = Player.new(self, Vector2[FloorTile.width * 5.5, FloorTile.height * 2.5])
      
    @half_size = @wall_camera.rect.size / 2
    
    create_background 

    # Player's score, time remaining and progress through the level.
    text_color = Color.new(190, 190, 255)
    score_height = window.size.height - 60
    @score_background = Polygon.rectangle([0, window.size.height - 48, window.size.width, 48], Color.new(80, 80, 80))
    @score = ShadowText.new "0000000", at: [100, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @timer = Timer.new level_data['time_limit'], at: [490, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @progress = ProgressBar.new(Rect.new(0, window.size.height - 16, window.size.width, 16))

    @last_frame_started_at = Time.now.to_f

    window.hide_cursor

    init_fps
  end
  
  def create_background
    img = Image.new window.size / 2
    400.times { img[rand(img.size.width), rand(img.size.height)] = Color.new(*([55 + rand(200)] * 3)) }

    @background = sprite img
    
    @background_camera = window.default_view
    @background_camera.zoom_by 2
    @background_camera.center = @background_camera.size / 2
  end
  
  def add_object(object)
    @dynamic_objects << object
  end
  
  def register   
    always do
      now = Time.now.to_f
      @frame_time = [now - @last_frame_started_at, 0.1].min
      @last_frame_started_at = now
      
      start_at = now
         
      # Move the cameras to the player position (left side, plus an amount asked for from the player).
      @wall_camera.x = @floor_camera.x =
          @player.x + (@wall_camera.rect.width / 2) - (@wall_camera.rect.width * @player.screen_offset_x)
      
      # Checking for collision on the screen is significantly slower than just rendering everything.
      @visible_dynamic_objects = @dynamic_objects
      
      # Update visible dynamic objects and stop them moving off the map. Others will just sleep off the side of the map.
      min_x = @player.x - @floor_camera.rect.width * 0.75
      max_x = @player.x + @floor_camera.rect.width
      @visible_objects = @dynamic_objects.select {|o| o.x >= min_x and o.x <= max_x }
      @visible_objects.sort_by!(&:z_order)
      @visible_objects.each(&:update)
          
      @used_time += (Time.now - start_at).to_f
      recalculate_fps
      
      @progress.progress = (@player.position.x.to_f / @wall_map.to_rect.width)

      @score.string = "%07d" % player.score

      if DEVELOPMENT_MODE
        window.title = "Pos: (#{@player.x.round}, #{@player.y.round}), FPS: #{@fps.round} [#{@potential_fps.round}]"
      end
    end
    
    render do |win| 
      start_at = Time.now 
      
      win.with_view @background_camera do
        win.draw @background
      end
      
      win.with_view @wall_camera do
        @wall_map.draw_on(win)
      end

      win.with_view @floor_camera do
        @floor_map.draw_on(win)
        
        @visible_objects.each {|obj| obj.draw_shadow_on win }      
        @visible_objects.each {|obj| obj.draw_on win }
        if DEVELOPMENT_MODE
          @visible_objects.each {|obj| obj.draw_debug_on win }
        end
      end

      win.draw @score_background
      @timer.draw_on win
      @score.draw_on win
      @progress.draw_on win
      
      @used_time += (Time.now - start_at).to_f
    end
  end
  
  def init_fps
    @fps_next_calculated_at = Time.now.to_f + 1
    @fps = @potential_fps = 0
    @num_frames = 0
    @used_time = 0
  end
  
  def recalculate_fps
    @num_frames += 1
    
    if Time.now.to_f >= @fps_next_calculated_at     
      elapsed_time = @fps_next_calculated_at - Time.now.to_f + 1
      @fps = @num_frames / elapsed_time
      @potential_fps = @num_frames / [@used_time, 0.0001].max
       
      @num_frames = 0
      @fps_next_calculated_at = Time.now.to_f + 1
      @used_time = 0
    end
  end
end