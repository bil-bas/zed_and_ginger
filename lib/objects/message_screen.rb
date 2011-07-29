require_relative "dynamic_object"

class MessageScreen < DynamicObject
  FONT_SIZE = 6.25

  def casts_shadow?; false; end

  def initialize(map, tile, position)
    sprite = sprite image_path("message_screen.png")
    super(map.scene, sprite, position)

    # Create text for the message.
    message = map.next_message
    raise "no message for screen" unless message

    num_tiles = 5
    pos = Vector2[@sprite.x + 0.5 - (num_tiles * tile.width / 2.0), -tile.width * 2 + 1]
    scaling = window.scaling
    @text = text message, size: FONT_SIZE, color: Color.green, at: pos

    # Move the sprite behind the text and make it wide enough to show it all.
    @sprite.pos = pos - [2, 1] # Move it up onto the wall.
    @sprite.scale_x = num_tiles * tile.width
  end

  # Doesn't move or anything like that.
  def update
  end

  def draw_on(win)
    super(win)
    win.draw @text
  end
end