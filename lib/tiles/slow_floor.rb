require_relative "floor_tile"

class SlowFloor < FloorTile
  SHADER_PIXELS_PER_PIXEL = 1

  def self.shader_time=(time); @@shader[:time] = time if defined? @@shader; end

  def speed; 0.25; end

  def initialize(grid_position, offset)
    super([2, 0], grid_position, offset)

    unless defined? @@shader
      @@shader = Shader.new frag: shader_path("slime.frag")
      @@shader[:pixel_width] = 1.0 / (@sprite.image.width * SHADER_PIXELS_PER_PIXEL)
      @@shader[:pixel_height] = 1.0 / (@sprite.image.height * SHADER_PIXELS_PER_PIXEL)
      @@shader[:interference_amplitude] = 10
      @@shader[:frequency_amplitude] = 0.8
    end

    @shader_offset = Vector2[grid_position.x, grid_position.y] / @sprite.sheet_size

    @sprite.shader = @@shader
  end

  def draw_on(win)
    @sprite.shader[:offset] = @shader_offset
    super
  end
end