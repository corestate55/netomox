require 'bundler/gem_tasks'
require 'rake/clean'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new
rescue LoadError
  task :spec do
    warn 'RSpec is disabled'
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    warn 'RuboCop is disabled'
  end
end

FIG_DIR = './fig'.freeze
desc 'make UML class diagram'
task :fig do
  directory FIG_DIR
  %w[diff_view dsl graphdb topology].each do |dir|
    ['', '-s'].each do |opt|
      file = opt.empty? ? dir : "#{dir}#{opt.tr('-', '_')}"
      file = "#{FIG_DIR}/#{file}.puml"
      sh "bundle exec rb2puml #{opt} -d ./lib/netomox/#{dir} > #{file}"
    end
  end
  FileList["#{FIG_DIR}/*.puml"].each do |puml|
    sh "plantuml #{puml}"
  end
end

CLOBBER.include("#{FIG_DIR}/*.puml")
CLEAN.include('**/*~')
