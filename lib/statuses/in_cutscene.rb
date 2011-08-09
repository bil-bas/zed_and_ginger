require_relative "status"

class Status
  class InCutscene < Status
    DISABLES = [:controls, :jumping]
    def disables?(action); DISABLES.include? action; end

    def default_duration; Float::INFINITY; end
  end
end