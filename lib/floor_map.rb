%w[finish_floor glass_floor slow_floor standard_floor].each do |file_name|
  require_relative "tiles/#{file_name}"
end

%w[barrel board message_screen pacer rat slow_splat spring].each do |file_name|
  require_relative "objects/#{file_name}"
end

class FloorMap < Map
  def initialize(scene, tile_data, messages)
    @messages = messages
    super(FloorTile.size, scene, tile_data)
  end

  def next_message; @messages.shift; end

  def finish_line_x
    finish_tile = @tiles[0].find {|t| t.is_a? FinishFloor }
    finish_tile.x
  end

  def create_tile(char, grid_position)
    # Create the tile and, optionally, also create an object on that tile.
    tile_class, object_class = case char
      when '-' then [StandardFloor, nil]
      when '#' then [GlassFloor, nil]
      when 'f' then [FinishFloor, nil]
      when 's' then [SlowFloor, nil]
      when 'S' then [SlowFloor, SlowSplat]
      when '^' then [StandardFloor, Spring]
      when 'b' then [StandardFloor, Barrel]
      when 'B' then [StandardFloor, Board]
      when 'm' then [StandardFloor, MessageScreen]
      when 'p' then [StandardFloor, Pacer]
      when 'r' then [StandardFloor, Rat]
      else
       raise "Unknown floor tile: '#{char}'"
    end

    tile = tile_class.new grid_position, @position

    # Place an object into the center of the new tile.
    object_class.new(self, tile, (grid_position  + [0.5, 0.5]) * tile_size) if object_class

    tile
  end
end
