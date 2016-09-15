class InviteDeviseMailer < Devise::Mailer
  def invitation_instructions(record, token, opts={})
    # Determine a way to set object -- likely through a query of some type
    @current_user = User.find record.invited_by_id
    @resource = record
    @token = token
    super
  end
end
