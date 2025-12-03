unless ENV['NOCOVERAGE']
  require 'simplecov'
  require 'simplecov-console'

  SimpleCov.command_name ENV['TEST_SUITE'] || 'Tests'
  
  SimpleCov.minimum_coverage 70
  SimpleCov.start 'rails' do
    # Exclude test files
    add_filter '/spec/'
    add_filter '/features/'
    add_filter '/test/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/vendor/'
    add_filter '/bin/'
    
    # REMOVE THIS LINE - only track files that are actually loaded by tests
    # track_files '{app,lib}/**/*.rb'
    
    # Critical: Enable result merging
    use_merging true
    merge_timeout 3600
    
    enable_coverage :branch
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
end