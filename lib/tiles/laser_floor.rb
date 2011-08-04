require_relative "floor_tile"

class LaserFloor < FloorTile
  def initialize(grid_position, offset)
    grid_position = grid_position.to_vector2
    sheet_pos = [1, 3].include?(grid_position.y) ? [4, 0] : [0, 2]
    super(sheet_pos, grid_position, offset)
  end
end