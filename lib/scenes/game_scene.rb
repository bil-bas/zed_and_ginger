class GameScene < Scene
  def setup
    window.hide_cursor

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
end