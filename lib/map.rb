class Map
  include Helper
  
  attr_reader :grid_width, :grid_height 
  
  def to_rect; Rect.new(0, 0, @grid_width * Tile::SIZE, @grid_height * Tile::SIZE); end

  def initialize(grid_width, grid_height)
    @grid_width, @grid_height = grid_width, grid_height
    @tiles = Array.new(@grid_height) { Array.new(@grid_width) }
    @grid_height.times do |y|
      @grid_width.times do |x|
         @tiles[y][x] = [Tile::Grass, Tile::Dirt, Tile::Sand].sample.new [x, y]
      end
    end      
  end
  
  def tile_at_position(x, y)
    tile_size = Tile::SIZE.to_f
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
    tile_size = Tile::SIZE.to_f
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
  class Grass < Tile
    def color; Color.new(0, 120, 0); end
  end
  
  class Dirt < Tile
    def color; Color.new(100, 25, 0); end
  end
  
  class Sand < Tile
    def color; Color.new(200, 180, 50); end
  end
  
  SIZE = 8
  
  include Helper
  
  attr_reader :objects
  
  @@sprites = {}
  
  def initialize(grid_position)
    unless @@sprites.has_key? self.class
      img = Image.new [SIZE, SIZE]
      image_target(img) {|target| target.clear color }
      @@sprites[self.class] = sprite img
    end
    
    @sprite = @@sprites[self.class].dup
    @sprite.position = grid_position.to_vector2 * SIZE
    @objects = []
  end
  
  def add_object(object)
    @objects << object
  end
  
  def draw_on(window)
    window.draw @sprite
  end
end