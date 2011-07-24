require_relative "dynamic_object"

class Teleporter < DynamicObject
  SKEW = 2
  FREQUENCY_AMPLITUDE = 4
  INTERFERENCE_AMPLITUDE = 2

  def casts_shadow?; false; end

  def self.shader_time=(time); @@shader[:time] = time if defined? @@shader; end

  def to_rect; Rect.new(*(@position - [0, 3]), 0, 6) end

  def initialize(map, tile, position)
    @@image ||= Image.new([8, 8])
    sprite = sprite @@image
    sprite.origin = Vector2[sprite.image.width - 3, sprite.image.height * 1.5]

    super(map.scene, sprite, position)

    unless defined? @@shader
      @@shader = Shader.new frag: shader_path("teleporter.frag")
      @@shader[:pixel_width] = 1.0 / @sprite.image.width
      @@shader[:pixel_height] = 1.0 / @sprite.image.height
      @@shader[:interference_amplitude] = INTERFERENCE_AMPLITUDE
      @@shader[:frequency_amplitude] =  FREQUENCY_AMPLITUDE
    end

    @sprite.shader = @@shader

    @shader_offset = Vector2[tile.grid_position.x, tile.grid_position.y - 1] / @sprite.image.width

    @sprite.scale_x = tile.width.to_f / (tile.height * 3)
    @sprite.skew_y(SKEW * @sprite.scale_x)
  end

  # Doesn't move or anything like that.
  def update
    player = scene.player
    if player.z < 4 and collide? player
      # Find the next teleporter on the map.
      partner = find_partner
      if partner
        position = partner.pos + [player.to_rect.width, 0]
        scene.run_scene :teleporting, scene, position
      end
    end
  end

  def find_partner
    scene.objects.grep(TeleporterBackwards).select {|o| o.x > x }.sort_by {|o| distance(o) }.first
  end

  def draw_on(win)
    @sprite.shader[:offset] = @shader_offset

    super
  end
end

class TeleporterBackwards < Teleporter
  def find_partner
    scene.objects.grep(Teleporter).select {|o| o.x < x }.sort_by {|o| distance(o) }.first
  end
end
