class Timer
  OUT_OF_TIME_COLOR = Color.red
  FINISHED_COLOR = Color.new(100, 100, 255)

  attr_reader :remaining
  def elapsed; @total_time - @remaining; end

  def out_of_time?; @remaining == 0; end

  def initialize(duration, options = {})
    @total_time = duration.to_f
    @remaining = @total_time
    @text = ShadowText.new "", options
    recalculate
  end

  def decrease(time, options = {})
    options = {
        finished: false, # Means the player has finished, so reducing time to 0 is OK.
    }.merge! options

    @remaining = [@remaining - time, 0.0].max
    if out_of_time?
      @text.color = options[:finished] ? FINISHED_COLOR : OUT_OF_TIME_COLOR
    end
    recalculate
  end

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