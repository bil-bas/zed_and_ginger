require_relative '../objects/player'
require_relative '../map'
require_relative '../skewed_map'

class Level < Scene 
  attr_reader :frame_time
  
  ZOOM = 8
  
  def setup
    @dynamic_objects = [] # Objects that need #update
    
    @wall_map = Map.new [100, 3]
    @floor_map = SkewedMap.new [100, 6], [0, @wall_map.to_rect.height]
    
    @camera = window.default_view
    @camera.zoom_by ZOOM
    @camera.center = @camera.size / 2
    
    @player = Player.new(self, Vector2[24, 40])    
      
    @half_size = @camera.rect.size / 2
    
    create_background 
    
    @score = text "0000000", at: [64, 0], font: font_path("pixelated.ttf"), size: 48 # Player's score.
    @timer = text "0'00\"00", at: [400, 0], font: font_path("pixelated.ttf"), size: 48 # Time remaining for the level.
    
    @progress_back = Polygon.rectangle([0, window.size.height - 16, window.size.width, 16])
    @progress_back.outline = Color.black
    @progress_back.outlined = true
    @progress = Polygon.rectangle([0, window.size.height - 16, window.size.width, 16])
    @progress.color = Color.new(50, 50, 200)
    
    @last_frame_started_at = Time.now.to_f
      
    init_fps
  end
  
  def create_background
    img = Image.new Vector2[window.size.width, @wall_map.to_rect.height * ZOOM] / 2
    250.times { img[rand(img.size.width), rand(img.size.height)] = Color.new(*([55 + rand(200)] * 3)) }
    
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
         
      # Move the camera to the player position, but don't let the user see over the edge of the map. 
      @camera.x = [[@player.x, @half_size.w].max, @floor_map.to_rect.width - @half_size.w].min
      
      # Checking for collision on the screen is significantly slower than just rendering everything.
      clip_rect = @camera.rect
      @visible_dynamic_objects = @dynamic_objects
      
      # Update visible dynamic objects and stop them moving off the map. Others will just sleep off the side of the map.
      @dynamic_objects.each(&:update)
      
      @visible_objects = @dynamic_objects.sort_by(&:z_order)
          
      @used_time += (Time.now - start_at).to_f
      recalculate_fps
      
      @progress.scale_x = (@player.position.x.to_f / @wall_map.to_rect.width) 

      window.title = "Pos: (#{@player.x.round}, #{@player.y.round}), FPS: #{@fps.round} [#{@potential_fps.round}]"
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
      
      win.draw @timer
      win.draw @score
      win.draw @progress_back
      win.draw @progress
      
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