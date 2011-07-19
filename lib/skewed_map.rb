class SkewedMap
  include Helper
  
  attr_reader :grid_width, :grid_height 
  
  def to_rect; Rect.new(*@position, @grid_width * SkewedTile::WIDTH, @grid_height * SkewedTile::HEIGHT); end

  def initialize(scene, data, position = [0, 0])
    @position = position.to_vector2
    @grid_width, @grid_height = data.first.length, data.size
    @tiles = Array.new(@grid_height) { Array.new(@grid_width) }

    data.each_with_index do |row, y|
      row.each_char.with_index do |char, x|
        tile_class, object_class = case char
          when '.' # Std floor.
            [BasicFloor, nil]
          when 's' # Slow.
            [SlowFloor, nil]
          when '=' # Lower edge.
            [PipesFloor, nil]
          when '^' # Spring.
            [BasicFloor, Spring]
          else
           raise "unknown wall tile: '#{char}'"
        end

        tile = tile_class.new [x, y], @position
        @tiles[y][x] = tile
        object_class.new(scene, tile.position + Vector2[SkewedTile::WIDTH / 2, SkewedTile::HEIGHT / 2]) if object_class
      end
    end
  end
  
  def tile_at_coordinate(coordinate)
    coordinate = coordinate.to_vector2.dup
    coordinate -= @position
    tile_width, tile_height = SkewedTile::WIDTH.to_f, SkewedTile::HEIGHT.to_f
    horizontal_offset = - coordinate.y / 2 # Caused by the skew
    tile_at_grid(Vector2[((coordinate.x + horizontal_offset) / tile_width).to_i, (coordinate.y / tile_height).to_i])
  end
  
  def tile_at_grid(grid_position)
    grid_position = grid_position.to_vector2
    if grid_position.x.between?(0, @grid_width - 1) and grid_position.y.between?(0, @grid_height - 1)
      @tiles[grid_position.y][grid_position.x]
    else
      nil
    end
  end
  
  # Yields every tile visible to the view.
  def each_visible(view, &block)
    tile_width, tile_height = SkewedTile::WIDTH.to_f, SkewedTile::HEIGHT.to_f
    top_left = view.center - view.size / 2
    y_range = ((top_left.y - tile_height) / tile_height).floor..((top_left.y + view.size.height) / tile_height).ceil
    x_range = ((top_left.x - tile_width * @grid_height) / tile_width).floor..((top_left.x + view.size.width) / tile_width).ceil
    y_range.each do |y|
      x_range.each do |x|       
        tile = tile_at_grid([x, y])
        yield tile if tile
      end
    end
  end
  
  # Draws all tiles (only) visible in the window.
  def draw_on(window)
    each_visible(window.view) {|tile| tile.draw_on window }
  end
end

class SkewedTile
  extend Forwardable

  HEIGHT = 6
  WIDTH = 8
  SIZE = Vector2[WIDTH, HEIGHT]
  SKEW = WIDTH * 0.25
  
  include Helper

  def_delegator :@sprite, :position
  
  attr_reader :objects
  
  @@sprites = {}
  
  def initialize(sprite_position, grid_position, offset)
    @sprite = sprite image_path("floor_tiles.png")
    @sprite.sheet_size = [4, 1]
    @sprite.sheet_pos = sprite_position
    @sprite.position = grid_position.to_vector2 * SIZE
    @sprite.position += offset
    @sprite.x += grid_position[1] * 3 # So they line up diagonally.
    @objects = []
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end

class FloorTile < SkewedTile
  def speed; 1.0; end
end

class BasicFloor < FloorTile
  def initialize(grid_position, offset)
    super([0, 0], grid_position, offset)
  end
end

class SlowFloor < FloorTile
  def speed; 0.25; end

  def initialize(grid_position, offset)
    super([1, 0], grid_position, offset)
  end
end

class PipesFloor < FloorTile
  def initialize(grid_position, offset)
    super([3, 0], grid_position, offset)
  end
end