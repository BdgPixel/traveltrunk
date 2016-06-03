module AuthorizeNetLib
  require 'authorizenet'

  class Global
    def initialize
      api_login_id = ENV['AUTHORIZE_NET_API_LOGIN_ID']
      api_transaction_key = ENV['AUTHORIZE_NET_API_TRANSACTION_KEY']
      gateway = Rails.env.eql?('production') ? :production : :sandbox

      @transaction = AuthorizeNet::API::Transaction.new(api_login_id, api_transaction_key, gateway: gateway)
    end

    def self.generate_random_id(string_uniqe)
      random_id = "#{string_uniqe}_#{SecureRandom.urlsafe_base64(10)}"
    end
  end

  # Customer Information Manager (CIM)
  class Customers < Global
    def create_profile(customer_params)
      request = AuthorizeNet::API::CreateCustomerProfileRequest.new

      request.profile = AuthorizeNet::API::CustomerProfileType.new(
        customer_params[:merchant_customer_id], nil, customer_params[:email], nil, nil
      )
      
      response = @transaction.create_customer_profile(request)
      error_params, message_params = [response.messages, 'Failed to create a new customer profile.']
      RescueErrorsResponse::get_error_messages(error_params, message_params)

      response
    end

    def get_customer_profile(customer_profile_id)
      request = AuthorizeNet::API::GetCustomerProfileRequest.new(nil, nil, customer_profile_id)

      response = @transaction.get_customer_profile(request)
      error_params, message_params = [response.messages, "Failed to get customer profile information with id #{customer_profile_id}"]
      RescueErrorsResponse::get_error_messages(error_params, message_params)

      response.profile
    end

    def get_customer_payment_profile(customer_profile_id, customer_payment_profile_id)
      request = AuthorizeNet::API::GetCustomerPaymentProfileRequest.new
      request.customerProfileId = customer_profile_id
      request.customerPaymentProfileId = customer_payment_profile_id

      response = @transaction.get_customer_payment_profile(request)
      error_params, message_params = [response.messages, "Failed to get customer payment profile information with id #{customer_payment_profile_id}"]

      RescueErrorsResponse::get_error_messages(error_params, message_params)

      response
    end

    def delete_customer_profile(customer_profile_id)
      request = AuthorizeNet::API::DeleteCustomerProfileRequest.new
      request.customerProfileId = customer_profile_id

      response = @transaction.delete_customer_profile(request)
      error_params, message_params = [response.messages, "Failed to delete customer with customer profile id #{request.customerProfileId}"]
      RescueErrorsResponse::get_error_messages(error_params, message_params)

      response
    end

    def delete_payment_profile(customer_profile_id, customer_payment_profile_id)
      request = AuthorizeNet::API::DeleteCustomerPaymentProfileRequest.new(nil, nil, customer_profile_id, customer_payment_profile_id)

      response = @transaction.delete_customer_payment_profile(request)
      error_params, message_params = [response.messages, "Failed to delete payment profile with profile id #{customer_payment_profile_id}"]
      RescueErrorsResponse::get_error_messages(error_params, message_params)
      
      response
    end
 end

  # The RecurringBilling class is responsible for subscription.
  class RecurringBilling < Global
    def create_subscription(recurring_params)
      request = AuthorizeNet::API::ARBCreateSubscriptionRequest.new
      request.refId = recurring_params[:ref_id]

      customer_params = recurring_params[:customer]
      full_name = "#{customer_params[:first_name]}#{customer_params[:last_name]}"
      plan_params = recurring_params[:plan]

      request.subscription = AuthorizeNet::API::ARBSubscriptionType.new(full_name, nil, plan_params[:amount], 0.00)
      request.subscription.paymentSchedule = AuthorizeNet::API::PaymentScheduleType.new(
        AuthorizeNet::API::PaymentScheduleType::Interval.new(
          plan_params[:interval_length], 
          plan_params[:interval_unit]
        ),
        plan_params[:start_date],
        '9999',
        '0'
      )

      card_params = recurring_params[:card]

      request.subscription.payment = AuthorizeNet::API::PaymentType.new(
        AuthorizeNet::API::CreditCardType.new(
          card_params[:credit_card], card_params[:exp_card], card_params[:cvc]
        )
      )

      request.subscription.order = AuthorizeNet::API::OrderType.new(
        recurring_params[:order][:invoice_number], 'Recurring Billing'
      )
      
      request.subscription.customer = AuthorizeNet::API::CustomerDataType.new(
        AuthorizeNet::API::CustomerTypeEnum::Individual,
        customer_params[:customer_id],
        customer_params[:email]
      )
      
      request.subscription.billTo = AuthorizeNet::API::NameAndAddressType.new(
        customer_params[:first_name],
        customer_params[:last_name],
        customer_params[:company],
        customer_params[:address],
        customer_params[:city],
        customer_params[:state],
        customer_params[:zip],
        customer_params[:country]
      )

      response = @transaction.create_subscription(request)
      error_params, message_params = [response.messages, "Failed to create a subscription."]

      RescueErrorsResponse::get_error_messages(error_params, message_params) if response

      response
    end

    def update_subscription(subscription_id, amount)
      request = AuthorizeNet::API::ARBUpdateSubscriptionRequest.new(
        nil, nil, subscription_id, AuthorizeNet::API::ARBSubscriptionType.new(nil, nil, amount)
      )

      response = @transaction.update_subscription(request)
      error_params, message_params = [response.messages, "Failed to update a subscription."]
      
      RescueErrorsResponse::get_error_messages(error_params, message_params) if response

      response
    end

    def cancel_subscription(subscription_id, customer_profile_id, customer_payment_profile_id = nil)
      request = AuthorizeNet::API::ARBCancelSubscriptionRequest.new
      request.subscriptionId = subscription_id

      response = @transaction.cancel_subscription(request)

      if response != nil
        if response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
          customer = Customers.new
          if customer_payment_profile_id
            delete_payment_profile = customer.delete_payment_profile(customer_profile_id, customer_payment_profile_id)
          end
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

    def self.cancel_other_subscriptions(current_subscription_id, customer_profile_id)
      api_login_id = ENV['AUTHORIZE_NET_API_LOGIN_ID']
      api_transaction_key = ENV['AUTHORIZE_NET_API_TRANSACTION_KEY']
      gateway = Rails.env.eql?('development') ? :sandbox : :production

      transaction = AuthorizeNet::API::Transaction.new(api_login_id, api_transaction_key, gateway: gateway)

      customer_authorize = AuthorizeNetLib::Customers.new
      customer_profile = customer_authorize.get_customer_profile(customer_profile_id);0

      customer_profile.paymentProfiles.each do |payment_profile|
        payment_profile_id = payment_profile.customerPaymentProfileId

        payment_profile_response = customer_authorize.get_customer_payment_profile(customer_profile_id, payment_profile_id)
        subscription_ids = payment_profile_response.paymentProfile.subscriptionIds.subscriptionId.to_a

        subscription_ids.each do |subscription_id|
          unless subscription_id.eql?(current_subscription_id)
            request = AuthorizeNet::API::ARBCancelSubscriptionRequest.new

            request.subscriptionId = subscription_id
            response = transaction.cancel_subscription(request)
          end
        end

        unless subscription_ids.include?(current_subscription_id)
          sleep 3
          customer_authorize.delete_payment_profile(customer_profile_id, payment_profile_id)
        end
      end
    end

    def get_subscription_status(subscription_id)
      request = AuthorizeNet::API::ARBGetSubscriptionStatusRequest.new
      request.subscriptionId = subscription_id
      
      response = @transaction.get_subscription_status(request)
      error_params, message_params = [response.messages, "Failed to get a subscriptions status."]
      
      RescueErrorsResponse::get_error_messages(error_params, message_params) if response

      response.status
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

      response = @transaction.create_transaction(request)

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
      response = @transaction.create_transaction(request)

      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        response_message = response.messages.messages.first.text

        response_error_text, response_error_code = [response.transactionResponse.errors.errors.first.errorText, response.transactionResponse.errors.errors.first.errorCode] if response.transactionResponse

        # Check duplicate transaction, errorCode '11' as duplicate transaction
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
      response = @transaction.create_transaction(request)

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
      
      response = @transaction.create_transaction(request)
    
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
    def get_settled_batch_list(first_date = nil, last_date = nil)
      request = AuthorizeNet::API::GetSettledBatchListRequest.new

      if first_date && last_date
        request.firstSettlementDate = first_date
        request.lastSettlementDate = last_date
        request.includeStatistics = true
      end

      response = @transaction.get_settled_batch_list(request)

      error_params, message_params = [response.messages, "Failed to fetch settled batch list."]
      RescueErrorsResponse::get_error_messages(error_params, message_params)
      response.batchList.batch if response.batchList
    end

    def get_transaction_list(batch_id)
      request = AuthorizeNet::API::GetTransactionListRequest.new
      request.batchId = batch_id

      response = @transaction.get_transaction_list(request)
      error_params, message_params = [response.messages, "Failed to get Transaction list."]
      RescueErrorsResponse::get_error_messages(error_params, message_params)

      response.try(:transactions).try(:transaction)
    end

    def get_transaction_details(trans_id)
      request = AuthorizeNet::API::GetTransactionDetailsRequest.new
      request.transId = trans_id

      response = @transaction.get_transaction_details(request)
      error_params, message_params = [response.messages, "Failed to get transaction Details."]

      response_message = error_params.messages.first
      
      if !response_message.code.eql?('E00040') && !response_message.text.eql?("The record cannot be found.")
        RescueErrorsResponse::get_error_messages(error_params, message_params)

        response
      end
    end
  end

  class RescueErrorsResponse < StandardError
    attr_accessor :error_message

    def initialize(error_message)
      @error_message = error_message
    end

    def self.get_error_messages(error_params, message_params)
      unless error_params.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        message = error_params.messages.first
        
        error_messages = {
          response_message: message.text,
          response_error_code: message.code
        }
        
        raise RescueErrorsResponse.new(error_messages), message.text
      end
    end
  end
end
