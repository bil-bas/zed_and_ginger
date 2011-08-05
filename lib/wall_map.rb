require_relative "map"
require_relative "tiles/wall_tile"

class WallMap < Map
  def initialize(scene, data, default_tile)
    super(WallTile.size, scene, data, default_tile)
  end

  def create_tile(char, grid_position)
    sprite_pos = case char
                   when '-' then default_tile # Std wall.
                   when 'x' then [5, 1] # Tech panel
                   when 'o' then [6, 1] # Round window
                   when '#' then [7, 1] # Square window
                   when 'f' then [5, 0] # Finish line
                 else
                     raise "unknown wall tile: '#{char}'"
                 end

    WallTile.new sprite_pos, grid_position, position
  end
end