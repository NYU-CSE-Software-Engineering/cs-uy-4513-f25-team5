#!/usr/bin/env ruby
# bin/coverage_test.rb

require 'fileutils'

# Parse command line argument
suite = ARGV[0]&.downcase

# Validate input
unless [nil, 'rspec', 'cucumber'].include?(suite)
  puts "Usage: ruby bin/coverage_test.rb [rspec|cucumber]"
  puts "  rspec     - Run only RSpec and show its coverage"
  puts "  cucumber  - Run only Cucumber and show its coverage"
  puts "  (no arg)  - Run both and show merged coverage (CI mode)"
  exit 1
end

# Clean coverage directory
puts "🧹 Cleaning coverage directory..."
FileUtils.rm_rf('coverage')

case suite
when 'rspec'
  puts "\n🧪 Running RSpec tests only...\n\n"
  system('RAILS_ENV=test bundle exec rspec') || exit(1)
  
when 'cucumber'
  puts "\n🥒 Running Cucumber tests only...\n\n"
  system('RAILS_ENV=test bundle exec cucumber --publish-quiet') || exit(1)
  
when nil
  puts "\n🚀 Running full test suite (CI mode)...\n"
  puts "=" * 60
  puts "Step 1: Running RSpec tests..."
  puts "=" * 60
  unless system('RAILS_ENV=test bundle exec rspec')
    puts "\n❌ RSpec tests failed!"
    exit(1)
  end
  
  puts "\n" + "=" * 60
  puts "Step 2: Running Cucumber tests..."
  puts "=" * 60
  unless system('RAILS_ENV=test bundle exec cucumber --publish-quiet')
    puts "\n❌ Cucumber tests failed!"
    exit(1)
  end
  
  puts "\n" + "=" * 60
  puts "✅ All tests passed! Final merged coverage above."
  puts "=" * 60
end

puts "\n📊 Coverage report: coverage/index.html"