require 'rake'

desc "Create a new post in _posts"
task :new, :title do |t, args|
  title = args.title
  filename = "_posts/#{Time.now.strftime('%Y-%m-%d')}-#{title}.markdown"

  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: "
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "---"
  end

  puts "Created a new post: #{filename}"
end
