puts 'Creating admin'

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