context OnlineHighScores do
  setup { OnlineHighScores.new }

  context "[]" do
    asserts("fails on bad level number") { topic[999] }.raises OnlineHighScores::NetworkError
    asserts("contains only HighScore objects") { topic[1].all? {|h| h.is_a? OnlineHighScores::HighScore } }
    asserts("contains correct number of scores") { topic[1] }.size OnlineHighScores::NUM_SCORES_STORED
  end

  context "#add_score" do
    asserts("returns nil if score wouldn't rate") { topic.add_score(1, "BOB", 1, "[test]") }.nil
  end

  context "#high_score?" do
    asserts("true if it would rate") { topic.high_score?(1, Float::INFINITY) }
    denies("false if it wouldn't rate") { topic.high_score?(1, 1) }
  end
end
