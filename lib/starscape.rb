class Starscape
  include Helper

  SCALE = 4.0

  def initialize
    image = Image.new GAME_RESOLUTION * SCALE
    image_target image do |target|
      target.clear Color.new(0, 0, 25)
      target.update
    end

    # Draw on some stars.
    400.times do
      star_pos = [rand(image.size.width), rand(image.size.height)]
      image[*star_pos] = Color.new(*([55 + rand(200)] * 3))
    end

    # Add the moon and a sprinkling of asteroids.
    moon = sprite image(image_path("moon.png")),
                at: [310, 18],
                scale: Vector2[4, 4]

    asteroid = sprite image(image_path("asteroid.png"))
    image_target image do |target|
      target.draw moon
      20.times do
        rock_pos = Vector2[150 + rand(100), rand(image.size.height)]
        rock_pos.x += rock_pos.y / 3.0
        asteroid.pos = rock_pos
        asteroid.scale = [0.5 + rand() * 0.3] * 2
        brightness = 50 + rand(100)
        asteroid.color = Color.new(*[brightness] * 3)
        target.draw asteroid
      end
      target.update
    end

    @sprite = sprite image
    @sprite.scale = [1.0 / SCALE] * 2
  end

  def draw_on(win)
    win.draw @sprite
  end
end
