# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create demo user if it doesn't exist (development only)
if Rails.env.development?
  puts "👤 Creating demo user..."
  demo_user = User.find_or_create_by!(email: 'demo@mekarpad.com') do |user|
    user.name = 'Demo Author'
    user.bio = 'Demo account for testing'
  end
  puts "✅ Demo user created (email: demo@mekarpad.com)"
  puts ""
  puts "To login, generate OTP with:"
  puts "  rails runner \"User.find_by(email: 'demo@mekarpad.com').generate_otp!\""
end

puts "🎉 Seeding complete!"
