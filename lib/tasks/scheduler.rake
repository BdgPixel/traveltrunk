namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"
  task :test_scheduler => :environment do
    response = {"name"=>"teguh"}
    PaymentProcessorMailer.delay.send_request_params_webhook(response)
    puts "done."
  end

  desc "This task is called for synchronize all transaction"
  task :sync_per_day => :environment do
    transaction = Transaction.sync_per_day
    puts transaction.inspect
  end

  desc "This task is called for check pending reservations"
  task :check_pending_reservations => :environment do
    reservations = Reservation.check_pending_reservations
    puts reservations.inspect
  end 
end
