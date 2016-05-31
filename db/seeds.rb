# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin_users_count = User.where(admin: true).count

if admin_users_count.zero?
  user = User.new(email: 'admin@traveltrunk.us', password: ENV['ADMIN_PASSWORD'],
    password_confirmation: ENV['ADMIN_PASSWORD'], admin: true)
  
  user.confirm
  
  if user.save
    puts "Admin user created: #{user.to_json}"
  else
    puts "Error creating admin user: #{user.errors.full_messages}"
  end
else
  puts 'Admin user already exists'
end