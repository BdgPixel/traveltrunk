module AuthorizeNetLib
  # Customer Information Manager (CIM)

  require 'authorizenet'
  # include AuthorizeNet::API

  class Global
    def initialize
      @@api_login_id = '7gMRQp555ys3'
      @@api_transaction_key = '96R8396EWSkz8etd'
      @@transaction = AuthorizeNet::API::Transaction.new(@@api_login_id, @@api_transaction_key, gateway: :sandbox)
    end

    def self.genrate_random_id(string_uniqe)
      random_id = "#{string_uniqe}_#{SecureRandom.urlsafe_base64(10)}"
    end
  end

  class Customers < Global
    def create_profile(customer)
      request = AuthorizeNet::API::CreateCustomerProfileRequest.new
      # validation mode = testMode, none, liveMode
      # request.validationMode = 'testMode'
      request.profile = AuthorizeNet::API::CustomerProfileType.new

      request.profile.merchantCustomerId = customer[:merchant_customer_id]
      # request.profile.description = 'yuhuu'
      request.profile.email = customer[:email]
      request.profile.paymentProfiles = nil
      request.profile.shipToList = nil

      # Dummy data
      # request.profile.merchantCustomerId = 'jdoe123'
      # request.profile.email = 'John2@mail.com'
      # request.profile.paymentProfiles = nil
      # request.profile.shipToList = nil

      response = @@transaction.create_customer_profile(request)

      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
        puts "Successfully created a customer profile with id: #{response.customerProfileId}"
      else
        response_message = response.messages.messages[0].text
        response_error_code = response.messages.messages[0].code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to create a new customer profile.'
      end

      return response
    end

    def get_customer_profile(customer_profile_id)
      request = AuthorizeNet::API::GetCustomerProfileRequest.new
      request.customerProfileId = customer_profile_id

      response = @@transaction.get_customer_profile(request)

      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum.Ok
        puts "Successfully retrieved a customer with profile id is #{response.customerProfileId} and whose customer id is #{response.profile.merchantCustomerId}"

        response.profile.paymentProfiles.each do |paymentProfile|
          puts "Payment Profile ID #{paymentProfile.customerPaymentProfileId}"
          puts "Payment Details:"
          if paymentProfile.billTo != nil
            puts "Last Name #{paymentProfile.billTo.lastName}"
            puts "Address #{paymentProfile.billTo.address}"
          end
        end

        response.profile.shipToList.each do |ship|
          puts "Shipping Details"
          puts "First Name #{ship.firstName}"
          puts "Last Name #{ship.lastName}"
          puts "Adress #{ship.adress}"
          puts "Customer Address IDAdress #{ship.customerAddressId}"
        end

      else
        response_message = response.messages.messages[0].text
        response_error_code = response.messages.messages[0].code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), "Failed to get customer profile information with id #{request.customerProfileId}"
      end

      return response
    end

    def create_payment_profile(customerProfileId = '39737024')
      request = AuthorizeNet::API::CreateCustomerPaymentProfileRequest.new
      payment = AuthorizeNet::API::PaymentType.new(AuthorizeNet::API::CreditCardType.new('370000000000002', '0320'))
      profile = AuthorizeNet::API::CustomerPaymentProfileType.new(nil, nil, payment, nil, nil)

      request.paymentProfile = profile
      request.customerProfileId = customerProfileId

      response = @@transaction.create_customer_payment_profile(request)

      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
        puts "Successfully created a customer payment profile with id: #{response.customerPaymentProfileId}"
      else
        puts "Failed to create a new customer payment profile: #{response.messages.messages[0].text}"
      end
      return response
    end
  end

  class RecurringBilling < Global
    def create_subscription(recurring_params)
      request = AuthorizeNet::API::ARBCreateSubscriptionRequest.new
      request.refId = recurring_params[:ref_id]

      request.subscription = AuthorizeNet::API::ARBSubscriptionType.new
      request.subscription.name = "#{recurring_params[:customer][:first_name]}#{recurring_params[:customer][:last_name]}"
      request.subscription.amount = recurring_params[:plan][:amount]

      request.subscription.paymentSchedule = AuthorizeNet::API::PaymentScheduleType.new
      request.subscription.paymentSchedule.interval = AuthorizeNet::API::PaymentScheduleType::Interval.new
      request.subscription.paymentSchedule.interval.length = recurring_params[:plan][:interval_length]
      request.subscription.paymentSchedule.interval.unit = recurring_params[:plan][:interval_unit]
      request.subscription.paymentSchedule.startDate = recurring_params[:plan][:star_date]
      request.subscription.paymentSchedule.totalOccurrences = recurring_params[:plan][:total_occurrences]
      

      request.subscription.payment = AuthorizeNet::API::PaymentType.new
      
      request.subscription.payment.creditCard = AuthorizeNet::API::CreditCardType.new
      request.subscription.payment.creditCard.cardNumber = recurring_params[:card][:credit_card]
      request.subscription.payment.creditCard.expirationDate = recurring_params[:card][:exp_card]
      request.subscription.payment.creditCard.cardCode = recurring_params[:card][:cvc]

      request.subscription.order = AuthorizeNet::API::OrderType.new
      request.subscription.order.invoiceNumber = recurring_params[:order][:invoice_number]
      request.subscription.order.description = recurring_params[:order][:description]

      request.subscription.customer = AuthorizeNet::API::CustomerDataType.new
      request.subscription.customer.type = AuthorizeNet::API::CustomerTypeEnum::Individual
      request.subscription.customer.id = recurring_params[:customer][:customer_id]
      request.subscription.customer.email = recurring_params[:customer][:email]

      request.subscription.billTo = AuthorizeNet::API::NameAndAddressType.new
      request.subscription.billTo.firstName = recurring_params[:customer][:first_name]
      request.subscription.billTo.lastName = recurring_params[:customer][:last_name]
      request.subscription.billTo.company = recurring_params[:customer][:company]
      request.subscription.billTo.address = recurring_params[:customer][:address]
      request.subscription.billTo.city = recurring_params[:customer][:city]
      request.subscription.billTo.state = recurring_params[:customer][:state]
      request.subscription.billTo.zip = recurring_params[:customer][:zip]
      request.subscription.billTo.country = recurring_params[:customer][:country]

      # dummy data
      # request.refId = DateTime.now.to_s[-8]
      # request.subscription.name = 'Jhono yuhuu'
      # request.subscription.paymentSchedule.interval = AuthorizeNet::API::PaymentScheduleType::Interval.new('7', 'days')
      # request.subscription.paymentSchedule.startDate = (DateTime.now).to_s[0...10]
      # request.subscription.paymentSchedule.totalOccurrences = '1'
      # request.subscription.paymentSchedule.trialOccurrences = '1'
      # random_amount = ((SecureRandom.random_number + 1) * 150).round(2)
      # request.subscription.amount = random_amount
      # request.subscription.trialAmount = 0.00
      # request.subscription.payment.creditCard = AuthorizeNet::API::CreditCardType.new('370000000000002', '0320', '123')
      # request.subscription.order = AuthorizeNet::API::OrderType.new('invoiceNumber123', 'description123')
      # request.subscription.customer = AuthorizeNet::API::CustomerDataType.new(AuthorizeNet::API::CustomerTypeEnum::Individual, 'yuhuu2529', 'yuhuu6541@mail.com')
      # request.subscription.billTo = AuthorizeNet::API::NameAndAddressType.new('Yuhuu', 'Jhono', nil, nil, nil, nil, nil, nil)

      response = @@transaction.create_subscription(request)
      
      if response != nil
        if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
          puts "Successfully created a subscription #{response.subscriptionId}"
        else
          puts response.messages.messages[0].code
          puts response.messages.messages[0].text

          response_message = response.messages.messages[0].text
          response_error_code = response.messages.messages[0].code

          error_messages = {
            response_message: response_message,
            response_error_code: response_error_code
          }
          
          raise RescueErrorsResponse.new(error_messages), 'Failed to create a subscription'
        end
      end
      return response
    end

    def update_subscription(recurring_params)
      request = AuthorizeNet::API::ARBUpdateSubscriptionRequest.new
      request.subscriptionId = recurring_params[:subscription_id]
      request.subscription = AuthorizeNet::API::ARBSubscriptionType.new
      request.subscription.payment = AuthorizeNet::API::PaymentType.new

      request.subscription.payment.creditCard = AuthorizeNet::API::CreditCardType.new
      request.subscription.payment.creditCard.cardNumber = recurring_params[:card][:credit_card]
      request.subscription.payment.creditCard.expirationDate = recurring_params[:card][:exp_card]
      request.subscription.payment.creditCard.cardCode = recurring_params[:card][:cvc]

      response = @@transaction.update_subscription(request)

      if response != nil
        if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
          puts "Successfully updated a subscription"
          puts response.messages.messages[0].code
          puts response.messages.messages[0].text
        else
          puts response.messages.messages[0].code
          puts response.messages.messages[0].text

          response_message = response.messages.messages[0].code
          response_error_code = response.messages.messages[0].text

          error_messages = {
            response_message: response_message,
            response_error_code: response_error_code
          }

          raise RescueErrorsResponse.new(error_messages), 'Failed to get a subscriptions status'
        end

      end

      return response
    end

    # def cancel_subscription(subscription_id, ref_id = nil)
    #   request = AuthorizeNet::API::ARBCancelSubscriptionRequest.new
    #   request.refId = ref_id
    #   request.subscriptionId = subscription_id

    #   response = @@transaction.cancel_subscription(request)

    #   if response != nil
    #     if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
    #       puts 'Successfully cancelled a subscription'
    #     end
    #   else
    #     response_message = response.messages.messages[0].text
    #     response_error_code = response_message.messages[0].code

    #     puts response_message
    #     puts response_error_code

    #     error_messages = {
    #       response_message: response_message,
    #       response_error_code: response_error_code
    #     }

    #     raise RescueErrorsResponse.new(error_messages), 'Failed to cancel a subscription.'
    #   end

    #   return response  
    # end

    def get_subscription_status(subscription_id, ref_id = '')
      request = AuthorizeNet::API::ARBGetSubscriptionStatusRequest.new
      request.refId = ref_id
      request.subscriptionId = subscription_id

      response = @@transaction.get_subscription_status(request)

      if response != nil
        if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
          puts "Successfully got subscription status #{response.status}"
        else
          response_message = response.messages.messages[0].text
          response_error_code = response.messages.messages[0].code

          puts response_message
          puts response_error_code

          error_messages = {
            response_message: response_message,
            response_error_code: response_error_code
          }

          raise RescueErrorsResponse.new(error_messages), 'Failed to get a subscriptions status'
        end
      end

      return response
    end

  end

  class PaymentTransactions < Global
    def charge(credit_params = nil)
      request = AuthorizeNet::API::CreateTransactionRequest.new
      request.refId = AuthorizeNetLib::Global.genrate_random_id('ref')
      request.transactionRequest = AuthorizeNet::API::TransactionRequestType.new

      # request.transactionRequest.amount = credit_params[:amount]
      request.transactionRequest.amount = ((SecureRandom.random_number + 1 ) * 150 ).round(2)
      request.transactionRequest.payment = AuthorizeNet::API::PaymentType.new
      request.transactionRequest.payment.creditCard = AuthorizeNet::API::CreditCardType.new('4242424242424242','0220','123') 
      # request.transactionRequest.payment.creditCard = AuthorizeNet::API::CreditCardType.new(credit_params[:card_number], credit_params[:exp_date], credit_params[:cvv])

      request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::AuthOnlyTransaction

      response = @@transaction.create_transaction(request)
      
      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
        puts "Successfully charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"
        puts "refId #{response.refId}"
        puts "transId #{response.transactionResponse.transId}"
        # puts "reftransId #{response.transactionResponse.refTransId}"
      else
        response_message = response.messages.messages[0].text

        response_error_text, response_error_code = [response.transactionResponse.errors.errors[0].errorText, response.transactionResponse.errors.errors[0].errorCode] if response.transactionResponse

        # Check duplicate transaction
        # errorCode '11' as duplicate transaction
        response_error_text = 'Please wait several minutes for another transaction' if response_error_code.eql?('11')

        puts response_message
        puts response_error_text
        # puts response.transactionResponse.errors.errors[0].errorText
        
        error_messages = { 
          response_message: response_message,
          response_error_text: response_error_text,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), response_error_code.eql?('11') ? '' : 'Failed to charge card.'
      end

      return response
    end
    
  end

  class RescueErrorsResponse < StandardError
    attr_accessor :error_message

    def initialize(error_message)
      @error_message = error_message
    end
  end
end
