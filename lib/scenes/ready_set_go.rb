require 'fiber'

require_relative 'game_scene'

class ReadySetGo < GameScene
  def setup(previous_scene)
    super()

    @previous_scene = previous_scene

    @message = ShadowText.new "Ready...", at: [37.5, 8.75], size: 8
    gui_controls << @message

    beep = sound sound_path("ready_beep.ogg")
    beep.volume = 30 * (user_data.effects_volume / 50.0)
    p beep.volume
    beep.play

    @events = Fiber.new do
      ["Set...", "Go!!!"].each do |string|
        @message.string = string
        beep.play
        Fiber.yield
      end
    end

    @next_event_at = Time.now + 1

    @last_time = Time.now
  end

  def update
    if Time.now >= @next_event_at
      @events.resume
      pop_scene unless @events.alive?
      @next_event_at += 1
    end

    @previous_scene.update_camera(Time.now - @last_time)
    @previous_scene.update_intro_objects
    @last_time = Time.now
  end

  def render(win)
    @previous_scene.render(win)
    super(win)
  end
end