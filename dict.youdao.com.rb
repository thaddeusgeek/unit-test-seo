#coding:UTF-8
$project = 'youdao'
require './common.rb'

describe "站点地图/map/index.html" do
    host = 'dict.youdao.com'
    necessary_files = %w(/map/index.html /map/style.css /map/nav.png)
    necessary_files.each do |file|
        it "必要文件#{file}不能丢失" do
            expect{Mechanize.new.get "http://#{host}#{file}"}.not_to raise_error
        end
    end
end

host = 'dict.youdao.com'
describe "#{host}" do
    meta = {}
    meta[:host] = host
    it_behaves_like "所有主机", meta
    
    baduri = 'http://dict.youdao.com/example/written/make_a_dash_through_the_smoke_and_fire/'
    ['Sogou web spider/4.0','Sogou inst spider/4.0','YodaoBot','Googlebot','Baiduspider','Sosospider'].each do |ua|
        agent = Mechanize.new
        agent.redirect_ok = :permanet
        agent.user_agent = ua
        it "当查询#{baduri} 无结果时,应针对#{ua}返回404" do
            expect{agent.get baduri}.to raise_error(Mechanize::ResponseCodeError,/^404/)
        end
    end
end

describe "一般单词页面" do
        meta = {}
    #%w(abc go fine).each do |word|
        word = 'go'
        meta[:uri] = "http://dict.youdao.com/eng/#{word}/"
        meta[:keywords] = [] << word
        it_behaves_like "所有页面", meta

        it '<div id="ads" class="ads"> 中不能有内容(需要用js显示)' do
            Mechanize.new.get(meta[:uri]).search("//div[@id='ads']").first.text.should be_empty
        end
    #end
end
%w(écrire bon fleur).each do |word|
    meta = {}
    meta[:uri] = "http://dict.youdao.com/fr/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】什么意思_法语#{word}在线翻译成中文_有道词典"
    describe "法语#{word}单词页面" do
        it_behaves_like "基本页面", meta
    end
end

%w(にほん ちゅうごく アメリカ合衆国).each do |word|
    meta = {}
    meta[:uri] = "http://dict.youdao.com/fr/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】什么意思_法语#{word}在线翻译成中文_有道词典"
    describe "法语#{word}单词页面" do
        it_behaves_like "基本页面", meta
    end
end

%w(중국 한국 미국).each do |word|
    meta = {}
    meta[:uri] = "http://dict.youdao.com/ko/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】什么意思_韩语#{word}在线翻译成中文_有道词典"
    describe "韩语页面:#{word}" do
        it_behaves_like "基本页面", meta
    end
end

%w(china america world).each do |word|
    meta = {}
    meta[:uri] = "http://dict.youdao.com/eng/#{URI.encode(word)}/"
    meta[:keywords] = []<< word
    meta[:title] = "【#{word}】什么意思_英语#{word}在线翻译_有道词典"
    describe "英语页面:#{word}" do
        it_behaves_like "基本页面", meta
    end
end

%w(无 有 心理学).each do |word|
    meta = {}
    meta[:uri] = "http://dict.youdao.com/eng/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】英语怎么说_在线翻译_有道词典"
    describe "汉英页面:#{word}" do
        it_behaves_like "基本页面", meta
    end

    meta[:uri] = "http://dict.youdao.com/fr/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】法语怎么说_#{word}在线翻译成法语_有道词典"
    describe "汉法页面:#{word}" do
        it_behaves_like "基本页面", meta
    end

    meta[:uri] = "http://dict.youdao.com/ko/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】韩语怎么说_#{word}在线翻译成韩语_有道词典"
    describe "汉韩页面#{word}" do
        it_behaves_like "基本页面", meta
    end
    
    meta[:uri] = "http://dict.youdao.com/jap/#{URI.encode(word)}/"
    meta[:keywords] = [] << word
    meta[:title] = "【#{word}】日语怎么说_#{word}在线翻译成日语_有道词典"
    describe "汉日页面#{word}" do
        it_behaves_like "基本页面", meta
    end
end


describe "首页" do
    meta = {}
    meta[:uri] = 'http://dict.youdao.com/'
    meta[:title] = '英语_汉语_法语_日语_韩语_有道多语言在线词典'
    meta[:keywords] = %w(词典)
    meta[:description] = '有道词典网页版,支持中文、英语、法语、日语、韩语五种语言,不仅提供常规的英汉、法汉、日汉、韩汉互译以及汉语词典的功能,还收录了各类词汇的网络释义、例句和百科知识。'
    
    it "应该包含到'/map/index.html'的链接,而且没被标nofollow" do
        meta[:page].link_with(:href => %r(/map/index\.html)).rel.should be_empty
    end
    
    it_behaves_like "所有页面", meta
end
