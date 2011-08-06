# Tests shared by both floor and wall maps
def map_shared_tests
  asserts(:position).equals Vector2[0, 0]
  asserts(:grid_width).equals { tile_rows.first.size }
  asserts(:grid_height).equals { tile_rows.size }

  asserts("correct number of tiles created") { visible_tiles(topic, world_view).size == tile_rows.join.length }
  asserts("all rows of equal size") { tile_rows.map(&:length).uniq.size == 1 }
  asserts("finish line at correct distance from end") { tile_rows.all? {|row| row.rindex("f") == row.size - 11 } }
  asserts("finish line not found before the end") { tile_rows.all? {|row| row.index("f") == row.size - 11 } }
end

context Maps do
  helper(:column_view) { View.new [-8, 20], [4, 40] }
  helper(:world_view) { View.new [10000, 8], [20000, 200] }

  helper(:visible_tiles) do |topic, view|
    tiles = []
    topic.each_visible(view) {|t| tiles << t }
    tiles
  end

  helper(:scene) do
    @scene_class ||= Class.new do
      def add_object(object); end
      def event_runner
        @event_runner ||= DSL::EventRunner.new
      end
      def user_data
        # Only load user data once.
        @user_data ||= UserData.new
      end
    end

    @scene_class.new
  end

  helper :map do |level_number|
    $maps ||= {}
    # Only load maps in once, since they are very costly (0.5s or so).
    unless $maps[level_number]
      t = Time.now
      $maps[level_number] = Maps.new(scene, level_number, :zed)
      elapsed = Time.now - t
      puts "-------> level #{level_number} loaded in #{elapsed}s"
    end
    $maps[level_number]
  end

  helper(:tile_rows) { data['tiles'].split("\n") }

  Dir["config/levels/*.yml"].each do |file|
    file =~ /(\d+)\.yml/
    level_number = $1

    # Have to put this out here so we catch the error in a test.
    asserts("level #{level_number} loads without error") { map level_number }

    context level_number do
      setup { map level_number }

      asserts("floor and wall of equal length") { topic.wall.grid_width == topic.floor.grid_width  }

      context "floor" do
        helper(:data) { @floor_tile_data ||= YAML::load_file(file)['floor'] }
        helper(:default_tile) { Kernel::const_get data['default_tile'] }

        setup { topic.floor }

        map_shared_tests

        asserts_topic.kind_of FloorMap
        asserts("default tile inherits from FloorTile") { default_tile.ancestors.include? FloorTile }
        asserts(:to_rect).equals { Rect.new(0, 0, tile_rows.first.size * FloorTile.width, 5 * FloorTile.height) }
        asserts("number of rows") { visible_tiles(topic, column_view) }.size 5
        asserts("tiles are FloorTiles") { visible_tiles(topic, world_view).all? {|t| t.is_a? FloorTile } }
      end

      context "wall" do
        helper(:data) { @wall_tile_data ||= YAML::load_file(file)['wall'] }
        helper(:default_tile) { data['default_tile'] }

        setup { topic.wall }

        map_shared_tests

        asserts_topic.kind_of WallMap
        asserts(:to_rect).equals { Rect.new(0, 0, tile_rows.first.size * WallTile.width, 3 * WallTile.height) }
        asserts(:default_tile).kind_of Array
        asserts(:default_tile).size 2
        asserts("number of rows") { visible_tiles(topic, column_view) }.size 3
        asserts("tiles are WallTiles") { visible_tiles(topic, world_view).all? {|t| t.is_a? WallTile } }
      end
    end
  end
end
