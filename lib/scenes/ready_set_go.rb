require 'fiber'

require_relative 'game_scene'

class ReadySetGo < GameScene
  def setup(previous_scene)
    super()

    @previous_scene = previous_scene
    time = Time.now.to_f

    @message = ShadowText.new "Ready...", at: [37.5, 8.75], size: 8
    gui_controls << @message

    beep = sound sound_path("ready_beep.ogg")
    beep.volume = 30
    beep.play

    @events = Fiber.new do
      ["Set...", "Go!!!"].each do |string|
        @message.string = string
        beep.play
        Fiber.yield
      end
    end

    @next_event_at = Time.now + 1
  end

  def register
    always do
      if Time.now >= @next_event_at
        @events.resume
        pop_scene unless @events.alive?
        @next_event_at += 1
      end
    end
  end

  def render(win)
    @previous_scene.render(win)
    super(win)
  end
end