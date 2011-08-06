require_relative 'game_scene'

class ReadySetGo < GameScene
  def setup(previous_scene)
    super()

    @previous_scene = previous_scene

    @message = ShadowText.new "Ready...", at: [37.5, 8.75], size: 8
    gui_controls << @message

    @beep = sound sound_path("ready_beep.ogg")
    @beep.volume = 30 * (user_data.effects_volume / 50.0)
    @beep.play

    @message_strings = ["Set...", "Go!!!"]

    @next_event_at = Time.now + 1
    @last_time = Time.now
  end

  def update
    if Time.now >= @next_event_at
      unless @message_strings.any?
        pop_scene
        return
      end

      @beep.play
      @message.string = @message_strings.shift
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