# encoding: utf-8
namespace :paypal do
  desc "Try to transfer money"
  task :transfer => :environment do
    puts "Transfer in progress, please be patient ..."
    transactions = OrderTransaction.where(:state => "paid")

    unless transactions.any?
      puts  'Nothing to transfer' and return
    end

    transactions.each do |t|
      seller = t.order.user.paypal_account
      if seller.present?
        amount = ((t.amount - t.amount * 0.039 - 30) - t.amount * 0.03).to_i

        p g = GATEWAY.transfer(amount, seller, :subject => "Money from Orthodontics360", :note => "Here is the money owed to you.")
        if g.params["Ack"] == 'Success'
          if t.update_attributes(:state => 'closed', :paid_to_seller => amount)
            p "---- Status ok."
          else
            p "---- !!! Money sended, but transaction not closed!"
          end
        else
          raise 'Transfer. Error. Not Success'
        end
      else
        p "---- Seller does't have a PayPal account"
      end
    end
  end
end