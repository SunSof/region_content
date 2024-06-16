# Load all seed files from the seeds directory
Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |seed|
  puts "Loading seed file: #{seed}"
  load seed
end
