# frozen_string_literal: true

module Pats
  module Core
    def design_id(project)
      design = project.designs.find_by(short_name: 'CIW')
      design.id
    end

    def category_time_format
      "%d %b '%y"
    end

    def category_time_month_format
      "%b '%y"
    end

    def generic_table(project, start_date, type, objects, attribute: :created_at, date_variable: nil, breakdown: :month, by_distinct_subject: true)
      return generic_table_by_month(project, start_date, type, objects, attribute: attribute, date_variable: date_variable, by_distinct_subject: by_distinct_subject) if breakdown == :month
      table = {}

      header = []
      header_row = ['Week Starting On'] + project.sites.collect(&:short_name) + ['Week Total']
      header << header_row

      footer = []
      footer_row = ["Total #{type}"]
      footer_total = 0
      project.sites.each do |site|
        current_objects = objects.where(subjects: { site_id: site.id })
        current_count = by_distinct_subject ? count_subjects(current_objects) : current_objects.count
        footer_total += current_count
        footer_row << current_count
      end
      footer_row << footer_total
      footer << footer_row

      rows = []
      current_week = start_date.beginning_of_week
      last_week = Time.zone.today.beginning_of_week
      total = 0
      while current_week <= last_week
        total_count = 0
        row = [current_week.strftime(category_time_format)]
        project.sites.each do |site|
          site_objects = objects.where(subjects: { site_id: site.id })
          current_objects =
            if date_variable
              site_objects.joins(:sheet_variables).where("DATE(#{sheet_variable_cast_for_date}) BETWEEN ? AND ?", current_week.beginning_of_week, current_week.end_of_week).where(sheet_variables: { variable_id: date_variable.id })
            else
              site_objects.where("DATE(#{site_objects.table_name}.#{attribute}) BETWEEN ? AND ?", current_month.beginning_of_week, current_month.end_of_week)
            end
          current_count = by_distinct_subject ? count_subjects(current_objects) : current_objects.count
          total_count += current_count
          row << current_count
        end
        row << total_count
        rows << row
        total += total_count
        current_week += 1.week
      end

      table[:total] = total
      table[:header] = header
      table[:footer] = footer
      table[:rows] = rows
      table[:title] = "#{type} By Week"
      table
    end

    def generic_table_by_month(project, start_date, type, objects, attribute: :created_at, date_variable: nil, by_distinct_subject: true)
      table = {}

      header = []
      header_row = ['Month'] + project.sites.collect(&:short_name) + ['Month Total']
      header << header_row

      footer = []
      footer_row = ["Total #{type}"]
      footer_total = 0
      project.sites.each do |site|
        current_objects = objects.where(subjects: { site_id: site.id })
        current_count = by_distinct_subject ? count_subjects(current_objects) : current_objects.count
        footer_total += current_count
        footer_row << current_count
      end
      footer_row << footer_total
      footer << footer_row

      rows = []
      current_month = start_date.beginning_of_month
      last_month = Time.zone.today.beginning_of_month
      total = 0
      while current_month <= last_month
        total_count = 0
        row = [current_month.strftime(category_time_month_format)]
        project.sites.each do |site|
          site_objects = objects.where(subjects: { site_id: site.id })
          current_objects = if date_variable
                          site_objects.joins(:sheet_variables).where("DATE(#{sheet_variable_cast_for_date}) BETWEEN ? AND ?", current_month.beginning_of_month, current_month.end_of_month).where(sheet_variables: { variable_id: date_variable.id })
                        else
                          site_objects.where("DATE(#{site_objects.table_name}.#{attribute}) BETWEEN ? AND ?", current_month.beginning_of_month, current_month.end_of_month)
                        end
          current_count = by_distinct_subject ? count_subjects(current_objects) : current_objects.count
          total_count += current_count
          row << current_count
        end
        row << total_count
        rows << row
        total += total_count
        current_month += 1.month
      end

      table[:total] = total
      table[:header] = header
      table[:footer] = footer
      table[:rows] = rows
      table[:title] = "#{type} By Month"
      table
    end

    def ciws(project)
      design_id = design_id(project)
      project.sheets.where(design_id: design_id, missing: false)
    end

    def screened_sheets(project)
      ciws(project)
    end

    def consented_sheets(project)
      design_id = design_id(project)
      # answering "1: Yes" to #29 question (Informed Consent) (i.e. "# Consented")
      # variable_id = 14297
      variable = project.variables.find_by(name: 'ciw_complete_informed_consent')
      variable_id = variable.id

      # `ciw_consent_date` is date the consent happened.
      sheet_scope = SheetVariable.left_outer_joins(:domain_option).where(variable_id: variable_id).where(database_value_for_variable_equals(1)).select(:sheet_id)
      project.sheets.where(id: sheet_scope, design_id: design_id, missing: false)
    end

    def database_value_for_variable_equals(value, type_cast: 'numeric')
      field_one = "NULLIF(domain_options.value, '')::#{type_cast}"
      field_two = "NULLIF(sheet_variables.value, '')::#{type_cast}"
      "(CASE WHEN (#{field_one} IS NULL) THEN #{field_two} ELSE #{field_one} END) #{value.present? ? "= #{value}" : 'IS NULL'}"
    end

    def eligible_sheets(project, value: '1')
      design_id = design_id(project)
      # answering "1: Yes" to #31 question (eligible for baseline) (i.e. "# Eligible to Continue to Baseline")
      # variable_id = 14299
      variable = project.variables.find_by(name: 'ciw_eligible_for_baseline')
      variable_id = variable.id

      sheet_scope = SheetVariable.left_outer_joins(:domain_option).where(variable_id: variable_id).where(database_value_for_variable_equals(value)).select(:sheet_id)
      project.sheets.where(id: sheet_scope, design_id: design_id, missing: false)
    end

    def randomized_sheets(project)
      ciws(project).where(subjects: { id: randomizations(project).select(:subject_id) })
    end

    def randomizations(project)
      randomization_scheme_id = project.randomization_schemes.first.id
      # randomization_scheme_id = 12
      project.randomizations.where(randomization_scheme_id: randomization_scheme_id).joins(:subject).merge(Subject.current)
    end

    def psg_report_sheets(project)
      design = project.designs.find_by(short_name: 'PSG-RPT')
      project.sheets.where(design: design, missing: false)
    end

    def by_week(sheets, start_date)
      data = []
      total_count = 0
      current_week = start_date.beginning_of_week
      last_week = Time.zone.today.beginning_of_week
      while current_week <= last_week
        total_count += count_subjects(sheets.where("DATE(#{sheets.table_name}.created_at) BETWEEN ? AND ?", current_month.beginning_of_week, current_month.end_of_week))
        data << total_count
        current_week += 1.week
      end
      data
    end

    def by_week_of_attribute(sheets, start_date, variable)
      data = []
      total_count = 0
      current_week = start_date.beginning_of_week
      last_week = Time.zone.today.beginning_of_week
      while current_week <= last_week
        week_sheets = sheets.joins(:sheet_variables).where("DATE(#{sheet_variable_cast_for_date}) BETWEEN ? AND ?", current_week.beginning_of_week, current_week.end_of_week).where(sheet_variables: { variable_id: variable.id })
        total_count += count_subjects(week_sheets)
        data << total_count
        current_week += 1.week
      end
      data
    end

    def by_month(sheets, start_date, attribute: :created_at, running_total: true, by_distinct_subject: true)
      data = []
      total_count = 0
      current_month = start_date.beginning_of_month - 1.month
      last_month = Time.zone.today.beginning_of_month
      while current_month <= last_month
        current_objects = sheets.where("DATE(#{sheets.table_name}.#{attribute}) BETWEEN ? AND ?", current_month.beginning_of_month, current_month.end_of_month)
        current_count = by_distinct_subject ? count_subjects(current_objects) : current_objects.count
        total_count += current_count
        data << (running_total ? total_count : current_count)
        current_month += 1.month
      end
      data
    end

    def by_month_of_attribute(sheets, start_date, variable, running_total: true, by_distinct_subject: true)
      data = []
      total_count = 0
      current_month = start_date.beginning_of_month - 1.month
      last_month = Time.zone.today.beginning_of_month
      while current_month <= last_month
        current_objects = sheets.joins(:sheet_variables).where("DATE(#{sheet_variable_cast_for_date}) BETWEEN ? AND ?", current_month.beginning_of_month, current_month.end_of_month).where(sheet_variables: { variable_id: variable.id })
        current_count = by_distinct_subject ? count_subjects(current_objects) : current_objects.count
        total_count += current_count
        data << (running_total ? total_count : current_count)
        current_month += 1.month
      end
      data
    end

    def count_subjects(sheets)
      sheets.select(:subject_id).distinct.count(:subject_id)
    end

    def generate_categories(start_date)
      weeks = []
      current_week = start_date.beginning_of_week
      last_week = Time.zone.today.beginning_of_week
      while current_week <= last_week
        weeks << current_week.strftime(category_time_format)
        current_week += 1.week
      end
      weeks
    end

    def generate_categories_months(start_date)
      months = []
      current_month = start_date.beginning_of_month - 1.month
      last_month = Time.zone.today.beginning_of_month
      while current_month <= last_month
        months << current_month.strftime(category_time_month_format)
        current_month += 1.month
      end
      months
    end

    def sheet_variable_cast_for_date
      "NULLIF(sheet_variables.value, '')"
    end
  end
end
