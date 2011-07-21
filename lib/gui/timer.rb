class Timer
  OUT_OF_TIME_COLOR = Color.red
  FINISHED_COLOR = Color.new(100, 100, 255)

  def out_of_time?; @time_remaining == 0; end

  def initialize(time_remaining, options = {})
    @time_remaining = time_remaining.to_f
    @text = ShadowText.new "", options
    recalculate
  end

  def decrease(elapsed, options = {})
    options = {
        finished: false, # Means the player has finished, so reducing time to 0 is OK.
    }.merge! options

    @time_remaining = [@time_remaining - elapsed, 0.0].max
    if out_of_time?
      @text.color = options[:finished] ? FINISHED_COLOR : OUT_OF_TIME_COLOR
    end
    recalculate
  end

  def increase(time)
    @time_remaining += time
  end

  def draw_on(win)
    @text.draw_on(win)
  end

  protected
  def recalculate
    minutes, seconds = @time_remaining.divmod 60
    seconds, milliseconds = seconds.divmod 1
    @text.string = "%01d'%02d\"%s" % [minutes, seconds, milliseconds.to_s[2]]
  end
end