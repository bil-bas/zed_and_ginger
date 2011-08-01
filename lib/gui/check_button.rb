require_relative "button"

class CheckButton < Button
  def checked?; @checked; end
  def checked=(checked)
    @checked = checked
    update_contents
    @checked
  end

  def initialize(text, scene, options = {}, &handler)
    options = {
        shortcut: nil,
        checked: false,
    }.merge! options

    super('X', scene, options, &handler)

    @label = text

    self.checked = options[:checked]
  end

  def update_contents
    super
    @text.string = "#{(checked? ? '[X]' : '[ ]')} #{@label}"
  end

  def activate
    @checked = (not checked?)

    update_contents
    @handler.call self, @checked
  end

  def draw_on(win)
    super(win)
  end
end
