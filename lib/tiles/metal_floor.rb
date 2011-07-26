require_relative "floor_tile"

class MetalFloor < FloorTile
  def initialize(grid_position, offset)
    super([1, 1], grid_position, offset)
  end
end