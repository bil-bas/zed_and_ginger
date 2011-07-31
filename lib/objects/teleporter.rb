require_relative "dynamic_object"

class Teleporter < DynamicObject
  SKEW = 2
  FREQUENCY_AMPLITUDE = 4
  INTERFERENCE_AMPLITUDE = 2

  def casts_shadow?; false; end

  class << self
    def shader
      unless defined? @shader
        @shader = Shader.new frag: StringIO.new(read_shader("teleporter.frag"))
        @shader[:pixel_width] = 1.0 / 8
        @shader[:pixel_height] = 1.0 / 8
        @shader[:interference_amplitude] = INTERFERENCE_AMPLITUDE
        @shader[:frequency_amplitude] =  FREQUENCY_AMPLITUDE
      end

      @shader
    end

    def shader_time=(time)
      @shader[:time] = time if defined? @shader
    end
  end

  def to_rect; Rect.new(*(@position - [0, 1.5]), 0, 3) end

  def initialize(map, tile, position)
    @@image ||= Image.new([8, 8])
    sprite = sprite @@image
    sprite.origin = Vector2[sprite.image.width - 3, sprite.image.height * 1.5]

    super(map.scene, sprite, position)

    @sprite.shader = self.class.shader

    @shader_offset = Vector2[tile.grid_position.x, tile.grid_position.y - 1] / @sprite.image.width

    @sprite.scale_x = tile.width.to_f / (tile.height * 3)
    @sprite.skew_y(SKEW * @sprite.scale_x)
  end

  # Doesn't move or anything like that.
  def update
    scene.players.shuffle.each do |player|
      if player.z < 4 and collide? player
        # Find the next teleporter on the map.
        partner = find_partner
        if partner
          position = partner.pos + [player.to_rect.width, 0]
          scene.run_scene :teleporting, scene, player, position
        end
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

