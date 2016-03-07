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
    def create_profile
      request = AuthorizeNet::API::CreateCustomerProfileRequest.new
      # validation mode = testMode, none, liveMode
      # request.validationMode = 'testMode'
      request.profile = AuthorizeNet::API::CustomerProfileType.new

      request.profile.merchantCustomerId = 'customer[:merchant_customer_id]'
      # request.profile.description = 'yuhuu'
      request.profile.email = customer[:email]
      request.profile.paymentProfiles = nil
      request.profile.shipToList = nil

      response = @@transaction.create_customer_profile(request)

      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
        puts "Successfully created a customer profile with id: #{response.customerProfileId}"
      else
        puts response.messages.messages[0].text
         "Failed to create a new customer profile"
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
    def create_subscription
      request = AuthorizeNet::API::ARBCreateSubscriptionRequest.new
      request.refId = DateTime.now.to_s[-8]
      request.subscription = AuthorizeNet::API::ARBSubscriptionType.new
      request.subscription.name = 'Jhono yuhuu'
      request.subscription.paymentSchedule = AuthorizeNet::API::PaymentScheduleType.new
      request.subscription.paymentSchedule.interval = AuthorizeNet::API::PaymentScheduleType::Interval.new('7', 'days')
      request.subscription.paymentSchedule.startDate = (DateTime.now).to_s[0...10]
      request.subscription.paymentSchedule.totalOccurrences = '1'
      # request.subscription.paymentSchedule.trialOccurrences = '1'

      random_amount = ((SecureRandom.random_number + 1) * 150).round(2)
      request.subscription.amount = random_amount
      # request.subscription.trialAmount = 0.00
      request.subscription.payment = AuthorizeNet::API::PaymentType.new
      request.subscription.payment.creditCard = AuthorizeNet::API::CreditCardType.new('370000000000002', '0320', '123')

      request.subscription.order = AuthorizeNet::API::OrderType.new('invoiceNumber123', 'description123')
      request.subscription.customer = AuthorizeNet::API::CustomerDataType.new(AuthorizeNet::API::CustomerTypeEnum::Individual, 'yuhuu2529', 'yuhuu6541@mail.com')
      request.subscription.billTo = AuthorizeNet::API::NameAndAddressType.new('Yuhuu', 'Jhono', nil, nil, nil, nil, nil, nil)

      response = @@transaction.create_subscription(request)
      
      if response != nil
        if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
          puts "Successfully created a subscription #{response.subscriptionId}"
        else
          puts response.messages.messages[0].code
          puts response.messages.messages[0].text
          raise 'Failed to create a subscription'
        end
      end
      return response
    end
  end

  class PaymentTransactions < Global
    def charge(credit_params)
      request = AuthorizeNet::API::CreateTransactionRequest.new
      request.transactionRequest = AuthorizeNet::API::TransactionRequestType.new

      request.transactionRequest.amount = credit_params[:amount]
      # request.transactionRequest.amount = ((SecureRandom.random_number + 1 ) * 150 ).round(2)
      request.transactionRequest.payment = AuthorizeNet::API::PaymentType.new
      # request.transactionRequest.payment.creditCard = AuthorizeNet::API::CreditCardType.new('4242424242424242','0220','123') 
      request.transactionRequest.payment.creditCard = AuthorizeNet::API::CreditCardType.new(credit_params[:card_number], credit_params[:exp_date], credit_params[:cvv])

      request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::AuthOnlyTransaction

      response = @@transaction.create_transaction(request)
      
      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
        puts "Successfully charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"
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
