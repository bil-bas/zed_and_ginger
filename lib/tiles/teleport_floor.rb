require_relative "floor_tile"

class TeleportFloor < FloorTile
  def initialize(grid_position, offset)
    super([6, 0], grid_position, offset)
  end
end

class TeleportBackwardsFloor < FloorTile
  def initialize(grid_position, offset)
    super([7, 0], grid_position, offset)
  end
end