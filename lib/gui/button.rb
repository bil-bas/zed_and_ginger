class Button
  include Helper
  extend Forwardable

  attr_accessor :data

  def_delegators :'@text.rect', :height, :width

  def enabled?; @enabled; end

  COLOR = Color.white
  DISABLED_COLOR = Color.new(100, 100, 100)

  def initialize(text, scene, options = {}, &handler)
    raise "Button must have handler" unless block_given?

    options = {
        enabled: true,
        color: COLOR.dup,
        disabled_color: DISABLED_COLOR.dup,
    }.merge! options

    @color = options[:color]
    @disabled_color = options[:disabled_color]


    shortcut = options.has_key?(:shortcut) ? options[:shortcut] : text[0].downcase.to_sym
    if shortcut
      scene.add_event_handler(:key_press, key(shortcut)) { activate }
    end

    @data = options[:data]
    @text = Text.new "[#{text}]", options
    @handler = handler

    scene.add_event_handler(:mouse_press) do |button, pos|
      activate if button == :left and enabled? and @text.to_rect.contain?(pos / Window.scaling)
    end

    self.enabled = options[:enabled]
  end

  def enabled=(enabled)
    @enabled = enabled
    @text.color =  @enabled ? @color : @disabled_color
    @enabled
  end

  def activate
    @handler.call self
  end

  def draw_on(win)
    @text.draw_on win
  end
end