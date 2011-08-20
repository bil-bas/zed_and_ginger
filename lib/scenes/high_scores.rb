require_relative 'gui_scene'

class HighScores < GuiScene
  SCORE_SIZE = ITEM_SIZE * 1.2

  POSITION_WIDTH = 4
  SCORE_WIDTH = 7

  DEFAULT_POSITION = ' ' * POSITION_WIDTH
  DEFAULT_SCORE = ' ' * SCORE_WIDTH
  DEFAULT_SCORER = 'BIL'.gsub(/./, ' ')
  DEFAULT_DATE = '2011/08/08 00:00'.gsub(/./, ' ')
  DEFAULT_TEXT = '<Inversion>'.gsub(/./, ' ')

  COLUMN_SPACING = LINE_SPACING * 10

  HIGH_SCORES_PER_PAGE = 10

  def setup
    super()

    y = 0

    @score_from ||= 0

    gui_controls << ShadowText.new(t.label.title, at: [TITLE_X, y], size: HEADING_SIZE)
    y += gui_controls.last.height + LINE_SPACING * 4

    # Level buttons to get the scores for a particular level.
    @level_buttons = RadioGroup.new(at: [LABEL_X, y], default_button_options: { size: SCORE_SIZE }) do |value|
       update_scores
    end

    (Level::LEVEL_NUMBERS - [UserData::DEV_LEVEL]).each do |i|
      @level_buttons.button(i.to_s, i, tip: t.button.level.tip(i))
    end

    gui_controls << @level_buttons

    nav_buttons(y)

    y += gui_controls.last.height + LINE_SPACING * 4

    # Table of scores => names.
    @positions = []
    @scores = []
    @names = []
    @dates = []
    @modes = []
    (HIGH_SCORES_PER_PAGE + 1).times.with_index do |score, i|
      if i == HIGH_SCORES_PER_PAGE
        @message = ShadowText.new('', at: [LABEL_X, y], size: SCORE_SIZE)
        y += @dates.last.height + LINE_SPACING * 1.5
      end

      x = LABEL_X

      @positions << ShadowText.new(DEFAULT_POSITION, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @positions.last.width + COLUMN_SPACING

      @scores << ShadowText.new(DEFAULT_SCORE, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @scores.last.width + COLUMN_SPACING

      @names << ShadowText.new(DEFAULT_SCORER, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @names.last.width + COLUMN_SPACING

      @modes << ShadowText.new(DEFAULT_TEXT, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      x += @modes.last.width + COLUMN_SPACING

      @dates << ShadowText.new(DEFAULT_DATE, at: [x, y], size: SCORE_SIZE, color: LABEL_COLOR)
      y += @dates.last.height + LINE_SPACING * 1.5
    end

    @level_buttons.select 1

    self.gui_controls += @positions + @scores + @names + @dates + @modes + [@message]

    back_button
  end

  def nav_buttons(y)
    x = 90
    options = { auto_center: [1, 0], size: SCORE_SIZE, shortcut: nil }

    @last_button = Button.new(">>", options.merge(at: [x, y], enabled: @score_from < OnlineHighScores::NUM_SCORES_STORED)) do
      @score_from = OnlineHighScores::NUM_SCORES_STORED - HIGH_SCORES_PER_PAGE
      update_scores
    end
    gui_controls << @last_button

    x -= gui_controls.last.width + LINE_SPACING

    @next_button = Button.new(">", options.merge(at: [x, y], enabled: @score_from < OnlineHighScores::NUM_SCORES_STORED)) do
      @score_from += 10
      update_scores
    end
    gui_controls << @next_button

    x -= gui_controls.last.width + LINE_SPACING

    @previous_button = Button.new("<", options.merge(at: [x, y], enabled: @score_from > 0)) do
      @score_from -= 10
      update_scores
    end
    gui_controls << @previous_button

    x -= gui_controls.last.width + LINE_SPACING

    @first_button = Button.new("<<", options.merge(at: [x, y], enabled: @score_from > 0)) do
      @score_from = 0
      update_scores
    end
    gui_controls << @first_button
  end

  def level; @level_buttons.value; end

  def update_scores
    high_scores = begin
      @message.string = t.label.best_local
      @message.color = LABEL_COLOR
      game.online_high_scores[level]
    rescue OnlineHighScores::NetworkError
      @message.string = t.label.network_failure
      @message.color = Color.red
      []
    end

    # Clear scores.
    HIGH_SCORES_PER_PAGE.times do |i|
      @positions[i].string = (@score_from + i + 1).to_s.rjust(POSITION_WIDTH)
      @scores[i].string = DEFAULT_SCORE
      @names[i].string = DEFAULT_SCORER
      @dates[i].string = DEFAULT_DATE
      @modes[i].string = DEFAULT_TEXT
    end

    # Fill in the scores that should be filled in.
    if high_scores.size >= @score_from
      high_scores[@score_from...(@score_from + HIGH_SCORES_PER_PAGE)].each_with_index do |score, i|
        @scores[i].string = score.score.to_s.rjust(SCORE_WIDTH)
        @names[i].string = score.name
        @dates[i].string = R18n.get.l score.time
        @modes[i].string = R18n.get.t.mutators[score.mode]
      end
    end

    # If the network is down or the local high score isn't in the list, then add it at the bottom.
    score, scorer, time, mode =
        user_data.high_score(level),
        user_data.high_scorer(level),
        user_data.high_score_time(level),
        user_data.high_score_mode(level)

    if score > 0
      @positions.last.string = game.online_high_scores.position_for(level, score, time).to_s.rjust(POSITION_WIDTH)
      @scores.last.string = score.to_s.rjust(SCORE_WIDTH)
      @names.last.string = scorer
      @dates.last.string = R18n.get.l time
      @modes.last.string = R18n.get.t.mutators[mode]
    else
      @positions.last.string = @scores.last.string = @names.last.string = @dates.last.string = @modes.last.string = ''
    end

    @next_button.enabled = @last_button.enabled = @score_from < (OnlineHighScores::NUM_SCORES_STORED - HIGH_SCORES_PER_PAGE)
    @previous_button.enabled = @first_button.enabled = @score_from > 0
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