class Map
  include Helper
  
  attr_reader :grid_width, :grid_height 
  
  def to_rect; Rect.new(*@position, @grid_width * Tile::WIDTH, @grid_height * Tile::WIDTH); end

  def initialize(data, position = [0, 0])
    @position = position.to_vector2
    @grid_width, @grid_height = data.first.length, data.size
    @tiles = Array.new(@grid_height) { Array.new(@grid_width) }
    data.each_with_index do |row, y|
      row.each_char.with_index do |char, x|
        sprite_pos = case char
                       when '-' # Std wall.
                         [0, 0]
                       when 'x' # Tech panel
                         [1, 0]
                       when 'o' # Round window
                         [2, 0]
                       when '#' # Square window
                         [3, 0]
                       else
                         raise "unknown wall tile: '#{char}'"
                     end

        @tiles[y][x] = Tile.new sprite_pos, [x, y], @position
      end
    end      
  end
  
  def tile_at_coordinate(coordinate)
    coordinate = coordinate.to_vector2.dup
    coordinate -= @position
    tile_size = Tile::WIDTH.to_f
    tile_at_grid(Vector2[(coordinate.x / tile_size).to_i, (coordinate.y / tile_size).to_i])
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
    tile_size = Tile::WIDTH.to_f
    top_left = view.center - view.size / 2
    y_range = ((top_left.y - tile_size) / tile_size).floor..((top_left.y + view.size.height) / tile_size).ceil
    x_range = ((top_left.x - tile_size) / tile_size).floor..((top_left.x + view.size.width) / tile_size).ceil
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

class Tile  
  WIDTH = HEIGHT = 8
  SIZE = Vector2[WIDTH, HEIGHT]
  
  include Helper
  
  def initialize(sprite_pos, grid_position, offset)
    @sprite = sprite image_path("wall_tiles.png")
    @sprite.sheet_size = [4, 1]
    @sprite.sheet_pos = sprite_pos
    @sprite.position = grid_position.to_vector2 * SIZE
    @sprite.position += offset
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end