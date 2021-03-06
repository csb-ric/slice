# frozen_string_literal: true

module Pats
  module Categories
    # Allows project sheets to be filtered by variable category, and provides
    # methods to print out count and percent by site for a category.
    class Default
      attr_reader :project

      def initialize(project)
        @project = project
      end

      def variable
        @variable ||= project.variables.find_by(id: variable_id)
      end

      def label
        'Default Category'
      end

      def subquery
        nil
      end

      def css_class
        nil
      end

      def inverse
        false
      end

      def variable_id
        nil
      end

      def model
        if variable && variable.variable_type == 'checkbox'
          Response
        else
          SheetVariable
        end
      end

      def select_sheet_ids
        model
          .left_outer_joins(:domain_option)
          .where(variable: variable)
          .where(subquery)
          .select(:sheet_id)
      end

      def filter_sheets(sheets)
        if inverse
          sheets.where.not(id: select_sheet_ids)
        else
          sheets.where(id: select_sheet_ids)
        end
      end

      def compute_row(sheets)
        row = []
        row << row_label
        row += compute_overall_total_cells(sheets)
        row += compute_site_cells(sheets)
        row
      end

      def compute_row_means(sheets)
        row = []
        row << row_label
        row += compute_overall_total_cell_means(sheets)
        row += compute_site_cell_means(sheets)
        row
      end

      def row_label
        { value: label, class: css_class }
      end

      def compute_overall_total_cells(sheets)
        cell_count = count_subjects(filter_sheets(sheets))
        column_total_count = count_subjects(sheets)
        count_and_percent_cells(cell_count, column_total_count)
      end

      def compute_overall_total_cell_means(sheets)
        cells = []
        mean = Sheet.array_calculation(filter_sheets(sheets), @variable, 'array_mean')
        cells << { value: mean, class: [css_class, 'count'].compact }
        cells
      end

      def compute_site_cells(sheets)
        cells = []
        project.sites.each do |site|
          cell_count = count_subjects(filter_sheets(sheets).where(subjects: { site_id: site.id }))
          column_total_count = count_subjects(sheets.where(subjects: { site_id: site.id }))
          cells += count_and_percent_cells(cell_count, column_total_count)
        end
        cells
      end

      def compute_site_cell_means(sheets)
        cells = []
        project.sites.each do |site|
          filtered_sheets = filter_sheets(sheets).where(subjects: { site_id: site.id })
          mean = Sheet.array_calculation(filtered_sheets, @variable, 'array_mean')
          cells << { value: mean, class: [css_class, 'count'].compact }
        end
        cells
      end

      def compute_percent(numerator, denominator)
        "#{numerator * 100 / denominator} %"
      rescue
        '0 %'
      end

      def count_and_percent_cells(cell_count, column_total_count)
        cell_percent = compute_percent(cell_count, column_total_count)
        cells = []
        cells << { value: cell_count, class: [css_class, 'count'].compact }
        cells << { value: cell_percent, class: [css_class, 'percent'].compact }
        cells
      end

      def database_value(type_cast: 'numeric')
        field_one = "NULLIF(domain_options.value, '')::#{type_cast}"
        field_two = "NULLIF(#{model.table_name}.value, '')::#{type_cast}"
        "(CASE WHEN (#{field_one} IS NULL) THEN #{field_two} ELSE #{field_one} END)"
      end
    end
  end
end
