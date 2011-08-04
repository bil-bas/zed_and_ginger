class Particle
  extend Forwardable
  include Helper

  GRAVITY = 8.0

  attr_reader :z

  def z_order; @polygon.y + @z; end

  def draw_shadow_on(win); ; end # NOP
  def draw_debug_on(win); ; end # NOP

  def z=(value)
    @polygon.y += @z - value
    @z = value
  end

  def x=(value)
    @x = value
    @polygon.x = value + @y / 2.0

    value
  end

  def z_order; @y + @z; end

  def y=(value)
    change_y = value - @y

    @y = value

    @polygon.y = value - @z
    @polygon.x += change_y / 2.0

    value
  end

  def initialize(generator, options = {})
    @polygon = Polygon.rectangle([-0.5, -0.5, 1, 1])
    @generator = generator
  end

  def init(position, options = {})
    options = {
        gravity: 1.0,
        glow: false,
        color: Color.white,
        velocity: [0, 0, 0],
        random_velocity: [0, 0, 0], # [2, 2, 2] will somewhere from [-2, -2, -2] to [2, 2, 2]
        fade_duration: Float::INFINITY, # Time before the particle fades out.
        scale: [1, 1],
    }.merge! options

    @color = options[:color].dup
    @alpha = @color.alpha.to_f
    @polygon.color = @color
    @fade_speed = @alpha / options[:fade_duration]

    @gravity = GRAVITY * options[:gravity]
    @x = @y = @z = 0
    @polygon.pos = [0, 0]
    self.x, self.y, self.z = position

    @polygon.scale = options[:scale]

    @polygon.blend_mode = options[:glow] ? :add : :alpha

    @velocity_x, @velocity_y, @velocity_z = options[:velocity]
    random_vx, random_vy, random_vz = options[:random_velocity]
    @velocity_x += (rand() * random_vx * 2) - random_vx if random_vx > 0
    @velocity_y += (rand() * random_vy * 2) - random_vy if random_vy > 0
    @velocity_z += (rand() * random_vz * 2) - random_vz if random_vz > 0
  end

  def update(duration)
    # Physics
    self.x = @x + @velocity_x * duration
    self.y = @y + @velocity_y * duration
    @velocity_z -= @gravity * duration
    self.z = @z + @velocity_z * duration

    # Fade.
    @alpha -= @fade_speed * duration

    if @z < 0 or @z > 100 or @y < 0 or @y > 30 or @alpha <= 10
      @generator.destroy(self)
    else
      @color.alpha = @alpha
      @polygon.color = @color
    end
  end

  def draw_on(win)
    win.draw @polygon
  end
end