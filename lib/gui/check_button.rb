require_relative "button"

class CheckButton < Button
  def checked?; @checked; end
  def checked=(checked)
    @checked = checked
    update_contents
    @checked
  end

  def initialize(text, options = {}, &handler)
    options = {
        shortcut: text[0].downcase.to_sym,
        checked: false,
    }.merge! options

    @label = text

    super("[X]#{@label}", options, &handler)

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
