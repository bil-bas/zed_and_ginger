class BaseUserData
  def initialize(user_file, default_file)
    @user_file = user_file
    @data = File.exists?(@user_file) ? YAML::load_file(@user_file) : {}
    @data = YAML::load_file(default_file).deep_merge @data
  end

  def save
    File.open(@user_file, "w") {|f| f.puts @data.to_yaml }
  end
end

class UserData < BaseUserData
  FILE_NAME = 'zed_and_ginger.dat'
  DEFAULT_DATA_FILE = File.join(EXTRACT_PATH, 'config', FILE_NAME)
  DATA_FILE = File.join(ROOT_PATH, FILE_NAME)

  # High scores, high scorers and level unlocking.
  GROUP_LEVELS = 'levels'
  HIGH_SCORER = 'high-scorer'
  HIGH_SCORE = 'high-score'
  FINISHED = 'finished'

  # Graphics options.
  GROUP_GRAPHICS = 'graphics'
  SCALING = 'scaling'

  MIN_SCALING = 2

  # Sound options.
  GROUP_SOUND = 'sound'
  # TODO: sound options.

  # Controls.
  GROUP_CONTROLS = 'controls'
  GROUP_CONTROLS_GENERAL = 'general'

  VALID_PLAYER_CONTROLS = [:left, :right, :up, :down, :jump]
  VALID_CONTROLS = [:pause]

  def initialize
    super DATA_FILE, DEFAULT_DATA_FILE
  end

  # High scores, high scorers and level unlocking.

  def high_scorer(level)
    @data[GROUP_LEVELS][level][HIGH_SCORER]
  end

  def high_score(level)
    @data[GROUP_LEVELS][level][HIGH_SCORE]
  end

  def set_high_score(level, player, score)
    @data[GROUP_LEVELS][level][HIGH_SCORER] = player
    @data[GROUP_LEVELS][level][HIGH_SCORE] = score
    save
  end

  def level_unlocked?(level)
    # First (tutorial) level is always unlocked.
    if level == 0
      true
    else
      @data[GROUP_LEVELS][level - 1][FINISHED]
    end
  end

  def finished_level?(level)
    @data[GROUP_LEVELS][level][FINISHED]
  end

  # Possible to finish a level without having made a high score.
  def finish_level(level)
    @data[GROUP_LEVELS][level][FINISHED] = true
    save
  end

  # Graphics options.

  def scaling
    [@data[GROUP_GRAPHICS][SCALING].round, MIN_SCALING].max
  end

  def scaling=(scaling)
    @data[GROUP_GRAPHICS][SCALING] = scaling
    save
  end

  # Controls

  def player_control(player, action)
    raise "Bad player #{player.inspect}" unless [1, 2].include? player
    raise "Bad action #{action.inspect}" unless VALID_PLAYER_CONTROLS.include? action
    @data[GROUP_CONTROLS][player][action.to_s].to_sym
  end

  def control(action)
    raise "Bad action #{action.inspect}" unless VALID_CONTROLS.include? action
    @data[GROUP_CONTROLS][GROUP_CONTROLS_GENERAL][action.to_s].to_sym
  end
end
