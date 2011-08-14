require_relative 'game_object'

# Speeds up the player, but forces them to run.
class SpeedPill < GameObject
  SCORE = 500

  def casts_shadow?; true; end

  def to_rect; Rect.new(*(@position - [2, 1.5]), 4, 3) end

  def initialize(map, tile, position)
    sprite = sprite image_path("speed_pill.png"), at: position
    sprite.origin = Vector2[sprite.image.width / 2, sprite.image.height / 2]
    sprite.scale = [0.75, 0.75]

    super(map.scene, sprite, position)

    self.z = 4
    @shadow.scale *= [0.5, 0.3]
  end

  def collide?(other)
    other.z <= 6 and super(other)
  end

  def update
    @sprite.angle = Math::sin(scene.timer.elapsed * 10) * 30

    scene.players.shuffle.each do |player|
      if player.ok? and collide? player
        player.apply_status :hyper_speed
        [Color.red, Color.white].each do |color|
          scene.create_particle([self.x, self.y, self.z], number: 5, gravity: 0.5,
                                 velocity: [0, 0, 50], random_velocity: [10, 10, 10],
                                 color: color)
        end

        player.score += SCORE
        scene.remove_object self
        break
      end
    end

    super
  end
end