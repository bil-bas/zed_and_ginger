class Camera
  MAX_ZOOM_CHANGE = 1 # Most the zoom can change in a second.
  MAX_X_CHANGE = 100 # Most the camera's position can change in a second.

  attr_accessor :zoom, :x

  def initialize(x, options = {})
    options = {
        zoom: 1.0,
        offset_x: 0.0,
        width: 1.0,
    }.merge! options

    @x = x
    @zoom = options[:zoom]
    @offset_x = options[:offset_x]
    @width = options[:width]
  end

  def zoom_to(desired_zoom, duration)
    @zoom += [[desired_zoom - @zoom, MAX_ZOOM_CHANGE * duration].min, -MAX_ZOOM_CHANGE * duration].max
  end

  def pan_to(desired_x, duration)
    # Prevent rapid shifts as we accelerate or come to a stop.
    max_x_change = MAX_X_CHANGE * duration
    @x += [[desired_x - @x, max_x_change].min, -max_x_change].max
  end

  def view_for(view)
    view = view.dup
    view.size *= [@width / @zoom, 1]
    view.x = @x

    viewport = view.viewport
    viewport.y += viewport.height * (1.0 / @zoom - 1) * 0.25 # Center it vertically.
    viewport.height *= @zoom
    viewport.width *= @width
    viewport.x += @offset_x
    view.viewport = viewport

    view
  end
end
