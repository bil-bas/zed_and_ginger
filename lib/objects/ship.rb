class Ship < GameObject
  include Helper

  attr_accessor :speed

  def initialize(scene, position, speed)
    @speed = speed
    sprite = sprite image(image_path("ship.png")), at: position
    sprite.sheet_size = [1, 2]

    super(scene, sprite, position)

    @front_sprite = @sprite.dup
    @front_sprite.sheet_pos = [0, 1]
  end

  def update
    @sprite.x += @speed * frame_time
    @front_sprite.x = @sprite.x
  end


  def draw_front_on(win)
    win.draw @front_sprite
  end
end