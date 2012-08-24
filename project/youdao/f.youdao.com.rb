#coding:UTF-8
require './common.rb'
$domains = %w(youdao.com 163.com)
$uri_patterns = [] <<
    %r(^\?path=(fast|file|about)$)

describe "首页" do
    meta = {}
    meta[:uri] = 'http://f.youdao.com/'
    meta[:page] = Mechanize.new.get meta[:uri]
    meta[:keywords] = %w(专业 人工 翻译)
    meta[:title] = '有道英汉互译_日语_法语_韩语_英语在线翻译器'
    meta[:description] ="有道翻译免费为您提供:英译中、中译英的英汉双向翻译.同时也支持日语、法语、韩语到中文的双向翻译.有道多语言在线翻译器,做您日常工作中的好帮手."
    meta[:h1] = '中英、中日、中法、中韩免费在线翻译'
    it_behaves_like "所有页面", meta
    
    it '应删除<div id="ym"/>' do
        meta[:page].search("//div[@id='ym1']").should be_empty
    end
end

describe "快速翻译页" do
end

describe "文档翻译页" do
end


