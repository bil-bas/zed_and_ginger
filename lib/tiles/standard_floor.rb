require_relative "floor_tile"

class StandardFloor < FloorTile
  def initialize(grid_position, offset)
    grid_position = grid_position.to_vector2
    index = (((grid_position.x + grid_position.y) % 2) == 1) ? 0 : 1
    super([index, 0], grid_position, offset)
  end
end