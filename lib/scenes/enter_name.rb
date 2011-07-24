# encoding: UTF-8

class EnterName < Scene
  BLANK_CHAR = '.'
  MAX_CHARS = 3

  def setup(previous_scene, set_name_proc)
    @previous_scene, @set_name_proc = previous_scene, set_name_proc
    @heading = ShadowText.new("HIGH SCORE!", at: [21.25, 1.25], size: 12, color: Color.red)

    @entry = text BLANK_CHAR * MAX_CHARS, at: [35.625, 11.875], size: 11.25
    @entry_background = Polygon.rectangle([30, 12.5, 25, 9.375], Color.new(0, 0, 0, 200))

    @key_press_sound = sound sound_path("key_press.ogg")
  end

  def register
    # Enter the name.
    on :text_entered do |char|
      char = Ray::TextHelper.convert(char).upcase

      case char
        when 'A'..'Z', '0'..'9'
          first_blank_index = @entry.string.index(BLANK_CHAR)
          if first_blank_index
            name = @entry.string
            name[first_blank_index] = char
            @entry.string = name
            @key_press_sound.play
          end
      end
    end

    # Accept the name.
    [:return].each do |key_code|
      on(:key_press, key(key_code)) { accept_name }
    end

    # Delete last character.
    [:delete, :backspace].each do |key_code|
      on(:key_press, key(key_code)) { delete_last_char }
    end
  end

  def render(win)
    @previous_scene.render(win)

    win.with_view win.default_view do
      @heading.draw_on win
    end

    win.draw @entry_background

    win.with_view win.default_view do
      win.draw @entry
    end
  end

  def accept_name
    unless @entry.string.include? BLANK_CHAR
      @set_name_proc.call @entry.string
      @key_press_sound.play

      pop_scene
    end
  end

  def delete_last_char
    @entry.string.chars.reverse_each.with_index do |char, i|
      if char !=  BLANK_CHAR
        name = @entry.string
        name[MAX_CHARS - 1 - i] = BLANK_CHAR
        @entry.string = name

        @key_press_sound.play

        break
      end
    end
  end
end
