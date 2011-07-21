class ShadowText
  extend Forwardable

  def_delegators :@main, :color, :color=, :x, :y, :pos

  def initialize(string, options = {})
    options = {
        shadow_offset: [2, 2],
        shadow_color: Color.black,
    }.merge! options

    @main = Text.new string, options

    @shadow = Text.new string, options # @main.dup should work here.
    @shadow.color = options[:shadow_color]
    @shadow.pos += options[:shadow_offset]
  end

  def string=(string)
    @main.string = @shadow.string = string
  end

  def draw_on(window)
    window.draw @shadow
    window.draw @main
  end
end
