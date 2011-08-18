require 'time'

class OnlineHighScores
  URL = "http://zed_and_ginger_00:cazoo_of_solid_gold@www.gamercv.com/games/$/high_scores.json"

  NUM_SCORES_STORED = 10
  REFRESH_AFTER = 30 # Refresh high scores every so often.

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
    def text; @data['text'] || ''; end
  end

  def initialize
    @cached_scores = {}
    @scores_cached_at = Hash.new {|h, k| h[k] = Time.new(0) }
  end

  public
  def [](level)
    begin
      unless @cached_scores.has_key? level and (Time.now - @scores_cached_at[level] < REFRESH_AFTER)
        @cached_scores[level] = JSON.parse(RestClient.get(url(level))).map {|d| HighScore.new(d) }
        @scores_cached_at[level] = Time.now
      end

      @cached_scores[level]
    rescue RestClient::ResourceNotFound
      raise OnlineHighScores::NetworkError
    end
  end

  public
  def high_score?(level, score)
    begin
      self[level].size < NUM_SCORES_STORED or score > self[level].last.score
    rescue NetworkError
      false
    end
  end

  public
  # Returns position of score (or nil if it didn't get on the table).
  def add_score(level, name, score, text)
    return nil unless high_score? level, score

    begin
      data = RestClient.post url(level), high_score: { name: name, score: score, text: text }
      HighScore.new(data)

    rescue RestClient::ResourceNotFound
      raise OnlineHighScores::NetworkError

    rescue RestClient::Forbidden # Score wouldn't get on the table, so was refused.
      nil

    ensure
      @cached_scores.delete level # Force reloading of the whole level scores.
    end
  end

  protected
  def url(level); URL.sub('$', LEVELS[level].to_s); end
end