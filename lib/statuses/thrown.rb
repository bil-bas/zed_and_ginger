require_relative "disabling_status"

class Status
  # Relies on the "thrower" to apply the force.
  # Disables you until you hit the ground again.
  class Thrown < DisablingStatus
    SPIN_FREQUENCY = 5.0

    def setup
      @start = Time.now

      # Prevent immediate un-throwing.
      owner.z = 000001 if owner.z == 0

      @original_origin = owner.origin
      owner.sheet_pos = owner.class::THROWN_SPRITE

      owner.origin = Vector2[owner.sprite_width, owner.sprite_height] * 0.5
    end

    def update
      if owner.z > 0
        owner.angle = (scene.timer.elapsed * 360 * SPIN_FREQUENCY) % 360
      else
        owner.sheet_pos = owner.class::AFTER_THROWN_SPRITE
        owner.angle = 0
        owner.origin = @original_origin
      end
    end
  end
end