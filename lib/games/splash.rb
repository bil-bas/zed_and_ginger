class Splash < Ray::Game
  attr_reader :image_file, :pre_load_code

  def initialize(image_file, pre_load_code, options = {})
    super('', options.merge(no_frame: true))

    @image_file, @pre_load_code = image_file, pre_load_code

    setup
  end

  def setup
    scene :splash do
      register do
        on :quit! do
          pop_scene
          window.close
          Kernel.exit
        end
      end

      @sprite = sprite image(game.image_file)
      @sprite.scale *= window.size.width / @sprite.image.width.to_f
      @empty_ticks = 0 # Allow a bit of time for the window to sort itself out.

      always do
        @empty_ticks += 1
        if @empty_ticks >= 5
          game.pre_load_code.call
          pop_scene
          window.close
        end
      end

      render do |win|
        win.draw @sprite
      end
    end

    scenes << :splash
  end
end

