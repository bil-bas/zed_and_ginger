class Particle
  extend Forwardable
  include Helper

  GRAVITY = 8.0 * 9.81 # Assuming an 8-pixel square tile is 1m square.
  AUTO_FADE_DURATION = 5.0
  AUTO_FADE_SPEED = 255.0 / AUTO_FADE_DURATION

  def z_order; @y; end

  def draw_shadow_on(win); ; end # NOP
  def draw_debug_on(win); ; end # NOP

  def initialize(generator, options = {})
    size = 0.75
    @polygon = Polygon.rectangle([-size * 0.5, -size * 0.5, size, size])
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
    @x, @y, @z = position
    @polygon.pos = [@x + @y, @y - @z]

    @polygon.scale = options[:scale]

    @polygon.blend_mode = options[:glow] ? :add : :alpha

    @velocity_x, @velocity_y, @velocity_z = options[:velocity]
    random_vx, random_vy, random_vz = options[:random_velocity]
    @velocity_x += (rand() * random_vx * 2) - random_vx if random_vx > 0
    @velocity_y += (rand() * random_vy * 2) - random_vy if random_vy > 0
    @velocity_z += (rand() * random_vz * 2) - random_vz if random_vz > 0
  end

  def update(duration)
    if @z < 0
      # Hit the ground. Fade out slowly, unless a fade is already set.
      @z = 0
      @polygon.y = @y
      @fade_speed = [AUTO_FADE_SPEED, @fade_speed].max
    elsif @z > 0
      # Physics
      @x += @velocity_x * duration
      @y = [[@y + @velocity_y * duration, 0].max, 30].min # stop it going through a wall (visible or invisible).

      # Interpolate gravity's effect.
      velocity_change = @gravity * duration
      @velocity_z -= velocity_change
      @z += (@velocity_z - velocity_change * 0.5) * duration

      @polygon.x = @x + @y / 2.0
      @polygon.y = @y - @z
    end
    # Else z == 0, so just fade.

    # Fade.
    @alpha -= @fade_speed * duration

    if @alpha < 10
      @generator.destroy(self)
    elsif @fade_speed > 0
      @color.alpha = @alpha
      @polygon.color = @color
    end
  end

  def draw_on(win)
    win.draw @polygon
  end
end