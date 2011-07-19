require_relative "floor_tile"

class SlowFloor < FloorTile
  def speed; 0.25; end

  def initialize(grid_position, offset)
    super([1, 0], grid_position, offset)
  end
end