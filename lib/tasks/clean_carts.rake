# frozen_string_literal: true

# Implemented with heroku scheduler --> destroy all cart_to_destroy
# (initially cart more than 2 days old)
# (currently cart more than 1 day old)
Rails.logger = Logger.new(STDOUT)

task clean_carts: :environment do
  orders = Order.cart_to_destroy

  new_csv = CSV.generate(headers: true, col_sep: ',') do |csv|
    csv << export_attributes = LineItem.new.attributes.keys
    orders.each do |order|
      order.line_items.each { |li| csv << export_attributes.map { |attr| li.send(attr) } }
    end
  end

  ContactMailer.with(csv: new_csv).line_items_csv.deliver_later

  orders.each(&:destroy)
end
