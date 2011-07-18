class GameObject
  extend Forwardable
  include Helper
  
  def_delegators :@scene, :window
  def_delegators :@sprite, :x
  
  attr_reader :scene, :z  
  
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
      img = Image.new [32, 32]
      center = img.size / 2
      img.map_with_pos! do |color, x, y|
        Color.new(0, 0, 0, 120 - Vector2[x, y].distance(center) * 10)
      end
      @@shadow = sprite img     
      @@shadow.origin = [16, 16]
      @@shadow.scale = [0.5, 0.5]      
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