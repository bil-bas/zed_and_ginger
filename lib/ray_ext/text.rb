module Ray
  class Text
    alias_method :old_initialize, :initialize

    def initialize(string, options = {})
      options = {
          auto_center: nil,
      }.merge! options

      # Create text which is
      options = options.dup
      options[:size] *= Window.scaling
      options[:scale] = [1.0 / Window.scaling] * 2

      old_initialize string, options

      self.auto_center = options[:auto_center]
    end

    alias_method :old_rect, :rect

    def rect
      rect = old_rect
      rect.x, rect.y = *(pos - origin * zoom)
      rect.y += rect.height * 0.2 # Otherwise the rect doesn't cover the bottom of the font.
      rect
    end

    alias_method :to_rect, :rect

    def draw_on(win)
      win.draw self
    end
  end
end