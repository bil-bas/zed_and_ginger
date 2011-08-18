require_relative 'gui_scene'

class HighScores < GuiScene
  SCORE_SIZE = ITEM_SIZE * 1.2

  DEFAULT_SCORE = '0000000'
  DEFAULT_SCORER = '???'
  DEFAULT_DATE = '2011/08/08 00:00'.gsub(/./, ' ')
  DEFAULT_TEXT = '[HC INV]'.gsub(/./, ' ')

  def setup
    super()

    y = 0

    gui_controls << ShadowText.new("High Scores", at: [TITLE_X, y], size: HEADING_SIZE)
    y += gui_controls.last.height + LINE_SPACING * 4

    # Level buttons to get the scores for a particular level.
    @level_buttons = RadioGroup.new(at: [LABEL_X, y], default_button_options: { size: SCORE_SIZE }) do |value|
       update_scores
    end

    (Level::LEVEL_NUMBERS - [UserData::DEV_LEVEL]).each do |i|
      @level_buttons.button(i.to_s, i, tip: "Level #{i}")
    end

    gui_controls << @level_buttons

    y += gui_controls.last.height + LINE_SPACING * 4

    # Table of scores => names.
    @scores = []
    @names = []
    @dates = []
    @texts = []
    (OnlineHighScores::NUM_SCORES_STORED + 1).times.with_index do |score, i|
      if i == OnlineHighScores::NUM_SCORES_STORED
        @message = ShadowText.new('', at: [LABEL_X, y], size: SCORE_SIZE, color: Color.red)
        y += @dates.last.height + LINE_SPACING * 1.5
      end

      x = LABEL_X
      @scores << ShadowText.new(DEFAULT_SCORE, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @scores.last.width + LINE_SPACING * 20

      @names << ShadowText.new(DEFAULT_SCORER, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @names.last.width + LINE_SPACING * 20

      @texts << ShadowText.new(DEFAULT_TEXT, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @texts.last.width + LINE_SPACING * 20

      @dates << ShadowText.new(DEFAULT_DATE, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      y += @dates.last.height + LINE_SPACING * 1.5
    end

    @level_buttons.select 1

    self.gui_controls += @scores + @names + @dates + @texts + [@message]

    back_button
  end

  def update_scores
    high_scores = begin
      @message.string = ""
      game.online_high_scores[@level_buttons.value]
    rescue OnlineHighScores::NetworkError
      @message.string = "Network failure - try again later!"
      []
    end

    high_scores.each_with_index do |score, i|
      @scores[i].string = score.score.to_s.rjust(7, '0')
      @names[i].string = score.name
      @dates[i].string = R18n.get.l score.time
      @texts[i].string = score.text
    end

    # Clear rest of scores.
    ((high_scores.size)...OnlineHighScores::NUM_SCORES_STORED).each do |i|
      @scores[i].string = DEFAULT_SCORE
      @names[i].string = DEFAULT_SCORER
      @dates[i].string = DEFAULT_DATE
      @texts[i].string = DEFAULT_TEXT
    end

    # If the network is down or the local high score isn't in the list, then add it at the bottom.
    score, scorer, time, text =
        user_data.high_score(@level_buttons.value),
        user_data.high_scorer(@level_buttons.value),
        user_data.high_score_time(@level_buttons.value),
        user_data.high_score_text(@level_buttons.value)

    if  score > 0 and (high_scores.empty? or
        high_scores.all? {|h| h.score != score and h.name != scorer and h.time != time and h.text != text })

      @scores.last.string = score.to_s.rjust(7, '0')
      @names.last.string = scorer
      @dates.last.string = R18n.get.l time
      @texts.last.string = text
    else
      @scores.last.string = @names.last.string = @dates.last.string = @texts.last.string = ''
    end
  end

  def update
    background.update frame_time
    super
  end

  def register
    super

    on :key_press, key(:escape) do
      pop_scene
    end
  end

  def render(win)
    background.draw_on win
    super
  end
end