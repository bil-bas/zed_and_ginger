require_relative "floor_tile"

class ExhaustFloor < FloorTile
  def initialize(grid_position, offset)
    super([0, 1], grid_position, offset)
  end
end