require_relative "floor_tile"

# Prevents the player from jumping.
class GlueFloor < FloorTile
  SHADER_PIXELS_PER_PIXEL = 1
  INTERFERENCE_AMPLITUDE = 20

  class << self
    def shader
      unless defined? @shader
        @shader = Shader.new frag: StringIO.new(read_shader("glue.frag"))
        @shader[:interference_amplitude] = INTERFERENCE_AMPLITUDE
        @shader[:pixel_width] = 1.0 / FloorTile::IMAGE_SIZE.width
        @shader[:pixel_height] = 1.0 / FloorTile::IMAGE_SIZE.height
      end

      @shader
    end

    def shader_time=(time)
      @shader[:time] = time if defined? @shader
    end
  end

  def initialize(grid_position, offset)
    super([1, 2], grid_position, offset)

    @sprite.shader = self.class.shader

    @shader_offset = grid_position / @sprite.sheet_size
    @shader_offset.y *= -1.0
  end

  def draw_on(win)
    @sprite.shader[:offset] = @shader_offset
    super
  end
end