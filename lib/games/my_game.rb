class MyGame < Ray::Game
  include Log
  extend Forwardable

  SCREEN_SHOT_EXTENSION = 'tga'

  attr_reader :fps_monitor, :user_data, :online_high_scores

  def initialize(title, scene_classes, options = {})
    @user_data = UserData.new
    @online_high_scores = OnlineHighScores.new

    options = {
        initial_scene: :main_menu,
    }.merge! options

    initial_scene = options[:initial_scene]

    options = if user_data.fullscreen?
      { size: Ray.screen_size, no_frame: true }
    else
      { size: GAME_RESOLUTION * user_data.scaling }
    end

    super(title, options)

    @fps_monitor = FpsMonitor.new

    window.hide_cursor

    window_view = window.default_view
    window_view.zoom_by user_data.scaling
    window_view.center = window_view.size / 2
    window.view = window_view

    scene_classes.each {|s| s.bind(self) }

    scenes << :main_menu

    if initial_scene != :main_menu
      scenes << initial_scene
    end

    if defined? RubyProf
      RubyProf.start
      RubyProf.pause
      Log.log.debug { "Profiling started and paused" }
    end
  end

  def register
    super

    on :quit do
      if defined? RubyProf and RubyProf.running?
        result = RubyProf.stop
        printer = RubyProf::FlatPrinter.new(result)
        printer.print(STDERR, min_percent: 0.5)
      end

      Kernel.exit
    end

    event_group :game_keys do
      on :key_press, *key_or_code(user_data.control(:show_fps)) do
        @fps_monitor.toggle
      end

      on :key_press, *key_or_code(user_data.control(:screenshot)) do
        path = File.join(ROOT_PATH, 'screenshots')
        Dir.mkdir path unless File.exists? path
        files = Dir[File.join(path, "screenshot_*.#{SCREEN_SHOT_EXTENSION}")]
        last_number = files.map {|f| f =~ /(\d+)\.#{SCREEN_SHOT_EXTENSION}$/; $1.to_i }.sort.last || 0
        window.to_image.write(File.join(path, "screenshot_#{(last_number + 1).to_s.rjust(3, '0')}.#{SCREEN_SHOT_EXTENSION}"))
      end
    end
  end
end