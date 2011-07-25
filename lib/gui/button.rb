class Button
  include Helper

  attr_accessor :data

  def initialize(text, scene, options = {}, &handler)

    shortcut = options.has_key?(options[:shortcut]) ? options[:shortcut] : text[0].downcase.to_sym
    if shortcut
      scene.add_event_handler(:key_press, key(shortcut)) { activate }
    end

    @data = options[:data]
    @text = Text.new "[#{text}]", options
    @handler = handler

    scene.add_event_handler(:mouse_press) do |button, pos|
      activate if button == :left and @text.to_rect.contain?(pos)
    end
  end

  def activate
    @handler.call self
  end

  def draw_on(win)
    win.draw @text
  end
end