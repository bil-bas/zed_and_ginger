require_relative "game_object"
require_relative "../tiles/slow_floor.rb"

class SlowSplat < GameObject
  IMAGE_SIZE = Vector2[32, 8]

  class << self
    def shader
      unless defined? @shader
        @shader = Shader.new frag: StringIO.new(read_shader("slime.frag"))
        @shader[:pixel_width] = 1.0 / IMAGE_SIZE.width
        @shader[:pixel_height] = 1.0 / IMAGE_SIZE.height
        @shader[:interference_amplitude] = SlowFloor::INTERFERENCE_AMPLITUDE
        @shader[:frequency_amplitude] =  SlowFloor::FREQUENCY_AMPLITUDE
      end

      @shader
    end

    def shader_time=(time)
      @shader[:time] = time if defined? @shader
    end
  end

  def casts_shadow?; false; end

  def initialize(map, tile, position)
    sprite = sprite image_path("slow_splat.png")
    sprite.sheet_size = [4, 1]
    sprite.sheet_pos = [rand(4), 0]
    sprite.scale_x = -sprite.scale_x if rand() < 0.5
    sprite.origin = Vector2[sprite.sprite_width / 2, sprite.sprite_height]

    super(map.scene, sprite, position)

    @sprite.y = 0 # Move it up next to the wall.
    @sprite.x -= 1.5

    @sprite.shader = self.class.shader

    @shader_offset = Vector2[tile.grid_position.x, tile.grid_position.y - 1] / @sprite.sheet_size
  end

  # Doesn't move or anything like that.
  def update
  end

  def draw_on(win)
    @sprite.shader[:offset] = @shader_offset

    super
  end
end