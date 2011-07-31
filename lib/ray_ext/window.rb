module Ray
  class Window
    class << self
      attr_reader :scaling

      protected
      def scaling=(scaling); @scaling = scaling; end
    end

    public
    def scaled_size
      size / self.class.scaling
    end
  end
end