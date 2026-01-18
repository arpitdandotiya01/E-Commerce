# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin = User.find_or_create_by!(email: 'admin@example.com')
admin.password = 'password'
admin.role = :admin
admin.save!

# Create regular user
user = User.find_or_create_by!(email: 'user@example.com')
user.password = 'password'
user.role = :user
user.save!

# Create products
Product.find_or_create_by!(name: 'Laptop') do |product|
  product.price = 1000.00
  product.stock_quantity = 10
end

Product.find_or_create_by!(name: 'Phone') do |product|
  product.price = 500.00
  product.stock_quantity = 20
end

Product.find_or_create_by!(name: 'Tablet') do |product|
  product.price = 300.00
  product.stock_quantity = 15
end
