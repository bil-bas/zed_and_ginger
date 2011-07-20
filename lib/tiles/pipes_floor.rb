require_relative "floor_tile"

class PipesFloor < FloorTile
  def initialize(grid_position, offset)
    super([4, 0], grid_position, offset)
  end
end