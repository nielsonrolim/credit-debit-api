# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Account.create(id: 1, credit_limit: 100_000) unless Account.exists?(id: 1)
Account.create(id: 2, credit_limit: 80_000) unless Account.exists?(id: 2)
Account.create(id: 3, credit_limit: 1_000_000) unless Account.exists?(id: 3)
Account.create(id: 4, credit_limit: 10_000_000) unless Account.exists?(id: 4)
Account.create(id: 5, credit_limit: 500_000) unless Account.exists?(id: 5)
