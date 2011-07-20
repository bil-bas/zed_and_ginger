module Ray
  class Matrix
    class << self
      def skew_x(skew)
        s = skew.to_f
        new [
            1, s, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
        ]
      end

      def skew_y(skew)
        s = skew.to_f
        new [
            1, 0, 0, 0,
            s, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
        ]
      end
    end
  end
end