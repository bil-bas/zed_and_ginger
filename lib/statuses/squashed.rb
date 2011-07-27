require_relative "disabling_status"

class Status
  class Squashed < DisablingStatus
    def sound_effect; "player_squashed.ogg"; end

    def setup
      super

      owner.sheet_pos = owner.class::SQUASHED_SPRITE
      owner.z = 0
      owner.y += owner.class::SQUASH_OFFSET_Y
    end

    def clean_up
      owner.y -= owner.class::SQUASH_OFFSET_Y

      super
    end
  end
end