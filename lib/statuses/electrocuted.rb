require_relative "status"

class Status
  class Electrocuted < DisablingStatus
    ACTIVE_COLOR = Color.new(200, 200, 255, 255)
    DEFAULT_COLOR = Color.white

    def sound_effect; "player_squashed.ogg"; end

    def setup
      super

      owner.sheet_pos = owner.class::ELECTROCUTED_SPRITE
      owner.color = ACTIVE_COLOR
      @original_z = owner.z
    end

    def update
       owner.z = @original_z + rand() * 3

      if rand() < 0.25
        owner.scene.create_particle([owner.x, owner.y, owner.z + 6], gravity: 0, scale: 2,
            random_velocity: [8, 8, 8], glow: true, color: Pacer::SPARK_COLOR, shrink_duration: 2)
      end
    end

    def clean_up
      owner.color = DEFAULT_COLOR
      owner.z = @original_z
      super
    end
  end
end