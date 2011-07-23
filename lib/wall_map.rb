require_relative "map"
require_relative "tiles/wall_tile"

class WallMap < Map
  def initialize(scene, data)
    super(WallTile.size, scene, data)
  end

  def create_tile(char, grid_position)
    sprite_pos = case char
                   when '-' then [0, 0] # Std wall.
                   when 'x' then [1, 0] # Tech panel
                   when 'o' then [2, 0] # Round window
                   when '#' then [3, 0] # Square window
                   when 'f' then [4, 0] # Finish line
                 else
                     raise "unknown wall tile: '#{char}'"
                 end

    WallTile.new sprite_pos, grid_position, position
  end
end