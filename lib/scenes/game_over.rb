require_relative "dialog_scene"

class GameOver < DialogScene
  TEXT_SIZE = 6
  BUTTON_Y = 46

  TIME_MULTIPLIER = 10 # Speed of counting off time.
  SCORE_PER_S = 1000 # Score you get for each remaining second.

  def setup(previous_scene, winner)
    super(previous_scene, cursor_shown: false)

    @winner = winner

    gui_controls << Polygon.rectangle([0, 0, GAME_RESOLUTION.width, GAME_RESOLUTION.height * 0.9], Color.new(150, 150, 150))
    gui_controls.last.blend_mode = :multiply

    @buttons = []
    @buttons << Button.new("Menu", at: [GAME_RESOLUTION.width * 0.3, BUTTON_Y], size: TEXT_SIZE, auto_center: [0.5, 0]) do
      pop_scene :menu
    end

    @buttons << Button.new("Restart", at: [GAME_RESOLUTION.width * 0.5, BUTTON_Y], size: TEXT_SIZE, auto_center: [0.5, 0]) do
      pop_scene :restart
    end

    @next_button = Button.new("Next", at: [GAME_RESOLUTION.width * 0.7, BUTTON_Y], size: TEXT_SIZE, auto_center: [0.5, 0]) do
      pop_scene :next
    end

    @buttons << @next_button

    @button_background = Polygon.rectangle([0, @buttons.last.y - 1, GAME_RESOLUTION.width, @buttons.last.height + 2],
                                           Color.new(0, 0, 0, 100))

    @big_score = ShadowText.new("%07d" % @winner.score, at: [GAME_RESOLUTION.width / 2, GAME_RESOLUTION.height * 0.58], size: 20, blend_mode: :add,
                                color: Color.new(150, 150, 255, 200), shadow_color: Color.new(0, 0, 0, 200), auto_center: [0.5, 0.5])

    gui_controls << @big_score


    @all_time_removed = false
  end

  def register
    super
    on :key_press, key(:escape) do
      pop_scene :menu if previous_scene.timer.out_of_time?
    end

    event_group :buttons do
      @buttons.each {|b| b.register self, group: :buttons }
    end

    disable_event_group :buttons
  end

  def remove_all_time
    remove_time previous_scene.timer.remaining
  end

  def remove_time(duration)
    previous_scene.timer.decrease duration, finished: true
    @winner.score += SCORE_PER_S * duration
    previous_scene.update_score_cards
  end

  def update
    super

    # Empty out all the remaining time in the timer and convert to points, before finishing.
    if previous_scene.timer.out_of_time?
      unless @all_time_removed
        @all_time_removed = true

        score = @winner.score.to_i
        if score > previous_scene.high_score
          run_scene :enter_name, self do |name|
            if name
              user_data.set_high_score(previous_scene.level_number, name, score)
              previous_scene.update_high_score
            end
          end
        end

        # It is possible to get a high score without finishing and vice versa.
        if @winner.finished? and not user_data.finished_level?(previous_scene.level_number)
          user_data.finish_level(previous_scene.level_number)
        end

        @next_button.enabled = user_data.level_unlocked?(previous_scene.level_number + 1)

        self.cursor_shown = true
        gui_controls << @button_background
        self.gui_controls += @buttons

        enable_event_group :buttons
      end
    else
      remove_time [frame_time * TIME_MULTIPLIER, previous_scene.timer.remaining].min
    end

    @big_score.string = "%07d" % @winner.score
  end
end

