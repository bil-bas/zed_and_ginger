# Shows a player's score and progress on the gui bar
class ScoreCard
  include Helper
  extend Forwardable
  include Registers

  SCORE_DIGITS = 7
  SCORE_STRING = "%0#{SCORE_DIGITS}d"

  def initialize(player, x, y, font_size, text_color, distance_to_run)
    @player, @distance_to_run = player, distance_to_run
    @initial_player_x = player.x

    @name = ShadowText.new player.name.to_s.capitalize + ': ', at: [x + 1, y], size: font_size, color: text_color
    @score = ShadowText.new "", at: [x + @name.width + 1, y], size: font_size, color: text_color
    window_size = @player.scene.window.scaled_size
    @progress = ProgressBar.new(player.scene, Rect.new(x, y + font_size - 0.5, window_size.width / 3.0, 2))
    @progress.progress = 0

    register(player.scene)
  end

  def register(scene)
    super scene
    @player.scene.gui_controls += [@score, @progress, @name]
  end

  def update
    @progress.progress = (@player.x.to_f - @initial_player_x) / @distance_to_run
    @score.string = SCORE_STRING % @player.score
  end

  def draw_on(win)
    @score.draw_on win
    @progress.draw_on win
  end
end