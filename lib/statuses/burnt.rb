require_relative "disabling_status"

class Status
  class Burnt < DisablingStatus
    def sound_effect; "player_squashed.ogg"; end

    def setup
      super
      owner.sheet_pos = owner.class::BURNT_SPRITE
      # TODO: Create ash particles that fall? At least a proper burned sprite.
    end
  end
end