%w[finish_floor glass_floor slow_floor standard_floor].each do |file_name|
  require_relative "tiles/#{file_name}"
end

%w[barrel board pacer rat spring].each do |file_name|
  require_relative "objects/#{file_name}"
end

class FloorMap < Map
  def initialize(scene, data, position = [0, 0])
    super(FloorTile.size, scene, data, position)
  end

  def finish_line_x
    finish_tile = @tiles[0].find {|t| t.is_a? FinishFloor }
    finish_tile.x
  end

  def create_tile(char, grid_position)
    # Create the tile and, optionally, also create an object on that tile.
    tile_class, object_class = case char
      when '.' then [StandardFloor, nil]
      when '_' then [GlassFloor, nil]
      when 's' then [SlowFloor, nil]
      when 'f' then [FinishFloor, nil]
      when '^' then [StandardFloor, Spring]
      when 'b' then [StandardFloor, Barrel]
      when 'B' then [StandardFloor, Board]
      when 'r' then [StandardFloor, Rat]
      when 'p' then [StandardFloor, Pacer]
      else
       raise "Unknown floor tile: '#{char}'"
    end

    tile = tile_class.new grid_position, @position

    # Place an object into the center of the new tile.
    object_class.new(self, (grid_position  + [0.5, 0.5]) * tile_size) if object_class

    tile
  end
end
