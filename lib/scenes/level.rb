require_relative '../objects/player'
require_relative '../map'

class Level < Scene 
  def setup
    @dynamic_objects = [] # Objects that need #update
    
    @map = Map.new 100, 15
    
    @camera = window.default_view
    @camera.zoom_by 4
    @camera.center = @camera.size / 2
    
    @player = Player.new(self, Vector2[24, 80])    
      
    @half_size = @camera.rect.size / 2
      
    init_fps
  end
  
  def add_object(object)
    case object
      when DynamicObject
        @dynamic_objects << object
      when StaticObject
        @map.add_object(object)
    end
  end
  
  def register   
    always do
      start_at = Time.now
         
      # Move the camera to the player position, but don't let the user see over the edge of the map. 
      @camera.x = [[@player.x, @half_size.w].max, @map.to_rect.width - @half_size.w].min
      
      # Checking for collision on the screen is significantly slower than just rendering everything.
      clip_rect = @camera.rect
      @visible_dynamic_objects = @dynamic_objects.select {|o| o.to_rect.collide? clip_rect }
      
      # Update visible dynamic objects and stop them moving off the map. Others will just sleep off the side of the map.
      @visible_dynamic_objects.each(&:update)
      rect = @map.to_rect
      max_x, max_y = rect.width, rect.height
      @visible_dynamic_objects.each do |obj|
        half_w = obj.width / 2
        obj.x = [[obj.x, half_w].max, max_x - half_w].min
        obj.y = [[obj.y, half_w].max, max_y - half_w].min
      end
      
      @visible_objects = @visible_dynamic_objects + @map.visible_objects(@camera)
      @visible_objects.sort_by!(&:z_order)
          
      @used_time += (Time.now - start_at).to_f
      recalculate_fps

      window.title = "Pos: (#{@player.x.round}, #{@player.y.round}), FPS: #{@fps.round} [#{@potential_fps.round}]"
    end
    
    render do |win| 
      start_at = Time.now 
      
      win.with_view @camera do
        @map.draw_on(win)
        
        clip_rect = @camera.rect
        
        @visible_objects.each {|obj| obj.draw_shadow_on win }      
        @visible_objects.each {|obj| obj.draw_on win }
      end
      
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