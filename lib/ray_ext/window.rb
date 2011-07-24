module Ray
  class Window
    extend Forwardable

    def_delegators :'self.class.user_data', :scaling, :scaling=

    class << self
      attr_accessor :user_data

      def scaling; user_data.scaling; end
    end

    def user_data
      self.class.user_data
    end

    def scaled_size
      size / user_data.scaling
    end
  end
end