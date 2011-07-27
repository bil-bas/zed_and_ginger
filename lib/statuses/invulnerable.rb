require_relative "status"

class Status
  class Invulnerable < Status
    INVULNERABLE_COLOR = Color.new(255, 255, 255, 125)
    DEFAULT_COLOR = Color.white

    def default_duration; 1; end

    def setup
      owner.color = INVULNERABLE_COLOR
    end

    def clean_up
      owner.color = DEFAULT_COLOR
    end
  end
end