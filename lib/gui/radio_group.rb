class RadioGroup
  include Helper
  extend Forwardable
  include Registers

  SELECTED_COLOR = Color.red

  def height; (@buttons + @disabled_buttons).map(&:height).max; end

  def initialize(options = {}, &block)
    options = {
        at: [0, 0],
        spacing: 0.5,
        default_button_options: {},
        initial_value: nil,
    }.merge! options

    @spacing = options[:spacing]
    @position = options[:at].to_vector2
    @initial_value = options[:initial_value]

    @default_button_options = options[:default_button_options]
    @selected_button = nil
    @handler = block

    @buttons = []
    @disabled_buttons = []

    super(scene)
  end

  def value; @selected_button.data; end

  def select(value)
    @selected_button.enabled = true if @selected_button

    @selected_button = @buttons.find {|b| b.data == value }
    @selected_button.enabled = false

    @handler.call value if @handler

    value
  end

  def button(text, value, options = {})
    options = @default_button_options.merge options

    options = {
        enabled: true,
    }.merge! options

    position = if @buttons.empty?
      @position
    else
      last_button = (@buttons + @disabled_buttons).sort_by(&:x).last
      [last_button.x + last_button.width + @spacing, @position.y]
    end

    enabled = options[:enabled]

    disabled_color = enabled ? SELECTED_COLOR : (options[:disabled_color] || Button::DISABLED_COLOR)
    options.merge!(at: position, data: value, disabled_color: disabled_color, group: self)
    button = Button.new(text, options) { select(value) }

    if enabled
      @buttons << button
      select(button.data) if @initial_value and button.data == @initial_value
    else
      @disabled_buttons << button
    end
  end

  def register(scene)
    super(scene)
    @buttons.each {|b| b.register(scene) }
  end

  def draw_on(win)
    @buttons.each {|b| b.draw_on win }
    @disabled_buttons.each {|b| b.draw_on win }
  end
end
