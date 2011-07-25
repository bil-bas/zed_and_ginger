class GameScene < Scene
  # List of controls, automatically drawn in order.
  attr_accessor :gui_controls

  def setup
    window.hide_cursor

    @gui_controls = []
    @event_handlers = []
  end

  def add_event_handler(*args, &handler)
    @event_handlers << [args, handler]
  end

  def register
    @event_handlers.each do |args, handler|
      on *args, &handler
    end
  end

  def render(win)
    @gui_controls.each {|c| c.draw_on win }
  end
end