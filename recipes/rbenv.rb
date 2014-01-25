
# requires build_essentials

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

# extendedsuggestion ['2.1.0','2.0.0-p353','1.9.3-p484', 'jruby-1.7.2']
rubies = node['jenkins']['rbenv']['rubies'] || ['2.0.0-p353']

rubies.each do |rubie|
  rbenv_ruby rubie
end