module Ray
  class Animation

    # Ensure that if we change duration, that the effective progress is the same.
    # Example:
    #   duration == 10s, progress == 0.5
    #   duration increased to 15s
    #   duration == 15s, progress = 0.5
    #   (in vanilla, progress would be 0.333 because 5s had been completed)
    def duration=(duration)
      @duration = duration

      @end_time = @start_time + @duration if running?
    end
  end
end