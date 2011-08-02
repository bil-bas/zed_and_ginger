module Registers
  extend Forwardable

  def_delegators :@scene, :window, :frame_time

  attr_reader :scene

  def register(scene)
    self.event_runner = scene.event_runner
    @scene            = scene
  end
end