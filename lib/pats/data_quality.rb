# frozen_string_literal: true

require 'pats/core'
require 'pats/categories'
require 'pats/characteristics'

module Pats
  # Exports data quality statistics for subjects on PATS.
  module DataQuality
    include Pats::Core

    def data_quality_tables(project)
      tables = []
      tables << psg_overall_study_quality_table(project)
      tables << signal_quality_grades_table(project)
      tables
    end

    def data_quality_graphs(project)
      graphs = []
      graphs << signal_quality_grades_graph(project)
      graphs
    end

    def psg_overall_study_quality_table(project)
      characteristic = Pats::Characteristics.for('psg-overall-study-quality', project)
      build_table(characteristic, psg_report_sheets(project))
    end

    def signal_quality_grades_table(project)
      characteristic = Pats::Characteristics.for('signal-quality-grades', project)
      build_table_means(characteristic, psg_report_sheets(project))
    end

    def build_table_means(characteristic, sheets)
      {
        title: compute_title_means(characteristic),
        header: compute_header_means(characteristic),
        footer: [],
        rows: characteristic.categories.collect { |category| category.compute_row_means(sheets) }
      }
    end

    def compute_title_means(characteristic)
      compute_title(characteristic)
    end

    def compute_header_means(characteristic)
      header = []
      header << ['', { text: 'Overall' }] + characteristic.project.sites.collect { |s| { text: s.short_name } }
      header << [characteristic.label, { text: 'Mean', class: 'count' }] + [{ text: 'Mean', class: 'count' }] * characteristic.project.sites.count
      header
    end

    def signal_quality_grades_graph(project)
      sheets = psg_report_sheets(project)
      characteristic = Pats::Characteristics.for('signal-quality-grades', project)
      graph = {}
      categories = characteristic.categories.collect(&:label)
      series = []
      project.sites.each do |site|
        data = []
        characteristic.categories.each do |category|
          filtered_sheets = category.filter_sheets(sheets).where(subjects: { site_id: site.id })
          mean = Sheet.array_calculation(filtered_sheets, category.variable, 'array_mean')
          data << mean.to_f
        end
        series << { name: site.short_name, data: data }
      end
      graph[:categories] = categories
      graph[:chart_type] = 'bar'
      graph[:series] = series
      graph[:title] = characteristic.label
      graph[:yaxis] = 'Mean'
      graph[:yaxis_min] = 1
      graph[:yaxis_max] = 5
      graph
    end
  end
end
