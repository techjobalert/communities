class PaymentNotification < ActiveRecord::Base
  serialize :params
  after_create :change_transaction_state

  private
    def change_transaction_state
      transaction = OrderTransaction.where("authorization = ? AND order_id = ?", transaction_id, order_id).first
      if transaction.present?
        case status
          when "Completed"
            transaction.pay
          when "Canceled_Reversal"
          when "Denied"
            transaction.cancel
          when "Expired"
          when "Failed"
            transaction.cancel
          when "Pending"
          when "Processed"
          when "Refunded"
          when "Reversed"
          when "Voided"
            transaction.cancel
        end
      end
    end
end
