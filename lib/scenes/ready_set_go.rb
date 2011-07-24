class ReadySetGo < Scene
  def setup(previous_scene)
    @previous_scene = previous_scene
    time = Time.now.to_f

    @message = ShadowText.new "Ready...", at: [37.5, 8.75], size: 8
    @events = [
        ->{ @message.string = "Set..." },
        ->{ @message.string = "Go!" },
        ->{ exit! }
    ]

    @time_events = [time + 1, time + 2, time + 3]

    @beep = sound sound_path("ready_beep.ogg")
    @beep.volume = 30
  end

  def register
    always do
      if Time.now.to_f >= @time_events.first
        @time_events.shift
        @beep.play
        @events.shift.call
      end
    end
  end

  def render(win)
    @previous_scene.render(win)

    win.with_view win.default_view do
      @message.draw_on win
    end
  end
end