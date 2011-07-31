class MyGame < Ray::Game
  SCREEN_SHOT_EXTENSION = 'tga'

  attr_reader :fps_monitor

  def initialize(*args)
    super(*args)

    @fps_monitor = FpsMonitor.new

    window.hide_cursor

    window_view = window.default_view
    window_view.zoom_by window.scaling
    window_view.center = window_view.size / 2
    window.view = window_view

    SCENE_CLASSES.each {|s| s.bind(self) }
    scenes << :main_menu unless defined? Ocra
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

    on :key_press, *key_or_code(window.user_data.control(:show_fps)) do
      @fps_monitor.toggle
    end

    on :key_press, *key_or_code(window.user_data.control(:screenshot)) do
      path = File.join(ROOT_PATH, 'screenshots')
      FileUtils.mkdir_p path
      files = Dir[File.join(path, "screenshot_*.#{SCREEN_SHOT_EXTENSION}")]
      last_number = files.map {|f| f =~ /(\d+)\.#{SCREEN_SHOT_EXTENSION}$/; $1.to_i }.sort.last || 0
      window.to_image.write(File.join(path, "screenshot_#{(last_number + 1).to_s.rjust(3, '0')}.#{SCREEN_SHOT_EXTENSION}"))
    end
  end
end