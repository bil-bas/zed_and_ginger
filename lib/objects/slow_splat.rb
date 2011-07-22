require_relative "dynamic_object"
require_relative "../tiles/slow_floor.rb"

class SlowSplat < DynamicObject
  def casts_shadow?; false; end

  def self.shader_time=(time); @@shader[:time] = time if defined? @@shader; end

  def initialize(map, tile, position)
    sprite = sprite image_path("slow_splat.png")
    sprite.sheet_size = [4, 1]
    sprite.sheet_pos = [rand(4), 0]
    sprite.origin = Vector2[sprite.sprite_width / 2 + 1.5, sprite.sprite_height]

    super(map.scene, sprite, position)

    @sprite.y = 0 # Move it up next to the wall.

    unless defined? @@shader
      @@shader = Shader.new frag: shader_path("slime.frag")
      @@shader[:pixel_width] = 1.0 / (@sprite.image.width * SlowFloor::SHADER_PIXELS_PER_PIXEL)
      @@shader[:pixel_height] = 1.0 / (@sprite.image.height * SlowFloor::SHADER_PIXELS_PER_PIXEL)
      @@shader[:interference_amplitude] = SlowFloor::INTERFERENCE_AMPLITUDE
      @@shader[:frequency_amplitude] =  SlowFloor::FREQUENCY_AMPLITUDE
    end

    @sprite.shader = @@shader

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