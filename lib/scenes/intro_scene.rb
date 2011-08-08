class IntroScene < GameScene
  def_delegator :@particle_generator, :create, :create_particle
  attr_reader :particle_generator

  BORDER_WIDTH = 3

  BORDER_RECTANGLES = [
      [0, 0, GAME_RESOLUTION.width, BORDER_WIDTH],
      [0, GAME_RESOLUTION.height - BORDER_WIDTH, GAME_RESOLUTION.width, BORDER_WIDTH]
  ]


  def setup
    super()

    @objects = []
    @particle_generator = ParticleGenerator.new(self)

    @fade = Polygon.rectangle([0, 0, *GAME_RESOLUTION], Color.black)
    @fade.blend_mode = :multiply
    gui_controls << @fade

    self.gui_controls += BORDER_RECTANGLES.map {|r| Polygon.rectangle(r, Color.black) }

    gui_controls << ShadowText.new("<space> to skip", at: [GAME_RESOLUTION.width - 4, GAME_RESOLUTION.height - 0.75],
                                   auto_center: [1, 1], size: 4, color: Color.new(255, 255, 255, 150))
  end

  def register
    super()

    @objects.each {|o| o.register(self) }

    on :key_press, key(:space) do
      skip
    end

    on :key_press, key(:escape) do
      skip
    end
  end

  def skip
    pop_scene_while {|s| s.is_a? IntroScene }
  end

  def update
    super

    # Fade in.
    color = @fade.color_of(0)
    if color.red < 255
      color.red = color.green = color.blue = color.red + 2
      @fade.color = color
    end

    background.update frame_time
    @particle_generator.update

    @objects.each {|o| o.update }
  end

  def add_object(object)
    @objects << object
  end

  def remove_object(object)
    @objects.delete(object)
  end
end
