# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# User Data
users = [
  { username: "The Log", level: 99, xp: 200 },
  { username: "Tempestissimo", level: 69, xp: 700 },
  { username: "Ani67", level: 67, xp: 67 },
  { username: "Jour", level: 79, xp: 77 },
  { username: "Shinramyeon", level: 77, xp: 99 }
]

users.each do |attrs|
  User.find_or_create_by!(username: attrs[:username]) do |u|
    u.level = attrs[:level]
    u.xp = attrs[:xp]
  end
end
