class ShadowText
  extend Forwardable

  def_delegators :@main, :color, :color=, :x, :y, :pos, :x=, :y=, :pos, :pos=, :rect,
                 :auto_center, :auto_center=, :size
  def_delegators :'@main.rect', :height, :width

  def initialize(string, options = {})
    options = {
        shadow_offset: [0.25, 0.25],
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
