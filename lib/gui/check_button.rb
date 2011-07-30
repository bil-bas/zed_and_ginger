require_relative "button"

class CheckButton < Button
  def checked?; @checked; end

  def initialize(text, scene, options = {}, &handler)
    options = {
        shortcut: nil,
        checked: false,
    }.merge! options

    super('X', scene, options, &handler)

    spacing = (@text.size / scene.window.scaling) / 5
    @label = ShadowText.new(text, options.merge(at: options[:at].to_vector2 + [width + spacing, 0]))

    @checked = options[:checked]

    update_contents
  end

  def update_contents
    super
    @text.string = checked? ? '[X]' : '[ ]'
  end

  def activate
    @checked = (not checked?)

    update_contents
    @handler.call self, @checked
  end

  def draw_on(win)
    super(win)
    @label.draw_on win
  end
end
