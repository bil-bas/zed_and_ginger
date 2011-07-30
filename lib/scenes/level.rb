require_relative '../objects/player'
require_relative '../wall_map'
require_relative '../floor_map'

require_relative 'game_scene'

class Level < GameScene
  attr_reader :frame_time, :floor_map, :players, :timer, :scene_time, :level_number

  WALL_MAP_ROWS = 3
  FLOOR_MAP_ROWS = 6

  FONT_SIZE = 5.625
  START_TILE_GRID_X = 15

  MAX_CAMERA_ZOOM_CHANGE = 1 # Most the zoom can change in a second.
  MAX_CAMERA_X_CHANGE = 64 # Most the camera's position can change in a second.

  def setup(level_number, player_data)
    started_at = Time.now

    super()

    @level_number, @player_data = level_number, player_data

    # Create maps and objects
    @dynamic_objects = [] # Objects that need #update

    level_data = YAML::load_file(File.expand_path(File.join(EXTRACT_PATH, "config/levels/#{level_number}.yml")))
    @wall_map = WallMap.new self, level_data['wall']['tiles'].split("\n"),
                            level_data['wall']['default_tile']
    @floor_map = FloorMap.new self, level_data['floor']['tiles'].split("\n"),
                              Kernel::const_get(level_data['floor']['default_tile'].to_sym),
                              messages: level_data['messages'], player_name: @player_data.keys.first

    # Create the players on the start line.
    start_grid_positions = if @player_data.size == 1
      [[START_TILE_GRID_X, 2]]
    else
      [[START_TILE_GRID_X, 1], [START_TILE_GRID_X, 3]]
    end

    @players = []
    @player_data.each_pair.with_index do |(name, sheet), i|
      position = (start_grid_positions[i].to_vector2 + [0.5, 0.5]) * FloorTile.size
      @players << Player.new(self, @floor_map.tile_at_grid(start_grid_positions[i]), position, sheet, name)
    end

    @initial_player_x = players.first.x
    @distance_to_run = @floor_map.finish_line_x - @initial_player_x

    # Player's score, time remaining and progress through the level.
    text_color = Color.new(190, 190, 255)
    score_height = window.scaled_size.height - 6.625
    gui_controls << Polygon.rectangle([0, window.scaled_size.height - 6, window.scaled_size.width, 6], Color.new(80, 80, 80))
    gui_controls << ShadowText.new("L%02d" % level_number, at: [3, score_height], size: FONT_SIZE, color: text_color)
    @high_score = ShadowText.new "XXX: 0000000", at: [15.5, score_height], size: FONT_SIZE, color: text_color
    @score = ShadowText.new "0000000", at: [53, score_height], size: FONT_SIZE, color: text_color
    @timer = Timer.new level_data['time_limit'], at: [76, score_height], size: FONT_SIZE, color: text_color
    @progress = ProgressBar.new(Rect.new(0, window.scaled_size.height - 2, window.scaled_size.width, 2))

    self.gui_controls += [@high_score, @score, @timer, @progress]

    init_fps
    update_high_score

    @game_over = false

    # Setup a few things, so we can show a countdown before playing.
    @progress.progress = 0
    @visible_objects = @players.dup
    @frame_time = 0

    @camera_zoom = 1.0
    # Make the camera pan during intro, so place it near the start.
    @camera_x = FloorTile.width * 8

    update_camera(0)

    @level_music ||= music music_path "Space_Cat_Habitat.ogg"
    @level_music.volume = 20

    @finish_music ||= music music_path "Space_Cat_Winner.ogg"
    @finish_music.volume = 50

    calculate_visible_objects

    log.info { "#{self.class}##{level_number} loaded in #{Time.now - started_at}s" }

    run_scene :ready_set_go, self unless DEVELOPMENT_MODE

    @level_music.play

    if defined? RubyProf
      RubyProf.resume
      log.debug { "Profiling resumed" }
    end
  end

  def clean_up
    if defined? RubyProf
      RubyProf.pause
      log.debug { "Profiling paused" }
    end

    @level_music.stop
    @finish_music.stop
  end

  def update_high_score
    @high_score.string = "%s: %07d" % [high_scorer, high_score]
  end

  # Called from an overlay state.
  def update_intro_objects(duration)
    @frame_time = duration
    visible_objects = @dynamic_objects.select {|o| not o.is_a?(Player) and o.x < 200 }
    visible_objects.each {|o| o.update }
  end

  def game_over(player)
    @level_music.stop
    @finish_music.play if player.finished?

    if player.score > high_score
      run_scene(:enter_name, self) do |name|
        if name
          window.user_data.set_high_score(level_number, name, player.score)
          update_high_score
        end
      end
    end

    # It is possible to get a high score without finishing and vice versa.
    if player.finished? and not window.user_data.finished_level?(level_number)
      window.user_data.finish_level(level_number)
    end

    run_scene :game_over, self, window.user_data.level_unlocked?(@level_number + 1) do |choice|
      pop_scene

      case choice
        when :menu
          # Do nothing.
        when :restart
          push_scene :level, @level_number, @player_data
        when :next
          push_scene :level, @level_number + 1, @player_data
      end
    end
  end

  def high_score
    window.user_data.high_score(level_number)
  end

  def high_scorer
    window.user_data.high_scorer(level_number)
  end
  
  def add_object(object)
    @dynamic_objects << object
  end

  def remove_object(object)
    @dynamic_objects -= [object]
  end

  def objects; @dynamic_objects; end

  def pause; run_scene :pause, self unless @game_over; end

  def register
    on :key_press, key(:escape) do
      pop_scene
    end

    on :focus_loss do
      pause
    end

    on :key_press, *key_or_code(window.user_data.control(:pause)) do
      pause
    end

    always do
      started_at = Time.now.to_f
      @scene_time = started_at - @level_started_at # Time elapsed since start of level.
      @frame_time = [@scene_time - @last_frame_started_at, 0.1].min # Time elapsed since start of last frame.
      @last_frame_started_at = @scene_time

      update_camera(frame_time)

      timer.decrease frame_time if @players.all?(&:ok?)

      calculate_visible_objects
      @visible_objects.each(&:update)

      @progress.progress = (@players.first.position.x.to_f - @initial_player_x) / @distance_to_run
      @score.string = "%07d" % players.first.score

      @used_time += Time.now.to_f - started_at
      recalculate_fps

      if DEVELOPMENT_MODE
        window.title = "FPS: #{@fps.round} [#{@potential_fps.round}]"
      end

      update_shaders
    end
  end

  def calculate_visible_objects
    # Update visible dynamic objects and stop them moving off the map. Others will just sleep off the side of the map.
    x_positions = @players.map do |player|
      [
          player.x - window.scaled_size.width * 0.75, # Look behind.
          player.x + window.scaled_size.width * 1 # Look ahead a bit more to wake things up.
      ]
    end

    @visible_objects = @dynamic_objects.select do |o|
      x_positions.any? {|min, max| o.x.between?(min, max) }
    end

    @visible_objects.sort_by!(&:z_order)
  end
    
  def render(win)
    start_at = Time.now

    background.draw_on win

    view = window.view
    # Expand the view of the world.
    view.size /= [@camera_zoom, 1]

    # Clip on the screen.
    viewport = view.viewport
    viewport.y += viewport.height * (1.0 / @camera_zoom - 1) * 0.25
    viewport.height *= @camera_zoom
    view.viewport = viewport

    # Create a camera for displaying the wall map
    view.center = [@camera_x, view.rect.height / 2.0]
    win.with_view view do
      @wall_map.draw_on(win)
    end

    # Create a camera for displaying the floor map (which has origin set in the view)
    view.y -= @wall_map.to_rect.height
    win.with_view view do
      @floor_map.draw_on(win)

      @visible_objects.each {|obj| obj.draw_shadow_on win }
      @visible_objects.each {|obj| obj.draw_on win }
      if DEVELOPMENT_MODE
        @visible_objects.each {|obj| obj.draw_debug_on win }
      end
    end

    super

    @used_time += (Time.now - start_at).to_f
  end

  def update_shaders
    CLASSES_WITH_SHADERS.each {|c| c.shader_time = timer.elapsed }
  end

  def update_camera(duration)
    # Move the cameras to the player position (left side, plus an amount asked for from the player).
    if players.size == 1
      player = players.first
      @desired_camera_x = player.view_range_x.max - GAME_RESOLUTION.width / 2
    else
      view_ranges = @players.map {|p| p.view_range_x }
      left_edge_of_view = view_ranges.map {|r| r.min }.min
      right_edge_of_view = view_ranges.map {|r| r.max }.max
      view_range = right_edge_of_view - left_edge_of_view

      # Zoom out if necessary to fit everything in.
      @desired_camera_zoom = [[GAME_RESOLUTION.width / view_range, 0.5].max, 1.0].min

      # Prevent fast zooming in/out.
      max_zoom_change = MAX_CAMERA_ZOOM_CHANGE * duration
      @camera_zoom += [[@desired_camera_zoom - @camera_zoom, max_zoom_change].min, -max_zoom_change].max

      @desired_camera_x = right_edge_of_view - (GAME_RESOLUTION.width / (2 * @camera_zoom))
    end

    # Prevent rapid shifts as we accelerate or come to a stop.
    max_x_change = MAX_CAMERA_X_CHANGE * duration
    @camera_x += [[@desired_camera_x - @camera_x, max_x_change].min, -max_x_change].max
  end
  
  def init_fps
    @level_started_at = Time.now.to_f
    @last_frame_started_at = 0
    @fps_next_calculated_at = @level_started_at + 1
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