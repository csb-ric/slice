# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines unknown race variable and associated subquery.
      class Unknown < Default
        def label
          'Unknown or not reported'
        end

        def variable_name
          'ciw_race'
        end

        def subquery
          "NULLIF(value, '')::numeric IN (1, 2, 3, 4, 5, 98)"
        end

        def css_class
          'lighter'
        end

        def inverse
          true
        end
      end
    end
  end
end