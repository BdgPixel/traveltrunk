class AuthorizeParamsMailer < ApplicationMailer
  def create(params)
    @response_params = params
    
    mail to: 'teguh@41studio.com', subject: 'Params webhook'
  end
end
