require 'bundler'
Bundler.setup

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Runtests"
task default: :test
