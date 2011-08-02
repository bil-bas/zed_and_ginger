module Ray::Helper

  alias_method :original_holding?, :holding?

  def holding?(key)
    if key.is_a? Symbol
      original_holding?(key)
    else
      scene.game.holding_unknown? key
    end
  end
end