class Button
  include Helper
  extend Forwardable
  include Registers

  attr_accessor :data

  def_delegators :'@text.rect', :x, :y, :height, :width

  def enabled?; @enabled; end

  COLOR = Color.white
  DISABLED_COLOR = Color.new(100, 100, 100)
  HOVER_COLOR =  Color.new(175, 175, 255)

  def initialize(text, scene, options = {}, &handler)
    raise "Button must have handler" unless block_given?

    options = {
        enabled: true,
        color: COLOR.dup,
        disabled_color: DISABLED_COLOR.dup,
        hover_color: HOVER_COLOR.dup,
    }.merge! options

    @color = options[:color]
    @disabled_color = options[:disabled_color]
    @hover_color = options[:hover_color]

    register(scene)

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

    # Handle mouse hovering.
    @under_mouse = false
    scene.add_event_handler(:mouse_motion) do |pos|
      if enabled? and @text.to_rect.contain?(pos / Window.scaling)
        unless @under_mouse
          @under_mouse = true
          raise_event :mouse_hover, self
          update_color
        end
      else
        if @under_mouse
          @under_mouse = false
          update_color
          raise_event :mouse_unhover, self
        end
      end
    end

    scene.add_event_handler(:mouse_unhover, self) do |pos|
      @under_mouse = false
      update_color
    end

    self.enabled = options[:enabled]
  end

  def unhover
    @under_mouse = false
    update_color
  end

  def enabled=(enabled)
    @enabled = enabled
    @under_mouse = false unless @enabled
    update_color
    @enabled
  end

  def update_color
    @text.color =  @enabled ? (@under_mouse ? @hover_color : @color) : @disabled_color
  end

  def activate
    @handler.call self
  end

  def draw_on(win)
    @text.draw_on win
  end
end