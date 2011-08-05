module Registers
  extend Forwardable

  def_delegators :@scene, :window, :frame_time, :frame_number

  attr_reader :scene

  def register(scene)
    self.event_runner = scene.event_runner
    @scene            = scene
  end
end