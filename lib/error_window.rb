class ErrorWindow < Game
  include Log

  def initialize(title, exception, options = {})
    super(title, options)
    @exception = exception

    setup
  end

  def register
   on :quit do
      Kernel.exit
    end
  end

  def setup
    message = <<-END
The game suffered from a fatal error and had to go and die in a corner.
The full error report has been written to zed_and_ginger.log

#{@exception.class}: #{@exception.message}

#{@exception.backtrace.join("\n")}"
END

    log.error { message }

    Window.send :scaling=, 1

    scene :scene do
      y = 0
      @lines = message.split("\n").map do |line|
        text = Text.new(line, at: [0, y], size: 16)
        y += text.size * 0.8
        text
      end

      def render(win)
        @lines.each {|line| win.draw line }
      end
    end

    scenes << :scene
  end
end