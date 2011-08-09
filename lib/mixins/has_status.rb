module HasStatus
  @@status_types = {}

  def self.included(base)
    # For each status, add a query method.
    # E.g. If there is a Status::Poisoned class, there will be a poisoned? method.
    Status.constants.each do |status|
      klass = Status.const_get(status)

      if klass.is_a? Class and klass.ancestors.include? Status

        type = klass.type
        @@status_types[type] = klass
        define_method("#{type}?") do
          not status(type).nil?
        end
      end
    end

    super(base)
  end

  def statuses; @statuses.values; end
  def valid_status?(type); @@status_types.has_key? type; end

  def initialize(*args)
    @statuses = {}
    super(*args)
  end

  # Get the status of this type, if any.
  def status(type)
    @statuses[type]
  end

  def apply_status(type, options = {})
    existing_status = status(type)
    if existing_status
      existing_status.reapply(options)
    else
      raise "No defined status: #{type.inspect}" unless @@status_types.has_key? type
      status = @@status_types[type].new(self, options)
      @statuses[type] = status
    end
  end

  def remove_status(type)
    return unless status(type)

    status = @statuses.delete type
    status.remove
  end

  def disabled?(action)
    @statuses.each_value.any? {|s| s.disables? action }
  end

  def update
    @statuses.values.each do |status|
      status.send :_update
    end

    super
  end

  def draw_on(win)
    super(win)

    @statuses.each_value {|status| status.draw_on(win) }
  end
end
