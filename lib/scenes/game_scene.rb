class GameScene < Scene
  extend Forwardable
  include Log

  def_delegators :game, :fps_monitor, :user_data
  def_delegators :"game.fps_monitor", :frame_time

  # List of controls, automatically drawn in order.
  attr_accessor :gui_controls

  class << self
    attr_accessor :background
    attr_accessor :ambient_music
  end

  def background; GameScene.background; end
  def background=(background); GameScene.background = background; end

  def ambient_music
    unless GameScene.ambient_music
      music = music music_path("Space_Cat_Ambient.ogg")
      music.looping = true
      GameScene.ambient_music = music
      reset_ambient_music_volume
    end

    GameScene.ambient_music
  end

  def reset_ambient_music_volume
     ambient_music.volume = 50 * (user_data.music_volume / 50.0)
  end

  def setup
    @gui_controls = []
  end

  def register
    @gui_controls.each {|c| c.register(self) if c.respond_to? :register }

    always { update }
  end

  alias_method :original_run_tick, :run_tick
  def run_tick(check_events = true)
    fps_monitor.run_frame { original_run_tick }
  end

  def render(win)
    @gui_controls.each {|c| c.draw_on win }
    fps_monitor.draw_on win if fps_monitor.shown?
  end

  def update
    #override
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