class ReadySetGo < Scene
  def setup(previous_scene)
    @previous_scene = previous_scene
    time = Time.now.to_f

    @message = ShadowText.new "Ready...", at: [300, 70], font: FONT_NAME, size: 80
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

    render do |win|
      @previous_scene.render(win)

      @message.draw_on win
    end
  end
end