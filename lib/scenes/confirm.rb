# encoding: UTF-8

require_relative "dialog_scene"

class Confirm < DialogScene
  BLANK_CHAR = '.'
  MAX_CHARS = 3

  def setup(previous_scene, message)
    super(previous_scene)

    gui_controls << Polygon.rectangle(window.view.rect, Color.new(0, 0, 0, 220))

    width = GAME_RESOLUTION.width

    heading = ShadowText.new(message, at: [width * 0.5, 20], size: 6, auto_center: [0.5, 0])
    gui_controls << heading

    gui_controls << Button.new("OK", self, at: [width * 0.37, 40], size: 8, auto_center: [0.5, 0]) do
      pop_scene true
    end

    gui_controls << Button.new("Cancel", self, at: [width * 0.63, 40], size: 8, auto_center: [0.5, 0]) do
      pop_scene false
    end
  end

  def register
    super

    on :key_press, key(:escape) do
      pop_scene false
    end
  end
end


