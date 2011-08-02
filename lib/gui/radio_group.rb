class RadioGroup
  include Helper
  extend Forwardable
  include Registers

  def initialize(position, options = {}, &block)
    options = {
        spacing: 0.5,
        default_button_options: {},
    }.merge! options

    @spacing = options[:spacing]
    @position = position.to_vector2

    @default_button_options = options[:default_button_options]
    @selected_button = nil
    @handler = block

    @buttons = []

    super(scene)
  end

  def select(value)
    @selected_button.enabled = true if @selected_button

    @selected_button = @buttons.find {|b| b.data == value }
    @selected_button.enabled = false

    @handler.call value

    value
  end

  def button(text, value, options = {})
    position = if @buttons.empty?
      @position
    else
      [@buttons.last.x + @buttons.last.width + @spacing, @position.y]
    end

    options = @default_button_options.merge! options
    options.merge!(at: position, data: value, disabled_color: Color.red)
    button = Button.new(text, options) { select(value) }

    @buttons << button

    select(button.data) unless @selected_button
  end

  def register(scene)
    super(scene)
    @buttons.each {|b| b.register(scene) }
  end

  def draw_on(win)
    @buttons.each {|b| b.draw_on win }
  end
end
