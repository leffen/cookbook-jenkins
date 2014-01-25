# nessesary libraries for capybara-webkit install

node[:jenkins][:capybara_webkit][:packages].each do |pkg|
  package pkg
end if node[:jenkins][:capybara_webkit][:packages]
