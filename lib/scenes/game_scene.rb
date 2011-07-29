class GameScene < Scene
  include Log

  # List of controls, automatically drawn in order.
  attr_accessor :gui_controls

  class << self
    attr_accessor :background
  end

  def background; GameScene.background; end
  def background=(background); GameScene.background = background; end

  def setup
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

  # Patched to return the scene that was run after run_scene
  def run_scene(name, *args, &blocks)
    scene_list = SceneList.new(game)
    scene_list.push(name, *args)

    scene_run = scene_list.current

    event_runner = DSL::EventRunner.new

    old_event_runner = game.event_runner
    old_scene_list   = game.scenes

    game.event_runner = event_runner
    game.scenes = scene_list

    begin
      game.run
    ensure
      game.event_runner = old_event_runner
      game.scenes       = old_scene_list
    end

    if scene_run.respond_to? :run_result
      result = scene_run.run_result
      yield result if block_given?
      result
    else
      nil
    end
  end
end