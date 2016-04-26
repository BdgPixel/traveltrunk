namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"
  task :test_scheduler => :environment do
    response = {"name"=>"teguh"}
    PaymentProcessorMailer.send_request_params_webhook(response).deliver_now
    puts "done."
  end

  desc "This task is called for synchronize all transaction"
  task :sync_per_day => :environment do
    transaction = Transaction.sync_per_day
    puts transaction.inspect
  end 
end
