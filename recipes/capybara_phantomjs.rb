# ensures that phantomjs test can be run

node[:jenkins][:capybara_phantom][:packages].each do |pkg|
  package pkg
end if node[:jenkins][:capybara_phantom][:packages]