require_relative "status"

class Status
  class Squashed < Status
    def default_duration; 2; end

    def disables_animation?; true; end
    def disables_control?; true; end
    def disables_jumping?; true; end

    def setup
      owner.sheet_pos = owner.class::SQUASHED_SPRITE
      owner.z = 0
      owner.velocity_z = 0
      owner.velocity_x = 0
      owner.y += owner.class::SQUASH_OFFSET_Y
      sound(sound_path("player_squashed.ogg")).play
    end

    def clean_up
      owner.y -= owner.class::SQUASH_OFFSET_Y
      owner.jump
      owner.velocity_x = owner.class::RECOVERY_JUMP_SPEED
      owner.apply_status :invulnerable
    end
  end
end