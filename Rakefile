require 'rake'

desc "Create a new post in _posts"
task :new do
  title = ARGV[1].dup
  post = "_posts/#{Time.now.strftime('%Y-%m-%d')}-#{title}.markdown"

  open(post, 'w') do |p|
    p.puts "---"
    p.puts "layout: post"
    p.puts "title: "
    p.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    p.puts "---"
  end

  puts "Created a new post: #{post}"
end
