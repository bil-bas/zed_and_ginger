require_relative '../objects/player'
require_relative '../wall_map'
require_relative '../floor_map'

require_relative 'game_scene'

class Level < GameScene
  FONT_SIZE = 5.25
  START_TILE_GRID_X = 15

  TEXT_COLOR = Color.new(190, 190, 255)
  GUI_BACKGROUND_COLOR = Color.new(80, 80, 80)

  SCORE_BAR_HEIGHT = 6.625

  # All the levels available (Array of Integer)
  LEVEL_NUMBERS = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")].map {|file| File.basename(file).to_i }.sort

  def_delegator :@maps, :floor, :floor_map

  attr_reader :players, :timer, :level_number

  def hardcore?; @hardcore; end
  def inversion?; @inversion; end

  def setup(level_number, player_data, hardcore, inversion)
    started_at = Time.now

    super()

    @level_number, @player_data, @hardcore, @inversion = level_number, player_data, hardcore, inversion

    # Create maps and objects
    @dynamic_objects = [] # Objects that need #update

    @maps = Maps.new(self, level_number, @player_data.keys.first)

    # Create the players on the start line.
    start_grid_positions = if @player_data.size == 1
      [[START_TILE_GRID_X, 2]]
    else
      [[START_TILE_GRID_X, 1], [START_TILE_GRID_X, 3]]
    end

    @players = []
    @player_data.each_pair.with_index do |(name, sheet), i|
      position = (start_grid_positions[i].to_vector2 + [0.5, 0.5]) * FloorTile.size
      @players << Player.new(self, @maps.floor.tile_at_grid(start_grid_positions[i]), position, sheet, name)
    end

    @initial_player_x = players.first.x
    @distance_to_run = @maps.finish_line_x - @initial_player_x

    # Player's score, time remaining and progress through the level.
    score_y = window.scaled_size.height - SCORE_BAR_HEIGHT
    width, height = window.scaled_size.width, window.scaled_size.height
    gui_controls << Polygon.rectangle([0, height - 6, width, 6], GUI_BACKGROUND_COLOR)
    main_left = width / 3.0 + 2
    main_right = width * 2 / 3.0 - 2
    gui_controls << ShadowText.new("L%02d" % level_number, at: [main_left, score_y], size: FONT_SIZE, color: TEXT_COLOR)
    @timer = Timer.new @maps.time_limit, at: [main_right, score_y], size: FONT_SIZE, color: TEXT_COLOR, auto_center: [1, 0]
    @high_score = ShadowText.new "XXX: 000000", at: [width / 2, score_y + FONT_SIZE * 0.7], size: FONT_SIZE * 0.75,
                                 color: TEXT_COLOR, auto_center: [0.5, 0]

    self.gui_controls += [@high_score, @timer]

    @player_score_cards = @players.map do |player|
      x = (player.name == :zed) ? 0 : (width * 2.0 / 3.0)
      ScoreCard.new(player, x, score_y, FONT_SIZE, TEXT_COLOR, @distance_to_run)
    end

    self.gui_controls += @player_score_cards

    update_high_score

    @game_over = false

    # Setup a few things, so we can show a countdown before playing.
    @visible_objects = @players.dup

    # Make the camera pan during intro, so place it near the start.
    @cameras = [Camera.new(FloorTile.width * 8)]
    @screen_splitter = Polygon.rectangle([GAME_RESOLUTION.width / 2, 0, 1, GAME_RESOLUTION.height], Color.new(50, 50, 50))
    update_camera(0)

    ambient_music.stop

    @level_music ||= music music_path "Space_Cat_Habitat.ogg"
    @level_music.volume = 20 * (user_data.music_volume / 50.0)

    @finish_music ||= music music_path "Space_Cat_Winner.ogg"
    @finish_music.volume = 50 * (user_data.music_volume / 50.0)

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
  def update_intro_objects
    visible_objects = @dynamic_objects.select {|o| not o.is_a?(Player) and o.x < 200 }
    visible_objects.each {|o| o.update }
  end

  # The game has completed, but score still needs to be calculated.
  def game_over(player)
    @level_music.stop

    if player.finished?
      @finish_music.play
    end

    # If in hardcore mode, then one player dying doesn't stop the game; they just get cut out.
    other_player = (@players - [player]).first
    if player.dead? and hardcore? and @players.size == 2
      log.info "#{player} died in hardcore mode. Continuing with #{other_player}"

      if @cameras.size == 2
        camera_index = @players.index player
        camera = @cameras[camera_index]
        camera_offset = GAME_RESOLUTION.width / 4.0 * (camera_index == 0 ? 1 : -1)
        @cameras = [Camera.new(camera.x + camera_offset, zoom: 0.5)]
      end

      # Other player stops being real and just becomes a dumb object.
      @players = [other_player]
      # TODO: This speeds remaining player up for no apparent reason. Why?
      #add_object other_player
    else
      # Stop the game now that one player is done.
      other_player.lose if other_player

      run_scene :game_over, self, player do |choice|
        pop_scene

        case choice
          when :menu
            # Do nothing.
          when :restart
            push_scene :level, @level_number, @player_data, @hardcore, @inversion
          when :next
            user_data.selected_level = @level_number + 1
            push_scene :level, @level_number + 1, @player_data, @hardcore, @inversion
        end
      end
    end
  end

  def high_score
    user_data.high_score(level_number)
  end

  def high_scorer
    user_data.high_scorer(level_number)
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
    super

    on :key_press, key(:escape) do
      pop_scene
    end

    on :focus_loss do
      pause
    end

    on :key_press, *key_or_code(user_data.control(:pause)) do
      pause
    end
  end

  def update
    update_camera(frame_time)

    timer.decrease frame_time if @players.all?(&:ok?)

    calculate_visible_objects
    @visible_objects.each(&:update)

    update_score_cards

    update_shaders
  end

  def update_score_cards
    @player_score_cards.each(&:update)
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
    background.draw_on win

    world_view = win.view
    world_view.size *= [1, @maps.height_factor] # Clip off the score bar.
    world_view.zoom_by [1, -1] if @inversion

    # Clip on the screen.
    viewport = world_view.viewport
    viewport.height *= @maps.height_factor # Clip off the score bar.
    world_view.viewport = viewport

    @cameras.each do |camera|
      camera_view = camera.view_for(world_view)

      # Create a camera for displaying the wall map
      camera_view.y = camera_view.rect.height / (@inversion ? -2.0 : 2.0)
      win.with_view camera_view do
        @maps.wall.draw_on(win)
      end

      # Create a camera for displaying the floor map (which has origin set in the view)
      camera_view.y -= @maps.wall.to_rect.height
      win.with_view camera_view do
        @maps.floor.draw_on(win)

        @visible_objects.each {|obj| obj.draw_shadow_on win }
        @visible_objects.each {|obj| obj.draw_on win }
        if DEVELOPMENT_MODE
          @visible_objects.each {|obj| obj.draw_debug_on win }
        end
      end
    end

    win.draw @screen_splitter if @cameras.size == 2

    super
  end

  def update_shaders
    CLASSES_WITH_SHADERS.each {|c| c.shader_time = timer.elapsed }
  end

  def update_camera(duration)
    # Move the cameras to the player position (left side, plus an amount asked for from the player).
    if players.size == 1
      @cameras.first.zoom_to(1, duration) # May be used if one player dies.
      @cameras.first.pan_to(players.first.view_range_x.max - GAME_RESOLUTION.width / 2, duration)
    else
      view_ranges = @players.map {|p| p.view_range_x }
      left_edge_of_view = view_ranges.map {|r| r.min }.min
      right_edge_of_view = view_ranges.map {|r| r.max }.max
      view_range = right_edge_of_view - left_edge_of_view

      if view_range <= GAME_RESOLUTION.width * 2
        # Return to a single camera if we were in split screen.
        if @cameras.size == 2
          @cameras = [Camera.new((@cameras.first.x + @cameras.last.x) / 2.0, zoom: 0.5)]
        end

        # Players are close, but zoom out if necessary to fit everything in.
        # Prevent fast zooming in/out.
        @cameras.first.zoom_to([[GAME_RESOLUTION.width / view_range, 0.5].max, 1.0].min, duration)
        @cameras.first.pan_to(right_edge_of_view - GAME_RESOLUTION.width / (2 * @cameras.first.zoom), duration)
      else
        # Split into two independent cameras if we were just zoomed in.
        if @cameras.size == 1
          current_x = @cameras.first.x
          @cameras = [
              Camera.new(current_x - GAME_RESOLUTION.width / 2, zoom: 0.5, width: 0.5),
              Camera.new(current_x + GAME_RESOLUTION.width / 2, zoom: 0.5, width: 0.5, offset_x: 0.5),
          ]
        end

        loser, winner = @players.sort_by(&:x)

        @cameras.first.pan_to(loser.view_range_x.max - GAME_RESOLUTION.width * 0.5, duration)
        @cameras.last.pan_to(winner.view_range_x.max - GAME_RESOLUTION.width * 0.5, duration)
      end
    end
  end
end