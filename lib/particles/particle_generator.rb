require_relative 'particle'

class ParticleGenerator
  include Log

  attr_reader :scene

  def particles; @active; end

  public
  def initialize(scene, options = {})
    options = {
        initial_pool_size: 200,
    }.merge! options

    @scene = scene

    t = Time.now
    @pool = Array.new(options[:initial_pool_size]) { Particle.new(self) }
    log.debug { "Created #{options[:initial_pool_size]} particles in the pool in #{Time.now - t}s" }

    @active = []
  end

  public
  def create(position, options = {})
    options = {
        number: 1,
    }.merge! options

    options[:number].times do
      particle = @pool.empty? ? Particle.new(self) : @pool.shift
      particle.init(position, options)
      @active << particle
    end
  end

  public
  def destroy(particle)
    @pool << particle if @active.delete particle
  end

  public
  def update
    frame_time = @scene.frame_time
    @active.each {|p| p.update frame_time }
  end
end
