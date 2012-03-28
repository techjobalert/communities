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
        amount = (t.amount - t.amount * 0.039 - 30) - t.amount * 0.03

        p g = GATEWAY.transfer(amount, seller, :subject => "Money from Orthodontics360", :note => "Here is the money owed to you.")
        if g.params["Ack"] == 'Success'
          if t.close
            Rails.logger.info "---- Status ok."
          else
            Rails.logger.info "---- !!! Money sended, but transaction not closed!"
          end
        else
          raise 'Transfer. Error. Not Success'
        end
      end
    end
  end
end