require 'time'

class OnlineHighScores
  include Log

  URL = 'http://www.gamercv.com/games/$/high_scores.json'
  USER, PASSWORD = 'zed_and_ginger_00', 'cazoo_of_solid_gold'

  NUM_SCORES_STORED = 100 # There are actually 100 on the server, but just show the top 10.
  REFRESH_AFTER = 30 # Refresh high scores every so often.
  TIMEOUT = 2

  # Each level is mapped to the rest-client resource.
  LEVELS = {
      1 => 15,
      2 => 16,
      3 => 17,
      4 => 18,
      5 => 19,
      6 => 20,
      7 => 21,
      8 => 22,
      9 => 23,
  }

  LEVELS.each_pair do |k, v|
    LEVELS[k] = RestClient::Resource.new(URL.sub('$', v.to_s), user: USER, password: PASSWORD, timeout: TIMEOUT)
  end

  class NetworkError < IOError
  end

  class HighScore
    def initialize(data)
      @data = data
    end

    def name; @data['name']; end
    def score; @data['score']; end
    def position; @data['position']; end
    def time; @time ||= Time.parse(@data['created_at']); end
    def mode; (@data['text'].nil? or @data['text'].empty?) ? :normal : @data['text'].to_sym; end
  end

  def initialize
    @cached_scores = {}
    @scores_cached_at = Hash.new {|h, k| h[k] = Time.new(0) }
  end

  public
  def [](level)
    raise ArgumentError, "No such level as #{level.inspect}" unless LEVELS.has_key? level

    begin
      unless @cached_scores.has_key? level and (Time.now - @scores_cached_at[level] < REFRESH_AFTER)
        t = Time.now
        level_data = LEVELS[level].get
        @cached_scores[level] = JSON.parse(level_data).map {|d| HighScore.new(d) }
        log.info { "Downloaded #{@cached_scores[level].size} high scores for level #{level} in #{Time.now - t}s [#{level_data.size} bytes]" }
        @scores_cached_at[level] = Time.now
      end

      @cached_scores[level]
    rescue RestClient::ResourceNotFound, JSON::ParserError, Errno::ETIMEDOUT, RestClient::RequestTimeout
      raise OnlineHighScores::NetworkError
    end
  end

  public
  def high_score?(level, score)
    return false if level == 0 # Don't record high scores for test level.

    begin
      self[level].size < NUM_SCORES_STORED or score > self[level].last.score
    rescue NetworkError
      false
    end
  end

  public
  # Returns position that a score would have on the table.
  def position_for(level, score, time)
    self[level].each_with_index do |high_score, i|
      if score > high_score.score
        return "#{i + 0.5}"
      elsif score == high_score.score
        return "#{i + 1}"
      end
    end

    return ">#{self[level].size}"
  end

  public
  # Returns position of score (or nil if it didn't get on the table).
  def add_score(level, name, score, mode)
    begin
      data = LEVELS[level].post high_score: { name: name, score: score, text: mode }
      HighScore.new(data)

    rescue RestClient::ResourceNotFound, JSON::ParserError, Errno::ETIMEDOUT, RestClient::RequestTimeout
      raise OnlineHighScores::NetworkError

    rescue RestClient::Forbidden # Score wouldn't get on the table, so was refused.
      nil

    ensure
      @cached_scores.delete level # Force reloading of the whole level scores.
    end
  end
end