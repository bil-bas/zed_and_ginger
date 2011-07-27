class Status
  include Log
  include Helper

  extend Forwardable

  def_delegators :@owner, :scene, :window

  attr_reader :owner # Object this status is applied to.

  def self.type; name.downcase[/[^:]+$/].to_sym; end
  def type; @type ||= self.class.type; end

  def default_duration; Float::INFINITY; end
  def sound_effect; nil; end # Override.

  public
  # If :duration option is missing, duration is indefinite.
  def initialize(owner, options = {})
    options = {
        duration: default_duration,
    }.merge! options

    @owner = owner
    @expires_at = 0

    duration_timer(options[:duration])

    register(scene)

    raise_event :status_application, @owner, self

    sound(sound_path(sound_effect)).play if sound_effect

    setup

    log.debug do
      duration = options[:duration]
      duration = (duration < Float::INFINITY) ? "for #{duration}s" : "indefinitely"
      "Applied status #{type.inspect} to #{@owner} #{duration}"
    end
  end

  public
  def register(scene)
    self.event_runner = scene.event_runner
    @scene            = scene
  end

  protected
  def _update
    if scene.timer.elapsed >= @expires_at
      remove
    else
      update
    end
  end

  protected
  def duration_timer(duration)
    will_expire_at = scene.timer.elapsed + duration
    @expires_at = [will_expire_at, @expires_at].max
  end

  public
  # Called if the status effect is already on an object.
  # Duration reset to that of the new duration, unless the remaining duration is greater.
  def reapply(options = {})
    options = {
        duration: default_duration,
    }.merge! options

    duration_timer(options[:duration])
  end

  public
  def draw_on(win)
    # Override.
  end

  public
  def update
    # Override.
  end

  public
  def setup
    # Override.
  end

  public
  def clean_up
    # Override.
  end

  def disables?(action)
    # Override.
    false
  end

  public
  # Status effect has been removed.
  def remove
    return unless @owner

    clean_up

    old_owner = @owner
    @owner = nil
    old_owner.remove_status(type)

    log.debug { "Removed status #{type.inspect} from #{old_owner}" }
  end
end