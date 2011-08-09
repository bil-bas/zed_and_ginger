require_relative "intro_scene"
require_relative "../intro/zed_essence_inside"

class IntroInside < IntroScene
  # FUDGING to use Player object in the intro.
  def_delegator :@maps, :floor, :floor_map
  def out_of_time?; false; end
  def elapsed; 0; end
  def inversion?; false; end
  def timer; self; end

  def setup(player_sheets)
    super()

    @maps = Maps.new(self, 0, :zed)

    tile = @maps.floor.tile_at_grid([0, 2])
    @ginger = Player.new(self, tile, tile.position + [0, 3], player_sheets[:ginger], :ginger)
    @ginger.apply_status :in_cutscene
    @ginger.velocity_x = 16

    @glow_entry_position = @ginger.position + [20, 0.0001]

    tile = @maps.floor.tile_at_grid([0, 2])
    @zed = Player.new(self, tile, tile.position + [0, 3], player_sheets[:zed], :zed)
    @zed.apply_status :in_cutscene

    @started_at = Time.now

    @cloned_sound = sound sound_path("zed_clone.ogg")
    @cloned_sound.volume = 30 * (user_data.effects_volume / 50.0)

    @zed_essence = nil

    ambient_music.pause
  end

  def clean_up
    ambient_music.play
  end

  def jump(cat)
    if cat.velocity_x == 0
      cat.velocity_x = 32
      cat.jump
    end
  end

  def update
    elapsed = Time.now - @started_at
    if elapsed > 12
      pop_scene_while {|s| s.is_a? IntroScene }
    elsif elapsed > 10
      fade_out
    elsif elapsed > 9
      jump @zed
    elsif elapsed > 8
      jump @ginger
    elsif elapsed > 7
      if @objects.include? @zed_essence
        @cloned_sound.play
        @zed_essence.save_tracker if @zed_essence.recording?
        remove_object @zed_essence
        @zed.pos = @ginger.pos
        @zed.explode_pixels(glow: true, color: ZedEssenceInside::COLOR, number: 2, gravity: 0, scale: 3,
                            velocity: [0, 0, 10], random_velocity: [20, 20, 20], shrink_duration: 3, fade_duration: 2)
      end
    elsif elapsed > 5.5
      @ginger.velocity_x = 0 if @ginger.velocity_x > 0
    elsif elapsed > 5
      jump @ginger
    elsif elapsed > 4
      @ginger.velocity_x = 0 if @ginger.velocity_x > 0
    elsif elapsed > 3.5
      jump @ginger
    elsif elapsed > 2.5
      @ginger.velocity_x = 0 if @ginger.velocity_x > 0
    elsif elapsed > 2
      unless @zed_essence
        @zed_essence = ZedEssenceInside.new(self, @glow_entry_position) #, state: :recording)
        @zed_essence.z += 30
      end
    end

    super()

    @visible_objects = (@objects + @particle_generator.particles).sort_by(&:z_order)
  end

  def render(win)
    background.draw_on(win)

    camera_view = win.view
    camera_view.y -= BORDER_WIDTH
    camera_view.x += 32
    win.with_view camera_view do
      @maps.wall.draw_on(win)
    end

    camera_view.y -= @maps.wall.to_rect.height
    win.with_view camera_view do
      @maps.floor.draw_on(win)
      @visible_objects.each {|o| o.draw_on(win) }
    end

    super(win)
  end
end
