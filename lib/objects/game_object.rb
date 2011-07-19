class GameObject
  extend Forwardable
  include Helper
  
  def_delegators :@scene, :window, :frame_time
  def_delegators :@sprite, :x
  
  attr_reader :scene, :z

  SHADOW_RADIUS = 64
  SHADOW_WIDTH = SHADOW_RADIUS * 2
  
  def width; @sprite.sprite_width; end
  def pos; Vector2[x, y]; end
  alias_method :position, :pos 
  def pos=(pos)
    self.x, self.y = *pos
  end
  alias_method :position=, :pos=
  
  def x=(value)
    @sprite.x = @shadow.x = value
  end
  
  def y; @sprite.y + @z; end
  alias_method :z_order, :y
  
  def y=(value)
    @sprite.y = value - @z
    @shadow.y = y
    value
  end
  
  def z=(value)
    @sprite.y += @z - value
    @z = value
  end
  
  def initialize(scene, sprite, position) 
    @sprite = sprite
  
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
    Rect.new(x - width / 2, y - width / 2, width, width)
  end
  
  def draw_on(win)
    win.draw @sprite
  end
  
  def draw_shadow_on(win)
    win.draw @shadow
  end
end