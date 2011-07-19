class Map
  include Helper
  
  attr_reader :grid_width, :grid_height 
  
  def to_rect; Rect.new(*@position, @grid_width * Tile::WIDTH, @grid_height * Tile::WIDTH); end

  def initialize(grid_size, position = [0, 0])
    @position = position.to_vector2
    @grid_width, @grid_height = *grid_size
    @tiles = Array.new(@grid_height) { Array.new(@grid_width) }
    @grid_height.times do |y|
      @grid_width.times do |x|
         @tiles[y][x] = Tile.new [x, y], position
      end
    end      
  end
  
  def tile_at_position(x, y)
    tile_size = Tile::WIDTH.to_f
    tile_at_grid((x / tile_size).to_i, (y / tile_size).to_i)
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
    tile_size = Tile::WIDTH.to_f
    top_left = view.center - view.size / 2
    y_range = ((top_left.y - tile_size) / tile_size).floor..((top_left.y + view.size.height) / tile_size).ceil
    x_range = ((top_left.x - tile_size) / tile_size).floor..((top_left.x + view.size.width) / tile_size).ceil
    y_range.each do |y|
      x_range.each do |x|       
        tile = tile_at_grid(x, y)
        yield tile if tile
      end
    end
  end 
  
  # List of all objects visible in the view.
  def visible_objects(view)
    objects = []
    each_visible(view) {|tile| objects += tile.objects }
    objects
  end
  
  # Draws all tiles (only) visible in the window.
  def draw_on(window)
    each_visible(window.view) {|tile| tile.draw_on window }
  end
  
  def add_object(object)
    tile_at_position(object.x, object.y).add_object(object)
  end
end

class Tile  
  WIDTH = HEIGHT = 8
  SIZE = Vector2[WIDTH, HEIGHT]
  
  include Helper
  
  attr_reader :objects
  
  @@sprites = {}
  
  def initialize(grid_position, offset)
    @sprite = sprite image_path("wall_tiles.png")
    @sprite.sheet_size = [4, 1]
    @sprite.sheet_pos = [rand(4), 0]
    @sprite.position = grid_position.to_vector2 * SIZE
    @sprite.position += offset
    @objects = []
  end
  
  def add_object(object)
    @objects << object
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end