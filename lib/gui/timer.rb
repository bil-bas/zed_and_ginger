class Timer
  COMPLETED_COLOR = Color.red

  def out_of_time?; @time_remaining == 0; end

  def initialize(time_remaining, options = {})
    @time_remaining = time_remaining.to_f
    @text = ShadowText.new "", options
    recalculate
  end

  def reduce(elapsed)
    @time_remaining = [@time_remaining - elapsed, 0.0].max
    if out_of_time?
      @text.color = COMPLETED_COLOR
    end
    recalculate
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