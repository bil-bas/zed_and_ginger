class SkewedMap
  include Helper
  
  attr_reader :grid_width, :grid_height 
  
  def to_rect; Rect.new(*@position, @grid_width * SkewedTile::WIDTH, @grid_height * SkewedTile::HEIGHT); end

  def initialize(grid_size, position = [0, 0])
    @position = position.to_vector2
    @grid_width, @grid_height = *grid_size
    @tiles = Array.new(@grid_height) { Array.new(@grid_width) }
    @grid_height.times do |y|
      @grid_width.times do |x|
         @tiles[y][x] = [SkewedTile].sample.new [x, y], position
      end
    end      
  end
  
  def tile_at_position(x, y)
    tile_width, tile_height = SkewedTile::WIDTH.to_f, SkewedTile::HEIGHT.to_f
    tile_at_grid((x / tile_width).to_i, (y / tile_height).to_i)
  end
  
  def tile_at_grid(x, y)
    if x.between?(0, @grid_width - 1) and y.between?(0, @grid_height - 1)
      @tiles[y][x]
    else
      nil
    end
  end
  
  # Yields every tile visible to the view.
  def each_visible(view, &block)
    tile_width, tile_height = SkewedTile::WIDTH.to_f, SkewedTile::HEIGHT.to_f
    top_left = view.center - view.size / 2
    y_range = ((top_left.y - tile_height) / tile_height).floor..((top_left.y + view.size.height) / tile_height).ceil
    x_range = ((top_left.x - tile_width) / tile_width).floor..((top_left.x + view.size.width) / tile_width).ceil
    y_range.each do |y|
      x_range.each do |x|       
        tile = tile_at_grid(x, y)
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
  HEIGHT = 6
  WIDTH = 8
  SIZE = Vector2[WIDTH, HEIGHT]
  SKEW = WIDTH * 0.25
  
  include Helper
  
  attr_reader :objects
  
  @@sprites = {}
  
  def initialize(grid_position, offset)
    @sprite = sprite image_path("floor_tiles.png")
    @sprite.sheet_size = [4, 1]
    @sprite.sheet_pos = [rand(4), 0]
    @sprite.position = grid_position.to_vector2 * SIZE
    @sprite.position += offset
    @sprite.x += grid_position[1] * 3 # So they line up diagonally.
    @objects = []
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end