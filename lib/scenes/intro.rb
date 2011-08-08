require_relative "../objects/ship"
require_relative "../objects/zed_asteroid"

class Intro < GameScene
  extend Forwardable

  def_delegator :@particle_generator, :create, :create_particle

  def register
    super()

    on :key_press, key(:space) do
      skip
    end

    on :key_press, key(:escape) do
      skip
    end
  end

  def skip
    pop_scene
  end

  def setup
    super()

    @objects = []
    @particle_generator = ParticleGenerator.new(self)

    @ship = Ship.new(self, [-190, 24], 4)
    @asteroid = ZedAsteroid.new(self, [200, 5])
  end

  def add_object(object)
    @objects << object
  end

  def remove_object(object)
    @objects.delete(object)
  end

  def update
    super()

    background.update frame_time
    @particle_generator.update

    @objects.each {|o| o.update }
  end

  def render(win)
    background.draw_on(win)

    super(win)

    @objects.each {|o| o.draw_on(win) }
    @ship.draw_front_on(win)

    #binding.pry if @particle_generator.particles.any?
    @particle_generator.particles.each {|p| p.draw_on(win) }
  end
end

require 'pry'
