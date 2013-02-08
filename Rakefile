require 'rake'
#require 'rake/gempackagetask'
require 'rubygems/package_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |spec|
    spec.name = "svn2git"
    spec.summary = "A tool for migrating svn projects to git"
    spec.authors = ["James Coglan", "Kevin Menard"]
    spec.homepage = "https://www.negativetwenty.net/redmine/projects/svn2git"
    spec.email = "nirvdrum@gmail.com"
  end
  Jeweler::GemcutterTasks.new
  
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
    
# 
# spec = Gem::Specification.new do |spec| 
#   
#   spec.version = "1.1.0"
#   spec.platform = Gem::Platform::RUBY
#   
#   
#   spec.require_path = "lib"
#   spec.files = FileList["lib/**/*"].to_a
#   spec.autorequire = "lib/svn2git.rb"
#   spec.bindir = "bin"
#   spec.executables = ["svn2git"]
#   spec.default_executable = "svn2git"
#   
#   
#   
#   
#   spec.test_files = FileList["test/**/*"].to_a
#   spec.has_rdoc = true
#   spec.extra_rdoc_files = ["README"]
#   spec.rdoc_options << "--main" << "README" << '--line-numbers' << '--inline-source'
# end
#  
# Rake::GemPackageTask.new(spec) do |pkg| 
#   pkg.need_tar = true 
# end
# 
