class Maps
  extend Forwardable

  def_delegators :@floor, :finish_line_x

  attr_reader :floor, :wall, :height_factor, :time_limit

  public
  def initialize(scene, level_number, player_name)
    level_data = YAML::load_file(File.expand_path(File.join(EXTRACT_PATH, "config/levels/#{level_number}.yml")))

    wall_tiles = level_data['wall']['tiles'].split("\n").map(&:strip)
    floor_tiles = level_data['floor']['tiles'].split("\n").map(&:strip)

    # Ensure that all floor and wall tiles are of the correct length.
    raise "Bad map data for #{level_number}" unless (wall_tiles + floor_tiles).map {|row| row.length}.uniq.size == 1

    @wall = WallMap.new scene, wall_tiles, level_data['wall']['default_tile']
    @floor = FloorMap.new scene, floor_tiles,
                              Kernel::const_get(level_data['floor']['default_tile'].to_sym),
                              messages: level_data['messages'], player_name: player_name

    @height_factor = (@wall.to_rect.height.to_f + @floor.to_rect.height.to_f)  / GAME_RESOLUTION.height

    @time_limit = level_data['time_limit']
  end
end
