require_relative "status"

class Status
  class DisablingStatus < Status
    MAX_X_VELOCITY_CHANGE_PER_SECOND = 32 # Slowly change the velocity of the player to the speed they will have when they recover.

    DISABLES = [:animation, :controls, :jumping, :hurt, :physics]
    def disables?(action); DISABLES.include? action; end

    def default_duration; 1.0; end

    def setup
      owner.velocity_y = owner.velocity_z = 0
    end

    def update
      # Slowly change x-velocity to that we will have when we recover (to affect the camera position).
      max_x_change = MAX_X_VELOCITY_CHANGE_PER_SECOND * frame_time
      owner.velocity_x += [[Player::JUMP_SPEED - owner.velocity_x, max_x_change].min, -max_x_change].max
    end

    def clean_up
      owner.jump
      owner.apply_status :invulnerable
    end
  end
end