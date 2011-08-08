require_relative "intro_scene"
require_relative "../intro/ship"
require_relative "../intro/zed_asteroid"

class IntroOutside < IntroScene
  def setup
    super()

    @objects = []
    @particle_generator = ParticleGenerator.new(self)

    @ship = Ship.new(self, [-190, 24], 0.1)
    @asteroid = ZedAsteroid.new(self, [200, 5])
  end

  def render(win)
    background.draw_on(win)

    @objects.each {|o| o.draw_on(win) }
    @ship.draw_front_on(win)

    @particle_generator.particles.each {|p| p.draw_on(win) }

    super(win)
  end
end
