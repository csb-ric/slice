# frozen_string_literal: true

# Files can be uploaded and attached to adverse events
class AdverseEventFile < ActiveRecord::Base
  # Uploaders
  mount_uploader :attachment, GenericUploader

  # Model Validation
  validates :project_id, :user_id, :adverse_event_id, :attachment, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :adverse_event, touch: true
  belongs_to :user

  # Model Methods

  def name
    attachment_identifier
  end

  def pdf?
    extension == 'pdf'
  end

  def image?
    %w(png jpg jpeg gif).include?(extension)
  end

  def extension
    attachment.file.extension.to_s.downcase
  end
end
