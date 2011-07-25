module Ray
  class Text
    alias_method :old_initialize, :initialize

    def initialize(string, options = {})
      # Create text which is
      options = options.dup
      options[:size] *= Window.scaling
      options[:scale] = [1.0 / Window.scaling] * 2
      old_initialize string, options
    end

    def draw_on(win)
      win.draw self
    end
  end
end