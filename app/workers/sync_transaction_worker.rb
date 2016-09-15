class SyncTransactionWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 1

  def perform(transaction_id)
    Transaction.sync_specific_id(transaction_id)
  end
end