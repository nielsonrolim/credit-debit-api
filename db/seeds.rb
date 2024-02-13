# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Account.find_or_create_by(id: 1, credit_limit: 100000)
Account.find_or_create_by(id: 2, credit_limit: 80000)
Account.find_or_create_by(id: 3, credit_limit: 1000000)
Account.find_or_create_by(id: 4, credit_limit: 10000000)
Account.find_or_create_by(id: 5, credit_limit: 500000)
