module Ray
  class Text
    DEFAULT_FONT = font_path("MonteCarloFixed12.ttf") # http://www.bok.net/MonteCarlo/

    alias_method :original_initialize, :initialize

    def initialize(text, options)
      options = {
          size: 8,
          font: DEFAULT_FONT,
      }.merge! options

      original_initialize(text, options)
    end
  end
end