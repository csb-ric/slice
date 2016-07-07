# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for eligible subjects on PATS.
  module Eligible
    include Pats::Core

    def eligible_graph(project, start_date)
      graph = {}
      categories = generate_categories(start_date)
      series = []
      date_variable = project.variables.find_by_name 'ciw_eligibility_date'
      project.sites.each do |site|
        series << {
          name: site.short_name,
          data: by_week_of_attribute(eligible_to_continue_to_baseline_sheets(project).where(subjects: { site_id: site.id }), start_date, date_variable)
        }
      end
      graph[:total] = count_subjects(eligible_to_continue_to_baseline_sheets(project))
      graph[:categories] = categories
      graph[:series] = series
      graph[:title] = 'Cumulative Eligible'
      graph[:yaxis] = '# Eligible'
      graph[:xaxis] = 'Week Starting On'
      graph
    end

    def eligible_table(project, start_date)
      objects = eligible_to_continue_to_baseline_sheets(project)
      date_variable = project.variables.find_by_name 'ciw_eligibility_date'
      generic_table(project, start_date, 'Eligible', objects, date_variable: date_variable)
    end

    def eligible_to_continue_to_baseline_sheets(project, response: '1')
      design_id = design_id(project)
      # answering "1: Yes" to #31 question (eligible for baseline) (i.e. "# Eligible to Continue to Baseline")
      # variable_id = 14299
      variable = project.variables.find_by_name 'ciw_eligible_for_baseline'
      variable_id = variable.id

      sheet_scope = SheetVariable.where(variable_id: variable_id, response: response).select(:sheet_id)
      project.sheets.where(id: sheet_scope, design_id: design_id, missing: false)
    end

    def eligible_to_continue_to_baseline_sheets_print(project)
      sheets_by_site_print(project, eligible_to_continue_to_baseline_sheets(project), 'Eligible to Continue To Baseline')
    end
  end
end
