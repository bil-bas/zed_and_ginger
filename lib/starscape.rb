class Starscape
  include Helper

  SCALE = 4.0

  ASTEROID_SIZES = [3.0, 4.0, 6.0]
  ASTEROID_SPEEDS = [0.2, 0.3, 0.4].map {|i| i * 5 }
  ASTEROID_BRIGHTNESSES = [0, 25, 50]

  def initialize
    # Create the moon and stars.
    background = Image.new GAME_RESOLUTION * SCALE

    draw_stars_on background
    draw_moon_on background

    @background = sprite background
    @background.scale = [1.0 / SCALE] * 2

    # Create the asteroids.
    @asteroids = ASTEROID_SIZES.map.with_index do |scale, i|
      size = GAME_RESOLUTION * SCALE / ASTEROID_SIZES[i]
      size.height += 8 * SCALE / ASTEROID_SIZES[i]
      image = Image.new size
      draw_asteroids_on image, ASTEROID_BRIGHTNESSES[i]

      sprite1 = sprite image
      sprite1.scale = @background.scale * ASTEROID_SIZES[i]
      sprite1.y -= rand() * 8
      sprite2 = sprite1.dup
      sprite2.x += GAME_RESOLUTION.width

      [sprite1, sprite2]
    end
  end

  def draw_stars_on(image)
    image_target image do |target|
      target.clear Color.new(0, 0, 25)
      target.update
    end

    # Draw on some stars.
    400.times do
      star_pos = [rand(image.size.width), rand(image.size.height)]
      image[*star_pos] = Color.new(*([55 + rand(200)] * 3))
    end
  end

  def draw_moon_on(image)
    # Add the moon and a sprinkling of asteroids.
    moon = sprite image(image_path("moon.png")),
                at: [310, 18],
                scale: Vector2[4, 4]

    image_target image do |target|
      target.draw moon
    end
  end

  def draw_asteroids_on(image, base_brightness)
    image_target image do |target|
      target.clear Color.none
      target.update
    end

    (image.size.height / 2).to_i.times do
      image[rand(image.size.width), rand(image.size.height)] = Color.new(*([base_brightness + rand(50)] * 3))
    end
  end

  def update(duration)
    width = GAME_RESOLUTION.width
    @asteroids.each_with_index do |layers, i|
      distance = duration * ASTEROID_SPEEDS[i]
      layers.each.with_index do |layer, j|
        layer.x -= distance
        layer.x += (width * 2) if layer.x < -width
      end
    end
  end

  def draw_on(win)
    win.draw @background
    @asteroids.flatten.each {|layer| win.draw layer }
  end
end
