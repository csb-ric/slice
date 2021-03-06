# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ENTFailures
      # Defines ENT Eligibility Failure
      class ENTEligibility2 < Default
        def label
          'AT indication not nocturnal symptoms'
        end

        # 'ciw_ent_eligibility_not_met_yes'
        def variable_id
          14326
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
