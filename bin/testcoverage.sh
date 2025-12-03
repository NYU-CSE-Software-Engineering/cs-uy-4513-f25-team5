#!/bin/bash
set -e

echo "=== Cleaning old coverage data ==="
rm -rf coverage/

echo ""
echo "=== Running RSpec ==="
TEST_SUITE=RSpec bundle exec rspec

echo ""
echo "=== RSpec Coverage Results ==="
if [ -f coverage/.resultset.json ]; then
  echo "✓ RSpec coverage generated"
  ruby -e "require 'json'; data = JSON.parse(File.read('coverage/.resultset.json')); puts \"Test Suites: #{data.keys.join(', ')}\""
else
  echo "✗ No RSpec coverage found!"
  exit 1
fi

echo ""
echo "=== Running Cucumber ==="
TEST_SUITE=Cucumber bundle exec cucumber --publish-quiet

echo ""
echo "=== Merged Coverage Results ==="
if [ -f coverage/.resultset.json ]; then
  echo "✓ Merged coverage exists"
  ruby -e "require 'json'; data = JSON.parse(File.read('coverage/.resultset.json')); puts \"Test Suites: #{data.keys.join(', ')}\""
else
  echo "✗ No merged coverage found!"
  exit 1
fi

echo ""
echo "=== Final Coverage Report ==="
ruby -e "
require 'simplecov'
SimpleCov.coverage_dir 'coverage'
result = SimpleCov::ResultMerger.merged_result
result.format!
puts \"Total Coverage: #{result.covered_percent.round(2)}%\"
puts \"Covered Lines: #{result.covered_lines} / #{result.total_lines}\"
puts \"\"
puts 'Open coverage/index.html to view detailed report'
"

echo ""
echo "=== Done ==="
echo "Coverage report: coverage/index.html"