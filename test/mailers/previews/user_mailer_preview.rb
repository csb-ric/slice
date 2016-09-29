# frozen_string_literal: true

# Allows emails to be viewed at /rails/mailers
class UserMailerPreview < ActionMailer::Preview
  def user_invited_to_project
    project_user = ProjectUser.where.not(invite_email: nil).first
    UserMailer.user_invited_to_project(project_user)
  end

  def user_added_to_project
    project_user = ProjectUser.where.not(invite_email: nil).first
    UserMailer.user_added_to_project(project_user)
  end

  def user_invited_to_site
    site_user = SiteUser.where.not(invite_email: nil).first
    UserMailer.user_invited_to_site(site_user)
  end

  def user_added_to_site
    site_user = SiteUser.where.not(invite_email: nil).first
    UserMailer.user_added_to_site(site_user)
  end

  def survey_completed
    sheet = Sheet.current.first
    UserMailer.survey_completed(sheet)
  end

  def sheet_unlock_request
    sheet_unlock_request = SheetUnlockRequest.current.first
    editor = User.first
    UserMailer.sheet_unlock_request(sheet_unlock_request, editor)
  end

  def sheet_unlocked
    sheet_unlock_request = SheetUnlockRequest.current.first
    project_editor = User.first
    UserMailer.sheet_unlocked(sheet_unlock_request, project_editor)
  end

  def export_ready
    export = Export.current.first
    UserMailer.export_ready(export)
  end

  def import_complete
    design = Design.current.first
    recipient = User.current.first
    UserMailer.import_complete(design, recipient)
  end

  # Updated
  def daily_digest
    recipient = User.current.first
    UserMailer.daily_digest(recipient)
  end

  def subject_randomized
    randomization = Randomization.where.not(subject_id: nil).first
    user = User.current.first
    UserMailer.subject_randomized(randomization, user)
  end

  def adverse_event_reported
    adverse_event = AdverseEvent.current.first
    recipient = User.current.first
    UserMailer.adverse_event_reported(adverse_event, recipient)
  end

  def password_expires_soon
    recipient = User.current.first
    UserMailer.password_expires_soon(recipient)
  end
end
