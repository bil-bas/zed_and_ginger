require_relative "floor_tile"

class GlassFloor < FloorTile
  def initialize(grid_position, offset)
    super([2, 0], grid_position, offset)
  end
end