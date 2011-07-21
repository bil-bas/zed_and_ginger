class GameObject
  extend Forwardable
  include Helper
  
  def_delegators :@scene, :window, :frame_time
  def_delegators :@position, :x, :y
  
  attr_reader :scene, :z

  SHADOW_RADIUS = 64
  SHADOW_WIDTH = SHADOW_RADIUS * 2

  def casts_shadow?; false; end
  def width; @sprite.sprite_width; end
  def pos; Vector2[x, y]; end
  alias_method :position, :pos 
  def position=(pos)
    self.x, self.y = *pos
  end
  alias_method :pos=, :position=
  
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
  
  def z=(value)
    @sprite.y += @z - value
    @z = value
  end
  
  def initialize(scene, sprite, position) 
    @sprite, @position = sprite, position.to_vector2
    @z = 0 
    
    create_shadow(position)
    
    scene.add_object(self)

    register(scene)   
  end

  def create_shadow(position)
    unless defined? @@shadow
      img = Image.new [SHADOW_WIDTH, SHADOW_WIDTH]
      center = img.size / 2
      img.map_with_pos! do |color, x, y|
        Color.new(0, 0, 0, (1 - (Vector2[x, y].distance(center) / SHADOW_RADIUS) ** 2) * 150)
      end
      @@shadow = sprite img
      @@shadow.origin = center
      @@shadow.scale = [0.06, 0.06]
    end
    
    @shadow = @@shadow.dup
    @shadow.position = position
  end
  
  def register(scene)
    self.event_runner = scene.event_runner
    @scene            = scene
  end
  
  def to_rect
    width = @sprite.sprite_width
    Rect.new(x - @sprite.origin.x, y - @sprite.origin.y, width, width)
  end
  
  def draw_on(win)
    win.draw @sprite
  end
  
  def draw_shadow_on(win)
    win.draw @shadow if casts_shadow?
  end

  def collide?(other)
    to_rect.collide? other
  end
end