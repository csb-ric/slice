# frozen_string_literal: true

# Generates sheet coverage tag, and also links back to sheet index
module SheetsHelper
  def coverage_helper(sheet, placement = 'right')
    content_tag(:span, "#{sheet.percent}%",
                class: "label label-coverage #{sheet.coverage}",
                rel: 'tooltip',
                data: { container: 'body', placement: placement },
                title: sheet.out_of)
  end

  def filter_link(count, design, variable, value, event_id: nil)
    params = { design_id: design.id }
    search_tokens = []
    search_tokens << "events:#{event_id}" if event_id.present?
    search_tokens << "#{variable.name}:#{convert_value(value)}" if variable
    params[:search] = search_tokens.join(' ')
    url = project_sheets_path design.project, params
    link_to_if count.present?, count || '-', url, target: '_blank'
  end

  def convert_value(value)
    case value
    when ':any'
      'any'
    when ':missing'
      'missing'
    when ':blank'
      'blank'
    else
      value
    end
  end
end
