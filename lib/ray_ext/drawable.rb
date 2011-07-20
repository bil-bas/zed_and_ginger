module Ray
  class Drawable
    def skew_x(skew)
      self.matrix = matrix.multiply_by! Matrix.skew_x(skew)
    end

    def skew_y(skew)
      self.matrix = matrix.multiply_by! Matrix.skew_y(skew)
    end
  end
end