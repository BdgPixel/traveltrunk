module AuthorizeNetLib
  require 'authorizenet'
  # include AuthorizeNet::API

  class Global
    def initialize
      @@api_login_id = ENV['AUTHORIZE_NET_API_LOGIN_ID']
      @@api_transaction_key = ENV['AUTHORIZE_NET_API_TRANSACTION_KEY']
      
      @@transaction = AuthorizeNet::API::Transaction.new(@@api_login_id, @@api_transaction_key, gateway: :sandbox)
    end

    def self.generate_random_id(string_uniqe)
      random_id = "#{string_uniqe}_#{SecureRandom.urlsafe_base64(10)}"
    end
  end

  # Customer Information Manager (CIM)
  class Customers < Global
    def create_profile(customer)
      request = AuthorizeNet::API::CreateCustomerProfileRequest.new

      request.profile = AuthorizeNet::API::CustomerProfileType.new
      request.profile.merchantCustomerId = customer[:merchant_customer_id]
      request.profile.email = customer[:email]
      request.profile.paymentProfiles = nil
      request.profile.shipToList = nil

      response = @@transaction.create_customer_profile(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_code = response.messages.messages.first.code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to create a new customer profile.'
      end

      response
    end

    def get_customer_profile(customer_profile_id)
      request = AuthorizeNet::API::GetCustomerProfileRequest.new
      request.customerProfileId = customer_profile_id

      response = @@transaction.get_customer_profile(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_code = response.messages.messages.first.code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), "Failed to get customer profile information with id #{request.customerProfileId}"
      end

      response.profile
    end

    def delete_payment_profile(customer_profile_id, customer_payment_profile_id)
      request = AuthorizeNet::API::DeleteCustomerPaymentProfileRequest.new
      request.customerProfileId = customer_profile_id 
      request.customerPaymentProfileId = customer_payment_profile_id 
      response = @@transaction.delete_customer_payment_profile(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_code = response_message.messages.first.code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), "Failed to delete payment profile with profile id #{customer_payment_profile_id} : #{response_message}"
      end

      response
    end
 end

  class RecurringBilling < Global
    def create_subscription(recurring_params)
      request = AuthorizeNet::API::ARBCreateSubscriptionRequest.new
      request.refId = recurring_params[:ref_id]

      request.subscription = AuthorizeNet::API::ARBSubscriptionType.new
      request.subscription.name = "#{recurring_params[:customer][:first_name]}#{recurring_params[:customer][:last_name]}"
      request.subscription.amount = recurring_params[:plan][:amount]
      request.subscription.trialAmount = 0.00

      request.subscription.paymentSchedule = AuthorizeNet::API::PaymentScheduleType.new
      request.subscription.paymentSchedule.interval = AuthorizeNet::API::PaymentScheduleType::Interval.new
      request.subscription.paymentSchedule.interval.length = recurring_params[:plan][:interval_length]
      request.subscription.paymentSchedule.interval.unit = recurring_params[:plan][:interval_unit]
      request.subscription.paymentSchedule.startDate = Time.now.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d")
      request.subscription.paymentSchedule.totalOccurrences = '9999'
      request.subscription.paymentSchedule.trialOccurrences = recurring_params[:plan][:trial_occurrences]
      
      request.subscription.payment = AuthorizeNet::API::PaymentType.new
      
      request.subscription.payment.creditCard = AuthorizeNet::API::CreditCardType.new
      request.subscription.payment.creditCard.cardNumber = recurring_params[:card][:credit_card]
      request.subscription.payment.creditCard.expirationDate = recurring_params[:card][:exp_card]
      request.subscription.payment.creditCard.cardCode = recurring_params[:card][:cvc]

      request.subscription.order = AuthorizeNet::API::OrderType.new
      request.subscription.order.invoiceNumber = recurring_params[:order][:invoice_number]
      request.subscription.order.description = 'Recurring Billing'

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

      response = @@transaction.create_subscription(request)
      
      if response != nil
        unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
          response_message = response.messages.messages.first.text
          response_error_code = response.messages.messages.first.code

          error_messages = {
            response_message: response_message,
            response_error_code: response_error_code
          }
          
          raise RescueErrorsResponse.new(error_messages), "Failed to create a subscription"
        end
      end

      response
    end

    def update_subscription(subscription_id, amount)
      request = AuthorizeNet::API::ARBUpdateSubscriptionRequest.new
      request.subscriptionId = subscription_id

      request.subscription = AuthorizeNet::API::ARBSubscriptionType.new
      request.subscription.amount = amount

      response = @@transaction.update_subscription(request)

      if response != nil
        unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
          response_message = response.messages.messages.first.code
          response_error_code = response.messages.messages.first.text

          error_messages = {
            response_message: response_message,
            response_error_code: response_error_code
          }

          raise RescueErrorsResponse.new(error_messages), 'Failed to update a subscription'
        end
      end

      response
    end

    def cancel_subscription(subscription_id, customer_profile_id, customer_payment_profile_id)
      request = AuthorizeNet::API::ARBCancelSubscriptionRequest.new
      request.subscriptionId = subscription_id
        
      response = @@transaction.cancel_subscription(request)

      if response != nil
        if response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
          customer = Customers.new
          delete_payment_profile = customer.delete_payment_profile(customer_profile_id, customer_payment_profile_id)
        end
      else
        response_message = response.messages.messages.first.text
        response_error_code = response_message.messages.first.code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to cancel a subscription.'
      end

      response  
    end
  end

  class PaymentTransactions < Global
    def charge_customer_profile(customer_profile_id, customer_payment_profile_id, amount)
      request = AuthorizeNet::API::CreateTransactionRequest.new
       
      request.transactionRequest = AuthorizeNet::API::TransactionRequestType.new()
      request.transactionRequest.amount = amount
      request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::AuthCaptureTransaction
      request.transactionRequest.profile = AuthorizeNet::API::CustomerProfilePaymentType.new
      request.transactionRequest.profile.customerProfileId = customer_profile_id
      request.transactionRequest.profile.paymentProfile = AuthorizeNet::API::PaymentProfile.new(customer_payment_profile_id)

      response = @@transaction.create_transaction(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_code = response.messages.messages.first.code

        error_messages = { 
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to charge customer profile.'
      end

      response
    end

    def charge(payment_params, customer_profile_params = nil)
      request = AuthorizeNet::API::CreateTransactionRequest.new
      request.refId = AuthorizeNetLib::Global.generate_random_id('ref')

      request.transactionRequest = AuthorizeNet::API::TransactionRequestType.new
      request.transactionRequest.amount = payment_params[:amount]

      request.transactionRequest.payment = AuthorizeNet::API::PaymentType.new

      request.transactionRequest.payment.creditCard = AuthorizeNet::API::CreditCardType.new
      request.transactionRequest.payment.creditCard.cardNumber = payment_params[:card_number]
      request.transactionRequest.payment.creditCard.expirationDate = payment_params[:exp_date]
      request.transactionRequest.payment.creditCard.cardCode = payment_params[:cvv]

      if customer_profile_params
        email = customer_profile_params['email']
        merchant_customer_id = customer_profile_params['merchant_customer_id']

        request.transactionRequest.customer = AuthorizeNet::API::CustomerType.new(nil, merchant_customer_id, email)

        request.transactionRequest.billTo = AuthorizeNet::API::CustomerAddressType.new
        request.transactionRequest.billTo.firstName = customer_profile_params['first_name']
        request.transactionRequest.billTo.lastName = customer_profile_params['last_name']
        request.transactionRequest.billTo.company = customer_profile_params['company']
        request.transactionRequest.billTo.address = customer_profile_params['address']
        request.transactionRequest.billTo.city = customer_profile_params['city']
        request.transactionRequest.billTo.state = customer_profile_params['state']
        request.transactionRequest.billTo.zip = customer_profile_params['zip']
        request.transactionRequest.billTo.country = customer_profile_params['country']
        request.transactionRequest.billTo.phoneNumber = nil
        request.transactionRequest.billTo.faxNumber = nil
      end

      request.transactionRequest.order = AuthorizeNet::API::OrderType.new(payment_params[:order][:invoice], payment_params[:order][:description])

      request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::AuthCaptureTransaction
      response = @@transaction.create_transaction(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text

        response_error_text, response_error_code = [response.transactionResponse.errors.errors.first.errorText, response.transactionResponse.errors.errors.first.errorCode] if response.transactionResponse

        # Check duplicate transaction
        # errorCode '11' as duplicate transaction
        response_error_text = 'Please wait several minutes for another transaction' if response_error_code.eql?('11')
        
        error_messages = { 
          response_message: response_message,
          response_error_text: response_error_text,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), response_error_code.eql?('11') ? '' : 'Failed to charge card.'
      end

      response
    end
    
    def refund_transaction(params_refund)
      request = AuthorizeNet::API::CreateTransactionRequest.new
      request.refId = params_refund[:ref_id]

      request.transactionRequest = AuthorizeNet::API::TransactionRequestType.new
      request.transactionRequest.amount = params_refund[:amount]

      request.transactionRequest.payment = AuthorizeNet::API::PaymentType.new
      request.transactionRequest.payment.creditCard = AuthorizeNet::API::CreditCardType.new
      request.transactionRequest.payment.creditCard.cardNumber = params_refund[:last_card_number]
      request.transactionRequest.payment.creditCard.expirationDate = params_refund[:exp_card]
      request.transactionRequest.payment.creditCard.cardCode = nil
      request.transactionRequest.refTransId = params_refund[:trans_id]

      request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::RefundTransaction
      response = @@transaction.create_transaction(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_text, response_error_code = [response.transactionResponse.errors.errors.first.errorText, response.transactionResponse.errors.errors.first.errorCode] if response.transactionResponse

        error_messages = { 
          response_message: response_message,
          response_error_text: response_error_text,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to refund a transaction.'
      end

      response
    end

    def void_transaction(params_refund)
      request = AuthorizeNet::API::CreateTransactionRequest.new
      request.refId = params_refund[:ref_id]
      request.transactionRequest = AuthorizeNet::API::TransactionRequestType.new()
      request.transactionRequest.refTransId = params_refund[:trans_id]
      request.transactionRequest.transactionType = AuthorizeNet::API::TransactionTypeEnum::VoidTransaction
      
      response = @@transaction.create_transaction(request)
    
      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_text, response_error_code = [response.transactionResponse.errors.errors.first.errorText, response.transactionResponse.errors.errors.first.errorCode] if response.transactionResponse

        error_messages = { 
          response_message: response_message,
          response_error_text: response_error_text,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to void the transaction.'
      end

      response
    end
  end

  class TransactionReporting < Global
    def get_transaction_details(trans_id)
      request = AuthorizeNet::API::GetTransactionDetailsRequest.new
      request.transId = trans_id

      response = @@transaction.get_transaction_details(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text
        response_error_code = response.messages.messages.first.code

        error_messages = {
          response_message: response_message,
          response_error_code: response_error_code
        }

        raise RescueErrorsResponse.new(error_messages), 'Failed to get transaction Details'
      end

      response
    end
  end

  class RescueErrorsResponse < StandardError
    attr_accessor :error_message

    def initialize(error_message)
      @error_message = error_message
    end
  end
end
