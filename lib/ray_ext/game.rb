require 'set'

class Ray::Game
  alias_method :original_initialize, :initialize
  def initialize(*args, &block)
    original_initialize(*args, &block)

    @holding_unknown = Set.new
  end

  def holding_unknown?(key_code)
    @holding_unknown.include? key_code
  end

  alias_method :original_register, :register
  def register
    original_register

    # Monitor the non-mapped keys.
    on :key_press, key(:unknown) do |*_, code|
      @holding_unknown.add code
    end

    on :key_release, key(:unknown) do |*_, code|
      @holding_unknown.delete code
    end
  end
end
