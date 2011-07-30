class Tile
  include Helper
  extend Forwardable

  def_delegators :@sprite, :position
  attr_reader :grid_position

  class << self
    def size; Vector2[width, height]; end
  end

  def height;  self.class.height; end
  def width; self.class.width; end
  def size; self.class.size; end
  
  def initialize(image, sprite_pos, grid_position, offset)
    @grid_position = grid_position
    @sprite = sprite image
    @sprite.sheet_size = [8, 8]
    @sprite.sheet_pos = sprite_pos
    @sprite.position = @grid_position.to_vector2 * self.class.size + offset
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end