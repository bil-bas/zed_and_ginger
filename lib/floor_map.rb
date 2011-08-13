%w[checkered dirt exhaust finish glass glue laser metal slow spring teleport].each do |file_name|
  require_relative "tiles/#{file_name}_floor"
end

%w[barrel board conveyors fire_exhaust fly_trap laser_beam message_screen mine pacer rat slow_splat speed_pill spring teleporter].each do |file_name|
  require_relative "objects/#{file_name}"
end

class FloorMap < Map
  def initialize(scene, tile_data, default_tile, options = {})
    options = {
        messages: [],
    }.merge! options

    @messages = options[:messages]

    if options[:player_name]
      @messages.map! do |message|
        message.gsub(/%.*%/) do |replacement|
          replacement =~ /%(.*)%/
          key_used = scene.user_data.player_control(options[:player_name], $1.to_sym)
          display_for_key(key_used)
        end
      end
    end

    super(FloorTile.size, scene, tile_data, default_tile)
  end

  def next_message; @messages.shift; end

  def finish_line_x
    finish_tile = @tiles[0].find {|t| t.is_a? FinishFloor }
    finish_tile.x
  end

  def create_tile(char, grid_position)
    # Create the tile and, optionally, also create an object on that tile.
    tile_class, object_class = case char
      when '-' then [default_tile, nil]
      when '#' then [GlassFloor, nil]
      when 'f' then [FinishFloor, nil]
      when 'd' then [DirtFloor, nil]
      when 'm' then [MetalFloor, nil]

      when '\\' then [default_tile, RightConveyor]
      when '/' then [default_tile, LeftConveyor]
      when '>' then [default_tile, ForwardConveyor]
      when '<' then [default_tile, BackwardConveyor]

      when 'l' then [LaserFloor, LaserBeam]
      when 'L' then [LaserFloor, LaserBeamShifted]

      when 'e' then [ExhaustFloor, FireExhaust]
      when 'E' then [ExhaustFloor, FireExhaustShifted]
      when 't' then [DirtFloor, FlyTrap]
      when 'g' then [GlueFloor, nil]
      when 'h' then [default_tile, SpeedPill]

      when '{' then [TeleportFloor, Teleporter]
      when '}' then [TeleportBackwardsFloor, TeleporterBackwards]

      when 's'
        if grid_position.y == 0 and rand() < 0.5
          [SlowFloor, SlowSplat]
        else
          [SlowFloor, nil]
        end

      when '^' then [SpringFloor, Spring]
      when 'b' then [default_tile, Barrel]
      when 'B' then [default_tile, Board]
      when 'M' then [default_tile, MessageScreen]
      when 'X' then [default_tile, Mine]
      when 'p' then [default_tile, PacerLow]
      when 'P' then [default_tile, PacerHigh]
      when 'r' then [default_tile, Rat]
      else
        raise "Unknown floor tile: '#{char}'"
    end

    tile = tile_class.new grid_position, @position

    # Place an object into the center of the new tile.
    object_class.new(self, tile, (grid_position  + [0.5, 0.5]) * tile_size) if object_class

    tile
  end
end
