require_relative "disabling_status"

class Status
  class Burnt < DisablingStatus
    def sound_effect; "player_squashed.ogg"; end

    def setup
      super
      # Create charcoal briquettes.
      owner.explode_pixels(color: Color.black, gravity: 0.5, velocity: [0, 0, 5], random_velocity: [1, 1, 1])

      # Create smoke.
      owner.scene.create_particle([owner.x, owner.y, owner.z + 4], color: Color.new(0, 0, 0, 100), number: 10,
                                  fade_duration: 4, gravity: 0, scale: 2, velocity: [0, 0, 3],
                                  random_position: [4, 2, 1], random_velocity: [1, 1, 0])
      owner.sheet_pos = owner.class::BLANK_SPRITE
    end
  end
end