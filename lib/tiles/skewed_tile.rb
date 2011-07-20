module Ray
  class Matrix
    class << self
      def skew_x(skew)
        new [
            1, skew, 0, 0,
            0, 1,    0, 0,
            0, 0,    1, 0,
            0, 0,    0, 1,
        ]
      end

      def skew_y(skew)
        new [
            1,    0, 0, 0,
            skew, 1, 0, 0,
            0,    0, 1, 0,
            0,    0, 0, 1,
        ]
      end
    end
  end

  class Drawable
    def skew_x(skew)
      self.matrix = matrix.multiply_by! Matrix.skew_x(skew)
    end

    def skew_y(skew)
      self.matrix = matrix.multiply_by! Matrix.skew_y(skew)
    end
  end
end

class SkewedTile
  extend Forwardable

  HEIGHT = 6
  WIDTH = 8
  SIZE = Vector2[WIDTH, HEIGHT]

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
    @sprite.x += grid_position.y * HEIGHT / 2 # So they line up diagonally.
    @sprite.skew_x(0.5)
    @objects = []
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end