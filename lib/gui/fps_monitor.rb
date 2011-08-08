class FpsMonitor
  attr_reader :fps, :potential_fps, :frame_time, :frame_number

  def shown?; @shown; end
  def toggle; @shown = (not @shown); end

  def initialize
    @started_at = Time.now.to_f
    @last_frame_started_at = 0
    @fps_next_calculated_at = @started_at + 1
    @fps = @potential_fps = 0
    @num_frames = 0
    @used_time = 0
    @frame_number = -1

    @shown = false
    @text = ShadowText.new "FPS", size: 5, at: [2, 0],
                               color: Color.new(200, 200, 200, 150),
                               shadow_color: Color.new(0, 0, 0, 150)
  end

  public
  def run_frame(&block)
    @frame_number += 1
    @frame_started_at = Time.now.to_f
    @elapsed = @frame_started_at - @started_at # Time elapsed since start of level.
    @frame_time = [@elapsed - @last_frame_started_at, 0.1].min # Time elapsed since start of last frame.
    @last_frame_started_at = @elapsed

    yield

    @used_time += Time.now.to_f - @frame_started_at
    recalculate_fps
  end

  protected
  def recalculate_fps
    @num_frames += 1

    if Time.now.to_f >= @fps_next_calculated_at
      elapsed_time = @fps_next_calculated_at - Time.now.to_f + 1
      @fps = @num_frames / elapsed_time
      @potential_fps = @num_frames / [@used_time, 0.0001].max

      @num_frames = 0
      @fps_next_calculated_at = Time.now.to_f + 1
      @used_time = 0

      @text.string = "FPS:%3d[%3d]" % [@fps, @potential_fps]
    end
  end

  public
  def draw_on(win)
    @text.draw_on(win)
  end
end