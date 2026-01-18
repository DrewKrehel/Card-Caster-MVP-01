# lib/tasks/sample_data.rake
require "faker"

desc "Fill the database with sample Card Caster data"
task sample_data: :environment do
  starting = Time.now

  puts "Cleaning database..."

  Project.destroy_all
  User.destroy_all

  puts "Creating users..."

  users = []

  5.times do |i|
    username = Faker::Internet.unique.username(specifier: 4..12).downcase

    users << User.create!(
      email: "#{username}@example.com",
      password: "password",
      username: username,
      bio: Faker::Lorem.paragraph(sentence_count: 3),
      private: [true, false].sample
    )
  end

  puts "Creating projects..."

  users.each do |user|
    3.times do
      user.projects.create!(
        project_name: Faker::Game.unique.title,
        summary: Faker::Lorem.paragraph(sentence_count: 2)
      )
    end
  end

  ending = Time.now

  puts "Sample data created in #{(ending - starting).round(2)} seconds"
  puts "Users: #{User.count}"
  puts "Projects: #{Project.count}"
end

