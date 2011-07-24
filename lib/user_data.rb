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

class UserData < UserData
  FILE_NAME = 'zed_and_ginger.dat'
  DEFAULT_DATA_FILE = File.join(EXTRACT_PATH, 'config', FILE_NAME)
  DATA_FILE = File.join(ROOT_PATH, FILE_NAME)

  FIELD_LEVELS = 'levels'

  FIELD_HIGH_SCORER = 'high-scorer'
  FIELD_HIGH_SCORE = 'high-score'

  FIELD_SCALING = 'scaling'

  MIN_SCALING = 2

  def initialize
    super DATA_FILE, DEFAULT_DATA_FILE
  end

  def high_scorer(level)
    @data[FIELD_LEVELS][level][FIELD_HIGH_SCORER]
  end

  def high_score(level)
    @data[FIELD_LEVELS][level][FIELD_HIGH_SCORE]
  end

  def set_high_score(level, player, score)
    @data[FIELD_LEVELS][level][FIELD_HIGH_SCORER] = player
    @data[FIELD_LEVELS][level][FIELD_HIGH_SCORE] = score
    save
  end

  def level_unlocked?(level)
    if level == 0
      true
    else
      @data[FIELD_LEVELS][level][FIELD_HIGH_SCORE] > 0
    end
  end

  def scaling
    [@data[FIELD_SCALING].round, MIN_SCALING].max
  end

  def scaling=(scaling)
    @data[FIELD_SCALING] = scaling
    save
  end
end
