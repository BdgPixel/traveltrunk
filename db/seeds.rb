puts 'Creating admin'

admin_users_count = User.where(admin: true).count

if admin_users_count.zero?
  password = ENV['ADMIN_PASSWORD'] || '12345678'

  user = User.new(email: 'admin@traveltrunk.us', password: password,
    password_confirmation: password, admin: true)

  if user.save
    puts "Admin user created"
  else
    puts "Error creating admin user: #{user.errors.full_messages}"
  end
else
  puts 'Admin user already exists'
end
