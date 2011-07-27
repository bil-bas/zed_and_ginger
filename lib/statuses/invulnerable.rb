require_relative "status"

class Status
  class Invulnerable < Status
    ACTIVE_COLOR = Color.new(255, 255, 255, 125)
    DEFAULT_COLOR = Color.white
    DISABLES = [:hurt]

    def disables?(action); DISABLES.include? action; end

    def default_duration; 0.75; end

    def setup
      owner.color = ACTIVE_COLOR
    end

    def clean_up
      owner.color = DEFAULT_COLOR
    end
  end
end