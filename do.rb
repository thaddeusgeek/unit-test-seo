# coding: UTF-8

require 'csv'
require 'uri'
require 'webpage'
require 'mechanize'

require './common/basic.rb'
require './common/coding.rb' # ?
require './common/content.rb'
require './common/front.rb'
require './common/host.rb' # 未完成
require './common/link.rb'
require './common/strict.rb'

project = './project'
# path = File.dirname(__FILE__)
# project = ARGV[0] unless ARGV[0].nil?

Dir.new(project).each do |domain|
  begin

  next if domain == '.' or domain == '..'
  next if File.exists? File.join(project,domain,'skip') #若包含skip文件,则跳过整个文件夹不处理
  Dir.new(File.join(project,domain)).each do |host|
    next if host == '.' or host == '..'
    next if File.exists? File.join(project,domain,host,'skip') #若包含skip文件,则跳过整个文件夹不处理
    next if !File.exists? File.join(project,domain,host,'meta.csv') #不存在meta.csv文件 跳过
    meta_csv = File.join(project,domain,host,'meta.csv') 

    begin
      CSV.open(meta_csv).each { |row| }
    rescue CSV::MalformedCSVError
      puts "!!!!!#{meta_csv} is malformed"
      next
    end

    CSV.open(meta_csv).each do |row|
      items = row
      next if items[4].nil? || items[6].nil?

      meta = {}
      meta[:uri] = items[1]
      meta[:keywords] = items[5].split(',') # 返回一个 keywords 的数组
      meta[:keywords] = items[5] if items[6] == '\identical' #\identical标记表示和举例的一致
      meta[:title] = Regexp.new items[4]
      meta[:title] = items[3] if items[4] == '\identical' #\identical标记表示和举例的一致
      meta[:description] = items[7] if !items[7].nil?

      agent = Mechanize.new
      page = Webpage.new(agent.get(meta[:uri]).body)

      describe "#{meta[:uri]}" do
        it_behaves_like "基本页面", meta, page
        it_behaves_like "页面内容", meta, page
        it_behaves_like "前端规范", meta, page
        it_behaves_like "链接页面", meta, page
        it_behaves_like "增强页面", meta, page
      end
    end
  end

  rescue ArgumentError => ex
  # /usr/lib/ruby/1.9.1/csv.rb:2058:in `=~': invalid byte sequence in UTF-8 (ArgumentError)
  # !!!!!ERROR: invalid byte sequence in UTF-8 in DOMAIN huoche.com.cn!!!!!
    puts "!!!!!ERROR: #{ex.message} in DOMAIN #{domain}!!!!!"
  end
end
