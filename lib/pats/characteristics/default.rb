# frozen_string_literal: true

module Pats
  module Characteristics
    # Groups together a set of categories to be listed on tables and graphs.
    class Default
      attr_reader :project

      def initialize(project)
        @project = project
      end

      def variable
        @variable ||= project.variables.find_by(id: variable_id)
      end

      def label
        'Default Characteristic'
      end

      def variable_id
        nil
      end

      def categories
        []
      end
    end
  end
end
