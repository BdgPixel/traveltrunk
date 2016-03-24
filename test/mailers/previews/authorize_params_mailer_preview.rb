# Preview all emails at http://localhost:3000/rails/mailers/authorize_params_mailer
class AuthorizeParamsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/authorize_params_mailer/create
  def create
    AuthorizeParamsMailer.create
  end

end
