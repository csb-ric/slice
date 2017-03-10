# frozen_string_literal: true

# Links a set of tasks to a randomization.
class RandomizationTask < ApplicationRecord
  # Relationships
  belongs_to :randomization
  belongs_to :task, dependent: :destroy
end
