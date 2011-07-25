require_relative "floor_tile"

class LaserFloor < FloorTile
  def initialize(grid_position, offset)
    super([4, 0], grid_position, offset)
  end
end