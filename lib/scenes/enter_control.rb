# encoding: UTF-8

require_relative "dialog_scene"

class EnterControl < DialogScene
  BLANK_CHAR = '.'
  MAX_CHARS = 3

  def setup(previous_scene, message, current)
    super(previous_scene)

    gui_controls << Polygon.rectangle(window.view.rect, Color.new(0, 0, 0, 220))

    width = GAME_RESOLUTION.width

    heading = ShadowText.new(message, at: [width * 0.5, 15], size: 6, auto_center: [0.5, 0])
    gui_controls << heading

    @key_display = Text.new(display_for_key(current), at: [width * 0.5, 20], size: 10, auto_center: [0.5, 0])
    gui_controls << @key_display

    gui_controls << Button.new("OK", at: [width * 0.37, 40], size: 8, auto_center: [0.5, 0], shortcut: nil) do
      pop_scene @key
    end

    gui_controls << Button.new("Cancel", at: [width * 0.63, 40], size: 8, auto_center: [0.5, 0], shortcut: nil) do
      pop_scene nil
    end

    @key_press_sound = sound sound_path("key_press.ogg")

    @key = nil

    disable_event_group :game_keys
  end

  def clean_up
    enable_event_group :game_keys
  end

  def register
    super

    on :key_press do |key_code, modifier, native_code|
      if Keys[:escape].include? key_code
        pop_scene nil
      else
        @key_press_sound.play

        key_name = Keys.find {|k, v| v.include? key_code }[0]

        @key = key_name == :unknown ? native_code : key_name

        @key_display.string = display_for_key(@key)
      end
    end
  end
end


