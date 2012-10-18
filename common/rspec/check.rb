# coding: utf-8

# require 'uri'
require 'mechanize'
require './basic.rb'

regexp_path = './regexp';

class Meta
  attr_accessor :title, :keywords, :description
   
  def initialize(line) # line from regexp_file
    items = line.split
    @title       = items[2]
    @keywords    = items[5]
    @description = items[7]
  end
end

class Page
  attr_accessor :title, :keywords, :description
   
  def initialize(line)
    url = (line.split)[1]
    agent = Mechanize.new
    agent.get(url)
    @title       = agent.page.title                                                             
    @keywords    = agent.page.search("meta[name='keywords']")[0].attributes['content'].value    
    @description = agent.page.search("meta[name='description']")[0].attributes['content'].value 
  end
end

# puts Page.new('. http://www.elong.com/ . . . . . .').title
File.new(regexp_path).each do |line|
  describe "测试 #{line.split.first}" do
    before(:each) do
      @meta = Meta.new(line)
      @page = Page.new(line)
    end

    it_behaves_like "BASIC"
  end
end

