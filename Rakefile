
$LOAD_PATH.unshift './lib'
require 'lambda'

task :test do
  require 'minitest/autorun'
  # begin; require 'turn'; rescue LoadError; end
  Dir.glob("test/**/*_test.rb").each { |test| require "./#{test}" }
end

task :pry do
  require 'pry'
  Lambda.pry
end

task :default => :test



