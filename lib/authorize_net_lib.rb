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
  end

  class Customers < Global
    # def initialize
    #   @@api_login_id = '7gMRQp555ys3'
    #   @@api_transaction_key = '96R8396EWSkz8etd'
    #   @@transaction = AuthorizeNet::API::Transaction.new(@@api_login_id, @@api_transaction_key, gateway: :sandbox)
    # end

    def create_profile
      request = AuthorizeNet::API::CreateCustomerProfileRequest.new
      request.profile = AuthorizeNet::API::CustomerProfileType.new

      request.profile.merchantCustomerId = "yuhuu#{rand(10000).to_s}"
      request.profile.description = 'yuhuu'
      request.profile.email = "yuhuu#{rand(10000).to_s}@mail.com"
      request.profile.paymentProfiles = nil
      request.profile.shipToList = nil

      response = transaction.create_customer_profile(request)

      if response.messages.resultCode == AuthorizeNet::API::MessageTypeEnum::Ok
        puts "Successfully created a customer profile with id: #{response.customerProfileId}"
      else
        puts response.messages.messages[0].text
        raise "Failed to create a new customer profile"
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

end
