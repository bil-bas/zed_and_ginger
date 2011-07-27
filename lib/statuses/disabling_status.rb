require_relative "status"

class Status
  class DisablingStatus < Status
    RECOVERY_JUMP_SPEED = 32

    DISABLES = [:animation, :controls, :jumping, :hurt, :physics]
    def disables?(action); DISABLES.include? action; end

    def default_duration; 1.5; end

    def setup
      owner.velocity_x = owner.velocity_y = owner.velocity_z = 0
    end

    def clean_up
      owner.velocity_x = RECOVERY_JUMP_SPEED
      owner.jump
      owner.apply_status :invulnerable
    end
  end
end