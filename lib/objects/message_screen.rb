require_relative "dynamic_object"

class MessageScreen < DynamicObject
  TEXT_SCALING = 8.0
  TEXT_PADDING = 2 # 2 pixels gap at each end.

  def casts_shadow?; false; end

  def initialize(map, tile, position)
    sprite = sprite image_path("message_screen.png")
    #sprite.origin = Vector2[0, 0]

    super(map.scene, sprite, position)

    # Create text for the message.
    message = map.next_message
    raise "no message for screen" unless message

    num_tiles = 5
    pos = Vector2[@sprite.x + 0.5 - (num_tiles * tile.width / 2.0), -tile.width * 2 + 1]
    scaling = window.scaling
    @text = text message, size: 6.25, color: Color.green, at: pos / scaling
    @text.scale = [1.0 /  scaling] * 2

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