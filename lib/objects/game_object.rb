class GameObject
  include Helper
  extend Forwardable
  include Log
  include Registers

  def_delegators :@position, :x, :y
  def_delegators :@sprite, :angle, :angle=,
                           :color, :color=,
                           :sheet_pos, :sheet_pos=,
                           :sprite_width, :sprite_height,
                           :origin, :origin=
  
  attr_reader :scene, :z

  SHADOW_RADIUS = 64
  SHADOW_WIDTH = SHADOW_RADIUS * 2

=begin
Too slow to use in the real system, so saved to a file.
  class << self
    # Generates the shadow_sprite from an image.
    def shadow_image
      unless defined? @shadow_image
        @shadow_image = Image.new [SHADOW_WIDTH, SHADOW_WIDTH]
        center = @shadow_image.size / 2
        @shadow_image.map_with_pos! do |color, x, y|
          Color.new(0, 0, 0, (1 - (Vector2[x, y].distance(center) / SHADOW_RADIUS) ** 2) * 150)
        end
      end

      @shadow_image
    end
  end
=end

  def casts_shadow?; false; end
  def width; @sprite.sprite_width; end
  def pos; Vector2[x, y]; end
  alias_method :position, :pos 
  def position=(pos)
    self.x, self.y = *pos
  end
  alias_method :pos=, :position=

  def distance(other)
    pos.distance(other.pos)
  end
  
  def x=(value)
    @position.x = value
    @sprite.x = @shadow.x = value + @position.y / 2.0

    value
  end

  def z_order; @position.y + @z; end
  
  def y=(value)
    change_y = value - y

    @position.y = value

    @sprite.y = value - @z
    @sprite.x += change_y / 2.0

    @shadow.y = y
    @shadow.x += change_y / 2.0

    value
  end

  def alpha=(alpha)
    color = @sprite.color
    color.alpha = alpha
    @sprite.color = color
  end

  def z=(value)
    @sprite.y += @z - value
    @z = value
  end
  
  def initialize(scene, sprite, position) 
    @sprite = sprite
    @position = Vector2[0, 0] # Will be set properly later.
    @z = 0

    @shadow = sprite image_path("shadow.png")
    @shadow.origin = @shadow.image.size / 2
    @shadow.scale = [0.06, 0.06]
    @shadow.position = position

    @animations = []
    
    scene.add_object(self)

    register(scene)

    create_debug_shapes if DEVELOPMENT_MODE

    self.position = position
  end

  def to_rect
    half_width = @sprite.sprite_width
    Rect.new(*(@position - [half_width, half_width]), width, width)
  end
  
  def draw_on(win)
    win.draw @sprite
  end

  def create_debug_shapes
    @collision_rect = Polygon.rectangle(to_rect)
    @collision_rect.outlined = true
    @collision_rect.outline = Color.new(255, 0, 0, 100)
    @collision_rect.outline_width = 0.25
    @collision_rect.filled = false

    @origin = Polygon.rectangle([*position - [0.25, 0.25], 0.5, 0.5], Color.new(0, 0, 255, 100))
  end

  def update
    @animations.each(&:update)

    if DEVELOPMENT_MODE
      @collision_rect.matrix = nil
      @collision_rect.pos = @sprite.pos
      @collision_rect.skew_x(0.5)

      @origin.matrix = nil
      @origin.pos = @sprite.pos - [0.25, 0.25]
      @origin.skew_x(0.5)
    end
  end

  def draw_debug_on(win)
    win.draw @collision_rect
    win.draw @origin
  end
  
  def draw_shadow_on(win)
    win.draw @shadow if casts_shadow?
  end

  def collide?(other)
    to_rect.collide? other
  end

  # Explode a sprite into a stack of pixel-sized particles.
  # Setting :color will override the colour at the particular pixel when creating the particle.
  def explode_pixels(options = {})
    image = @sprite.image

    # Find the position of the top left of the sprite in world coordinates. The 0.5s are because particles are centered in the pixel.
    scale_x, scale_y = *@sprite.scale
    world_x, world_y, world_z = self.x - (@sprite.origin.width - 0.5) * scale_x, self.y, self.z + (@sprite.origin.height - 0.5) * scale_y

    if @sprite.uses_sprite_sheet?
      # Assume a 1-pixel transparent edge that we can ignore.
      rect = @sprite.sub_rect
      world_x += 1
      world_z -= 1
      sprite_offset_x, sprite_offset_y, width, height = rect.x + 1, rect.y + 1, rect.width.to_i - 2, rect.height.to_i - 2
    else
      width, height = image.width.to_i, image.height.to_i
      sprite_offset_x, sprite_offset_y = 0, 0
    end

    width.times do |x|
      height.times do |y|
        color = image[sprite_offset_x + x, sprite_offset_y + y]
        unless color.alpha < 20
          scene.create_particle([world_x + x * scale_x, world_y, world_z - y * scale_y], { color: color }.merge!(options))
        end
      end
    end
  end
end