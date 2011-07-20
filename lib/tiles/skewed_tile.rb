class SkewedTile
  extend Forwardable

  HEIGHT = 6
  WIDTH = 8
  SIZE = Vector2[WIDTH, HEIGHT]
  SKEW = WIDTH * 0.25
  
  include Helper

  def_delegator :@sprite, :position
  
  attr_reader :objects
  
  @@sprites = {}
  
  def initialize(sprite_position, grid_position, offset)
    grid_position = grid_position.to_vector2
    @sprite = sprite image_path("floor_tiles.png")
    @sprite.sheet_size = [8, 1]
    @sprite.sheet_pos = sprite_position
    @sprite.position = grid_position * SIZE
    @sprite.position += offset
    @sprite.x += grid_position.y * 3 # So they line up diagonally.
    @objects = []
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end