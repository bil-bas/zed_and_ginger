class Teleporting < Scene
  SPEED = 128.0

  FREQUENCY_AMPLITUDE = 0
  INTERFERENCE_AMPLITUDE = 2

  def self.shader_time=(time); @@shader[:time] = time if defined? @@shader; end

  def setup(previous_scene, position)

    @previous_scene, @position = previous_scene, position
    @player = @previous_scene.player

    @animation = translation from: @player.position,
                             to: position,
                             duration: @player.position.distance(position) / SPEED

    @animation.start(@player)

    @overlay = sprite Image.new(window.scaled_size - [0, 6])
    unless defined? @@shader
      @@shader = Shader.new frag: StringIO.new(read_shader("teleporter.frag"))
      @@shader[:pixel_width] = 1.0 / window.scaled_size.width
      @@shader[:pixel_height] = 1.0 / window.scaled_size.height
      @@shader[:interference_amplitude] = INTERFERENCE_AMPLITUDE
      @@shader[:frequency_amplitude] =  FREQUENCY_AMPLITUDE
    end

    @overlay.shader = @@shader
  end

  def register
    always do
      @animation.update
      @player.update_riding_position if @player.riding?
      @previous_scene.move_camera
      @previous_scene.update_shaders
      pop_scene unless @animation.running?
    end
  end

  def render(win)
    @previous_scene.render(win)
    @@shader[:offset] = (@player.position - @position) / (window.user_data.scaling * 5)
    win.draw @overlay
  end
end