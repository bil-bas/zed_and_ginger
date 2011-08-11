require_relative "intro_scene"
require_relative "../intro/ship"
require_relative "../intro/asteroid"
require_relative "../intro/zed_asteroid"

class IntroOutside < IntroScene
  def setup(player_sheets)
    @player_sheets = player_sheets

    super()

    @objects = []
    @particle_generator = ParticleGenerator.new(self)

    @ship = Ship.new(self, [-190, 24], 0.1)
    @asteroid = ZedAsteroid.new(self, [200, 5])
    @num_frames = 0
    @zed_essence = nil
  end

  def next_intro
    push_scene :intro_inside, @player_sheets
  end

  def clean_up
    super
    @zed_essence.quiet if @zed_essence
  end

  def update
    super

    if rand() < 0.02
      Asteroid.new(self, [100, rand(50)])
    end
  end

  def render(win)
    background.draw_on(win)

    @zed_essence ||= @objects.find {|o| o.is_a? ZedEssenceOutside }

    view = win.view
    if @num_frames > 800
      view.zoom_by 2
      view.center = @zed_essence.x + @zed_essence.y / 2, @zed_essence.y
    end

    @num_frames += 1

    win.with_view view do
      before, behind  = @objects.partition {|o| o.is_a? Asteroid }

      behind.each {|o| o.draw_on(win) }

      @particle_generator.particles.each {|p| p.draw_on(win) }
      @ship.draw_front_on(win)

      before.each {|o| o.draw_on(win) }
    end

    super(win)
  end
end
