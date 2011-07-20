require_relative '../objects/player'
require_relative '../map'
require_relative '../skewed_map'


class Level < Scene 
  attr_reader :frame_time, :floor_map, :player
  
  ZOOM = 8
  WALL_MAP_ROWS = 3
  FLOOR_MAP_ROWS = 6

  FONT_SIZE = 32
  
  def setup
    @dynamic_objects = [] # Objects that need #update

    level_data = YAML::load_file(File.expand_path(File.join(__FILE__, "../../../config/levels/1.yml")))
    @wall_map = Map.new level_data['wall'].split("\n")
    @floor_map = SkewedMap.new self, level_data['floor'].split("\n"), [0, @wall_map.to_rect.height]
    
    @camera = window.default_view
    @camera.zoom_by ZOOM
    @camera.center = @camera.size / 2
    
    @player = Player.new(self, Vector2[64, 40])
      
    @half_size = @camera.rect.size / 2
    
    create_background 

    # Player's score, time remaining and progress through the level.
    text_color = Color.new(190, 190, 255)
    score_height = window.size.height - 60
    @score_background = Polygon.rectangle([0, window.size.height - 48, window.size.width, 48], Color.new(80, 80, 80))
    @score = ShadowText.new "0000000", at: [100, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @timer = Timer.new level_data['time_limit'], at: [490, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @progress = ProgressBar.new(Rect.new(0, window.size.height - 16, window.size.width, 16))

    @last_frame_started_at = Time.now.to_f
      
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
         
      # Move the camera to the player position (left side, plus an amount asked for from the player).
      @camera.x = @player.x + (@camera.rect.width / 2) - (@camera.rect.width * @player.screen_offset_x)
      
      # Checking for collision on the screen is significantly slower than just rendering everything.
      clip_rect = @camera.rect
      @visible_dynamic_objects = @dynamic_objects
      
      # Update visible dynamic objects and stop them moving off the map. Others will just sleep off the side of the map.
      @dynamic_objects.each(&:update)
      
      @visible_objects = @dynamic_objects.sort_by(&:z_order)

      @timer.reduce frame_time
          
      @used_time += (Time.now - start_at).to_f
      recalculate_fps
      
      @progress.progress = (@player.position.x.to_f / @wall_map.to_rect.width)

      if DEVELOPMENT_MODE
        window.title = "Pos: (#{@player.x.round}, #{@player.y.round}), FPS: #{@fps.round} [#{@potential_fps.round}]"
      end
    end
    
    render do |win| 
      start_at = Time.now 
      
      win.with_view @background_camera do
        win.draw @background
      end
      
      win.with_view @camera do
        @wall_map.draw_on(win)
        @floor_map.draw_on(win)
        
        clip_rect = @camera.rect
        
        @visible_objects.each {|obj| obj.draw_shadow_on win }      
        @visible_objects.each {|obj| obj.draw_on win }  
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