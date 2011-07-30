class Button
  include Helper
  extend Forwardable
  include Registers

  attr_accessor :data

  def_delegators :'@text.rect', :x, :y, :height, :width

  def under_mouse?; @under_mouse; end
  def enabled?; @enabled; end

  COLOR = Color.white
  DISABLED_COLOR = Color.new(100, 100, 100)
  HOVER_COLOR =  Color.new(175, 175, 255)

  def initialize(text, scene, options = {}, &handler)
    raise "#{self.class} must have handler" unless block_given?

    options = {
        enabled: true,
        color: COLOR.dup,
        disabled_color: DISABLED_COLOR.dup,
        hover_color: HOVER_COLOR.dup,
    }.merge! options

    @color = options[:color]
    @disabled_color = options[:disabled_color]
    @hover_color = options[:hover_color]

    @shortcut = options.has_key?(:shortcut) ? options[:shortcut] : text[0].downcase.to_sym

    @data = options[:data]
    @text = Text.new "[#{text}]", options
    @handler = handler

    self.enabled = options[:enabled]

    update_contents
  end

  def register(scene, options = {})
    options = {
        group: :default,
    }.merge! options

    super(scene)

    event_group options[:group] do
      if @shortcut
        on(:key_press, key(@shortcut)) { activate }
      end

      on :mouse_press do |button, pos|
        activate if button == :left and enabled? and @text.to_rect.contain?(pos / Window.scaling)
      end

      # Handle mouse hovering.
      @under_mouse = false
      on :mouse_motion do |pos|
        if enabled? and @text.to_rect.contain?(pos / Window.scaling)
          unless @under_mouse
            @under_mouse = true
            raise_event :mouse_hover, self
            update_contents
          end
        else
          if @under_mouse
            @under_mouse = false
            update_contents
            raise_event :mouse_unhover, self
          end
        end
      end

      on :mouse_unhover, self do |pos|
        @under_mouse = false
        update_contents
      end
    end
  end

  def update_contents
    @text.color = current_color
  end

  def unhover
    @under_mouse = false
    update_contents
  end

  def enabled=(enabled)
    @enabled = enabled
    @under_mouse = false unless @enabled
    update_contents
    @enabled
  end

  def current_color
    @enabled ? (@under_mouse ? @hover_color : @color) : @disabled_color
  end

  def activate
    @handler.call self
  end

  def draw_on(win)
    @text.draw_on win
  end
end