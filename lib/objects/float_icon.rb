require_relative "game_object"

class FloatIcon < GameObject
  PIXELS_PER_SECOND = 20
  FLOAT_DISTANCE = 20

  def initialize(name, owner)
    register owner.scene

    sprite = sprite image(image_path("floating/#{name}.png"))
    sprite.origin = Vector2[sprite.image.width / 2, sprite.image.height]
    sprite.scale = [0.5, 0.5]

    super(scene, sprite, owner.position)

    self.z = owner.z + 10
    duration = FLOAT_DISTANCE.to_f / PIXELS_PER_SECOND

    # Float upwards.
    @animations << float_variation(attribute: :z,
                                   from: z,
                                   to: z + FLOAT_DISTANCE,
                                   duration: duration).start(self)
    # Fade out.
    @animations << float_variation(attribute: :alpha,
                                   from: sprite.color.alpha * 2,
                                   to: 0,
                                   duration: duration).start(self)
    ## Grow.
    @animations << vector_variation(attribute: :scale,
                                    from: sprite.scale,
                                    to: sprite.scale * 1.25,
                                    duration: duration).start(@sprite)
  end
end