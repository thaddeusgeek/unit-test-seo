
require 'csv'

proj_path = './project'
regexp_path = './regexp'

Dir.new(proj_path).each do |domain|
  next if domain == '.' || domain ==  '..' || domain.match(/\.bak/) 
  next if ['163', 'leju', 'test', 'youdao'].include?(domain)
  Dir.new("#{proj_path}/#{domain}").each do |host|
    next if host == '.' || host == '..' 
    next if !Dir.exists?("#{proj_path}/#{domain}/#{host}")
    if !Dir.exists?("#{regexp_path}/#{host}")
      Dir.mkdir("#{regexp_path}/#{host}")
    end
    reg_200 = File.open("#{regexp_path}/#{host}/200", 'w')
    reg_301 = File.open("#{regexp_path}/#{host}/301", 'w')

    meta_csv = "#{proj_path}/#{domain}/#{host}/meta.csv"
    begin
      CSV.open(meta_csv).each { |row| }
    rescue CSV::MalformedCSVError
      puts meta_csv
      next
    end
    CSV.open(meta_csv).each do |row|
      reg_200.puts(row[2]) if row[2]
    end

    redirect = "#{proj_path}/#{domain}/#{host}/redirects"
    File.new(redirect).each do |line|
      items = line.split
      reg_301.puts(items[1]) if items[1]
    end
  end
end
      
