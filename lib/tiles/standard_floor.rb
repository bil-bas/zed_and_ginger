require_relative "floor_tile"

class StandardFloor < FloorTile
  def initialize(grid_position, offset)
    super([0, 0], grid_position, offset)
  end
end