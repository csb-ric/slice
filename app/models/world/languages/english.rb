# frozen_string_literal: true

module World
  module Languages
    class English < Default # :nodoc:
      def initialize
        @code = :en
        @names = {
          en: "English",
          es: "Inglés"
        }
      end
    end
  end
end
