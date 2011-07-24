module Ray
  class Text
    DEFAULT_FONT = font_path("MonteCarloFixed12.ttf") # http://www.bok.net/MonteCarlo/

    alias_method :original_initialize, :initialize

    def initialize(text, options)
      options = {
          size: 8,
          font: DEFAULT_FONT,
      }.merge! options

      scaling = Window.user_data.scaling
      options[:at] = (options[:at] || [0, 0]).to_vector2 *  scaling
      options[:size] *= scaling

      original_initialize(text, options)
    end
  end
end