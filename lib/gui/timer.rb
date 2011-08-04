class Timer
  OUT_OF_TIME_COLOR = Color.red
  FINISHED_COLOR = Color.new(100, 100, 255)

  attr_reader :remaining, :elapsed

  def out_of_time?; @remaining == 0; end

  def initialize(duration, options = {})
    @elapsed = 0
    @remaining = duration.to_f
    @text = ShadowText.new "", options
    recalculate
  end

  # Use up time.
  def decrease(time, options = {})
    options = {
        finished: false, # Means the player has finished, so reducing time to 0 is OK.
    }.merge! options

    decrease = [time, @remaining].min

    @elapsed += decrease unless options[:finished]
    @remaining -= decrease
    if out_of_time?
      @text.color = options[:finished] ? FINISHED_COLOR : OUT_OF_TIME_COLOR
    end
    recalculate
  end

  # Gain extra time.
  def increase(time)
    @remaining += time
  end

  def draw_on(win)
    @text.draw_on(win)
  end

  protected
  def recalculate
    minutes, seconds = @remaining.divmod 60
    seconds, milliseconds = seconds.divmod 1
    @text.string = "%01d:%02d.%s" % [minutes, seconds, milliseconds.to_s[2]]
  end
end