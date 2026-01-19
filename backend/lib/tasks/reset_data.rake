namespace :db do
  desc "Reset all orders and reset product stock"
  task reset_ecommerce_data: :environment do
    puts "Resetting data..."

    # 1. Delete all order items and orders
    puts "Deleting all order items and orders..."
    OrderItem.delete_all
    Order.delete_all
    puts "All orders have been deleted."

    # 2. Reset stock for all products
    initial_stock = 100
    puts "Resetting product stock to #{initial_stock}..."
    Product.update_all(stock_quantity: initial_stock)
    puts "Product stock has been reset."

    puts "✅ Data reset complete."
  end
end