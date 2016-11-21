# frozen_string_literal: true

# Stores a value response for a single response question on a sheet.
class SheetVariable < ApplicationRecord
  # Concerns
  include Formattable, Valuable

  # Scopes
  scope :with_files, -> { joins(variable: :design_options).where(variables: { variable_type: 'file' }).where.not(response_file: [nil, '']) }

  # Model Validation
  validates :sheet_id, presence: true

  # Model Relationships
  belongs_to :sheet, touch: true
  belongs_to :user
  belongs_to :domain_option
  has_many :grids

  def self.not_empty
    where.not(id: all_empty.select(:id))
  end

  def self.all_empty
    where(response_file: [nil, ''], response: [nil, ''], domain_option_id: nil)
      .where(id: grids_empty.select(:id))
      .where(id: responses_empty.select(:id))
  end

  def self.grids_empty
    left_outer_joins(:grids).having('COUNT(grids) = 0').group(:id)
  end

  def self.responses_empty
    left_outer_joins(:responses).having('COUNT(responses) = 0').group(:id)
  end
end
