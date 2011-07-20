require_relative "floor_tile"

class SlowFloor < FloorTile
  def speed; 0.25; end

  def initialize(grid_position, offset)
    super([2, 0], grid_position, offset)
  end
end