module Registers
  def register(scene)
    self.event_runner = scene.event_runner
    @scene            = scene
  end
end