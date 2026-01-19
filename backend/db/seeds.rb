# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the `bin/rails db:seed` command (or created alongside the database with `db:setup`).

# Clear existing data to prevent duplicates on re-seeding
puts "Clearing old data..."
OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
User.destroy_all

# Create Admin User
puts "Creating Admin User..."
User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

# Create Regular User
puts "Creating Regular User..."
User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  admin: false
)

puts "Users created."

# Create Products
puts "Creating Products..."
Product.create!([
  { name: 'Laptop', price: 1200.00, stock_quantity: 50, active: true },
  { name: 'Mouse', price: 25.00, stock_quantity: 200, active: true },
  { name: 'Keyboard', price: 75.00, stock_quantity: 150, active: true },
  { name: 'Monitor', price: 300.00, stock_quantity: 100, active: true },
  { name: 'Webcam', price: 50.00, stock_quantity: 80, active: false } # Inactive product
])

puts "Products created."
puts "✅ Seed data created successfully!"
puts "---"
puts "Credentials:"
puts "  Admin: admin@example.com / password"
puts "  User:  user@example.com / password"