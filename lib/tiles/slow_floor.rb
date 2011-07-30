require_relative "floor_tile"

class SlowFloor < FloorTile
  SHADER_PIXELS_PER_PIXEL = 1
  FREQUENCY_AMPLITUDE = 0.8
  INTERFERENCE_AMPLITUDE = 10
  IMAGE_SIZE = Vector2[64, 64]

  class << self
    def shader
      unless defined? @shader
        @shader = Shader.new frag: StringIO.new(read_shader("slime.frag"))
        @shader[:interference_amplitude] = INTERFERENCE_AMPLITUDE
        @shader[:frequency_amplitude] = FREQUENCY_AMPLITUDE
        @shader[:pixel_width] = 1.0 / IMAGE_SIZE.width
        @shader[:pixel_height] = 1.0 / IMAGE_SIZE.height
      end

      @shader
    end

    def shader_time=(time)
      @shader[:time] = time if defined? @shader
    end
  end

  def speed; 0.25; end

  def initialize(grid_position, offset)
    super([2, 0], grid_position, offset)

    @sprite.shader = self.class.shader

    @shader_offset = grid_position / @sprite.sheet_size
  end

  def draw_on(win)
    @sprite.shader[:offset] = @shader_offset
    super
  end
end