require_relative "disabling_status"

class Status
  # Eaten by a venus fly trap.
  class Eaten < DisablingStatus
    ACTIVE_COLOR = Color.new(255, 255, 255, 0)
    DEFAULT_COLOR = Color.white

    # Removal of the state is handled by the eater.
    def default_duration; Float::INFINITY; end

    def setup
      super
      owner.color = ACTIVE_COLOR
    end

    def clean_up
      owner.color = DEFAULT_COLOR
      super
    end
  end
end