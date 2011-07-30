class Teleporting < Scene
  SPEED = 128.0

  FREQUENCY_AMPLITUDE = 0
  INTERFERENCE_AMPLITUDE = 2

  class << self
    def shader
      unless defined? @shader
        @shader = Shader.new frag: StringIO.new(read_shader("teleporter.frag"))
        @shader[:pixel_width] = 1.0 / GAME_RESOLUTION.width
        @shader[:pixel_height] = 1.0 / GAME_RESOLUTION.height
        @shader[:interference_amplitude] = INTERFERENCE_AMPLITUDE
        @shader[:frequency_amplitude] =  FREQUENCY_AMPLITUDE
      end
      @shader
    end

    def shader_time=(time)
      @shader[:time] = time if defined? @shader
    end
  end

  def setup(previous_scene, teleportee, position)
    @previous_scene, @teleportee, @position = previous_scene, teleportee, position

    @animation = translation from: @teleportee.position,
                             to: position,
                             duration: @teleportee.position.distance(position) / SPEED

    @animation.start(@teleportee)

    @overlay = sprite Image.new GAME_RESOLUTION
    @overlay.scale = [window.scaling] * 2
    @overlay.shader = self.class.shader

    @last_time = Time.now
  end

  def register
    always do
      frame_time = Time.now - @last_time
      @animation.update
      @teleportee.update_riding_position if @teleportee.riding?
      @previous_scene.update_camera(frame_time)
      @previous_scene.update_shaders
      pop_scene unless @animation.running?
      @last_time = Time.now
    end
  end

  def render(win)
    @previous_scene.render(win)
    @overlay.shader[:offset] = (@teleportee.position - @position) / (window.user_data.scaling * 5)
    win.draw @overlay
  end
end