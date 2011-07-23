require_relative '../objects/player'
require_relative '../wall_map'
require_relative '../floor_map'


class Level < Scene 
  attr_reader :frame_time, :floor_map, :player, :timer
  
  ZOOM = 8
  WALL_MAP_ROWS = 3
  FLOOR_MAP_ROWS = 6

  FONT_SIZE = 45

  HIGH_SCORE_FILE = File.join(ROOT_PATH, 'zed_and_ginger.dat')

  FIELD_LEVELS = 'levels'
  FIELD_HIGH_SCORER = 'high-scorer'
  FIELD_HIGH_SCORE = 'high-score'
  DEFAULT_HIGH_SCORER = '???' # When noone has made a high score, it still needs a name.

  attr_reader :level_number

  def setup(level_number)
    @level_number = level_number

    @dynamic_objects = [] # Objects that need #update

    level_data = YAML::load_file(File.expand_path(File.join(__FILE__, "../../../config/levels/#{level_number}.yml")))
    @wall_map = WallMap.new self, level_data['wall'].split("\n")
    @floor_map = FloorMap.new self, level_data['floor'].split("\n"), level_data['messages']

    # Create a camera for displaying the wall map
    @wall_camera = window.default_view
    @wall_camera.zoom_by ZOOM
    @wall_camera.center = @wall_camera.size / 2

    # Create a camera for displaying the floor map (which has origin set in the view)
    @floor_camera = @wall_camera.dup
    @floor_camera.y -= @wall_map.to_rect.height

    start_tile = @floor_map.tile_at_grid([5, 2])
    @player = Player.new(self, start_tile, start_tile.position + @floor_map.tile_size / 2)
    @initial_player_x = player.x
    @distance_to_run = @floor_map.finish_line_x - @initial_player_x

    @half_size = @wall_camera.rect.size / 2
    
    create_background 

    # Player's score, time remaining and progress through the level.
    text_color = Color.new(190, 190, 255)
    score_height = window.size.height - 53
    @score_background = Polygon.rectangle([0, window.size.height - 48, window.size.width, 48], Color.new(80, 80, 80))
    @level_text = ShadowText.new "L%02d" % level_number, at: [25, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @high_score = ShadowText.new "XXXXXXX", at: [125, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @score = ShadowText.new "XXX: XXXXXXX", at: [425, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @timer = Timer.new level_data['time_limit'], at: [610, score_height], font: FONT_NAME, size: FONT_SIZE, color: text_color
    @progress = ProgressBar.new(Rect.new(0, window.size.height - 16, window.size.width, 16))

    @last_frame_started_at = Time.now.to_f

    window.hide_cursor

    init_fps

    load_high_scores

    # Setup a few things, so we can show a countdown before playing.
    @progress.progress = 0
    @visible_objects = [@player]
    move_camera

    @@level_music ||= music music_path "Space_Cat_Habitat.ogg"
    @@level_music.volume = 20
    @@level_music.play

    # TODO: Disabled this, because it was working erratically.
    #run_scene :ready_set_go, self
  end

  def clean_up
    @@level_music.stop
  end

  def load_high_scores
    @high_score_data = if File.exists? HIGH_SCORE_FILE
      YAML::load_file(HIGH_SCORE_FILE)
    else
      {
          FIELD_LEVELS => {}
      }
    end

    @high_score_data[FIELD_LEVELS][level_number] ||= {
        FIELD_HIGH_SCORE => 0,
        FIELD_HIGH_SCORER => DEFAULT_HIGH_SCORER,
    }

    update_high_score
  end

  def update_high_score
    @high_score.string = "%s: %07d" % [high_scorer, high_score]
  end

  def game_over(score)
    if score > high_score
      name = nil
      run_scene(:enter_name, self, lambda {|n| name = n })

      if name
        @high_score_data[FIELD_LEVELS][level_number] = {
            FIELD_HIGH_SCORE => score,
            FIELD_HIGH_SCORER => name,
        }

        update_high_score

        File.open(HIGH_SCORE_FILE, "w") {|f| f.puts @high_score_data.to_yaml }
      end
    end
  end

  def high_score
    @high_score_data[FIELD_LEVELS][level_number][FIELD_HIGH_SCORE] || 0
  end

  def high_scorer
    @high_score_data[FIELD_LEVELS][level_number][FIELD_HIGH_SCORER] || 0
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
    on :key_press, key(:escape) do
      pop_scene
    end

    on :focus_loss do
      # TODO: Disabled this, because it was working erratically.
      #push_scene :pause, self
    end

    always do
      now = Time.now.to_f
      @frame_time = [now - @last_frame_started_at, 0.1].min
      @last_frame_started_at = now

      start_at = now

      move_camera

      # Checking for collision on the screen is significantly slower than just rendering everything.
      @visible_dynamic_objects = @dynamic_objects

      # Update visible dynamic objects and stop them moving off the map. Others will just sleep off the side of the map.
      min_x = @player.x - @floor_camera.rect.width * 0.75
      max_x = @player.x + @floor_camera.rect.width
      @visible_objects = @dynamic_objects.select {|o| o.x >= min_x and o.x <= max_x }
      @visible_objects.sort_by!(&:z_order)
      @visible_objects.each(&:update)

      @progress.progress = (@player.position.x.to_f - @initial_player_x) / @distance_to_run
      @score.string = "%07d" % player.score

      @used_time += (Time.now - start_at).to_f
      recalculate_fps

      if DEVELOPMENT_MODE
        window.title = "Pos: (#{@player.x.round}, #{@player.y.round}), FPS: #{@fps.round} [#{@potential_fps.round}]"
      end

      update_shaders
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
      @level_text.draw_on win
      @timer.draw_on win
      @score.draw_on win
      @high_score.draw_on win
      @progress.draw_on win
      
      @used_time += (Time.now - start_at).to_f
    end
  end

  def update_shaders
    @shader_time ||= 0
    @shader_time += frame_time
    [SlowFloor, SlowSplat].each {|c| c.shader_time = @shader_time }
  end

  def move_camera
    # Move the cameras to the player position (left side, plus an amount asked for from the player).
    @wall_camera.x = @floor_camera.x =
        @player.x + (@wall_camera.rect.width / 2) - (@wall_camera.rect.width * @player.screen_offset_x)
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