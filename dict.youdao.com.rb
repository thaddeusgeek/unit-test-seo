#coding:UTF-8
require './common.rb'
$domains = %w(youdao.com 163.com)
$host = 'dict.youdao.com'
$uri_patterns = [] << 
    %r(^/w/[^/]+/$) <<
    %r(^/wikis/[^/]+/$) <<
    %r(^/wiki/[^/]+/$) <<
    %r(^/[^/]+/[^/]+/$) << #/eng/go/
    %r(^/[^/]+/[^/]+/example/$) << #/eng/go/example/
    %r(^/[^/]+/[^/]+/example/media\.html$) << #/eng/go/example/media.html
    %r(^/[^/]+/[^/]+/example/video\.html$) << #/eng/go/example/media.html
    %r(^/[^/]+/[^/]+/example/audio\.html$) << #/eng/go/example/media.html
    %r(^/[^/]+/[^/]+/example/auth\.html$) << #/eng/go/example/media.html
    %r(^/[^/]+/[^/]+/example/paper\.html$) << #/eng/go/example/media.html
    %r(^/[^/]+/[^/]+/example/oral\.html$) << #/eng/go/example/media.html
    %r(^/[^/]+/[^/]+/example/written\.html$) << #/eng/go/example/media.html
=begin
    %r(^/example/[^/]+/$) <<
    %r(^/example/oral/[^/]+/$) <<
    %r(^/example/written/[^/]+/$) <<
    %r(^/example/paper/[^/]+/$) <<
    %r(^/example/media/[^/]+/$) <<
    %r(^/example/audio/[^/]+/$) <<
    %r(^/example/video/[^/]+/$) <<
=end
    %r(^/fr/[^/]+/$) <<
    %r(^/jap/[^/]+/$) <<
    %r(^/ko/[^/]+/$) <<
    %r(^/eng/[^/]+/$)
agent = Mechanize.new
agent.redirect_ok = :permanet
shared_examples_for "小语种页面" do
    it "不应出现到英汉页面的链接" do
        $page.links.each do |link|
            link.href.should_not =~ /^\/w\//
            link.href.should_not =~ /^\/eng\//
        end
    end
end
describe "一般汉英页面" do
    word = '无'
    $page = Mechanize.new.get "http://dict.youdao.com/eng/#{URI.encode(word)}/"
    $necessary_links = [] <<
    ["/eng/not_have/","not have",word] <<
    ["/eng/regardless_of/","regardless of",word]
    it_behaves_like "固定链接页面"
end

describe "站点地图/map/index.html" do
    $necessary_files = %w(/map/index.html /map/style.css /map/nav.png)
    $necessary_files.each do |file|
        it "必要文件#{file}不能丢失" do
            expect{Mechanize.new.get "http://#{$host}#{file}"}.not_to raise_error
        end
    end
end

describe "主机dict.youdao.com" do
    $redirects = [] << 
    ['/w/Go/','/eng/go/'] <<
    ['/w/_Go/','/eng/go/'] <<
    ['/w/Go_/','/eng/go/'] <<
    ['/w/_Go_/','/eng/go/'] <<
    ['/w/Go','/eng/go/'] <<
    ['/w/Go/to/','/eng/go/'] <<
    ['/w/Go/to','/eng/go/'] <<
    ['/w/Go__to/','/eng/go_to'] <<
    ['/w/lj:Go/','/eng/go/example/'] <<
    ['/example/media/go/','/eng/go/example/media.html'] <<
    ['/search','/'] <<
    ['/search?q=bk:Go','/wiki/go/'] <<
    ['/w/bk:Go/','/wiki/go/'] <<
    ['/w/bk%3AGo/','/wiki/go/'] <<
    ['/w/bk:Go','/wiki/go/'] <<
    ['/w/bk:_Go/','/wiki/go/'] <<
    ['/w/bk:Go_/','/wiki/go/'] <<
    ['/w/bk:_Go_/','/wiki/go/'] <<
    ['/search?q=bk%3AGo&wiki.related&wikisearch=','/wikis/go/'] <<
    ['/search?q=bk:Go','/wiki/go/'] <<
    ['/?keyfrom=abc&vendor=bcd','/'] <<
    ['/drawsth','http://cidian.youdao.com/drawsth'] <<
    ['/m/search?keyfrom=dict.mindex&q=Go','/m/go/'] <<
    ['/search?q=Go&le=jap','/${lng}/${keyword}/'] <<
    ['/search?keyfrom=selector&q=Go','/eng/go/']

    it_behaves_like "所有主机"
    
    baduri = 'http://dict.youdao.com/example/written/make_a_dash_through_the_smoke_and_fire/'
    ['Sogou web spider/4.0','Sogou inst spider/4.0','YodaoBot','Googlebot','Baiduspider','Sosospider'].each do |ua|
        agent.user_agent = ua
        it "当查询#{baduri} 无结果时,应针对#{ua}返回404" do
            expect{$page = agent.get baduri}.to raise_error(Mechanize::ResponseCodeError,/^404/)
        end
    end
end

describe "一般英汉单词页面" do
    word = 'go'
    $uri = "http://dict.youdao.com/w/#{word}/"
    $necessary_links = [] <<
    ["/m/#{word}/",                     word,                               "#{word}的意思 手机版"] <<
    ["/wiki/#{word}/",                  word,                               nil] <<
    ["/wikis/#{word}/",                 "更多与\"word\"相关的百科词条 »",   nil] <<
    ["http://fanyi.youdao.com/",        "翻译",                             nil] <<
    ["/eng/#{word}/example/",           "更多双语例句",                     "#{word}的双语例句"] <<
    ["/eng/#{word}/example/media.html", "更多原声例句",                     "#{word}的原声例句"] <<
    ["/eng/#{word}/example/auth.html",  "更多权威例句",                     "#{word}的权威例句"] <<
    ["/eng/went/",                      "went",                             "#{word}的过去式"] <<
    ["/eng/going/",                     "going",                            "#{word}的现在分词"] <<
    ["/eng/goes/",                      "goes",                             "#{word}的复数形式"] <<
    ["/eng/gone/",                      "gone",                             "#{word}的过去分词"]

    $page = agent.get($uri)
    it_behaves_like "所有页面"

    it '<div id="ads" class="ads"> 中不能有内容(需要用js显示)' do
        $page.search("//div[@id='ads']").first.text.should be_empty
    end
end

describe "单数形式英汉单词页" do
    word = 'fern'
    $uri = "http://dict.youdao.com/eng/#{word}/"
    $necessary_links = [] <<
    ["/eng/ferns/","ferns","#{word}的复数"] <<
    ["/eng/fern/","fern","#{word}的复数"]
    it_behaves_like "固定链接页面"
end
describe "复数形式英汉单词页" do
    word = 'data'
    $uri = "http://dict.youdao.com/eng/#{word}/"
    $necessary_links = ['/eng/datum','datum',"#{word}的单数"]
end

describe "韩汉单词页面" do
    word = '음악'
    word_cn = '音乐'
    $uri = "http://dict.youdao.com/ko/#{URI.encode(word)}/"
    $page = Mechanize.new.get $uri
    $necessary_links = [] <<
    ["/ko/#{URI.encode(word)}/example/",   '更多双语例句', "#{word}的双语例句"] <<
    ["/wiki/#{URI.encode(word_cn)}/",       word_cn,        nil]
    it_behaves_like "固定链接页面"
    it_behaves_like "小语种页面"
end

describe "汉韩单词页面" do
    
end

describe "日汉单词页面" do
    word = 'ワード'
    word_cn = '音乐'
    $uri = "http://dict.youdao.com/jap/#{URI.encode(word)}/"
    $necessary_links = [] <<
    ["/jap/#{URI.encode(word)}/example/",   '更多双语例句',"#{word}的双语例句"] <<
    ["/wiki/#{URI.encode(word_cn)}/",       word_cn,         nil]
    it_behaves_like "固定链接页面"
    it_behaves_like "小语种页面"
end

describe "汉日单词页面" do
end

describe "法汉单词页面" do
    word = 'bon'
    $uri = "http://dict.youdao.com/fr/#{URI.encode(word)}/"
    it_behaves_like "固定链接页面"
    it_behaves_like "小语种页面"
end


describe "移动版英汉单词页" do
    word = 'go'
    $uri = "http://dict.youdao.com/m/#{word}/"
    $page = agent.get $uri
    $necessary_links = [] << ['/m/abc/online.html','更多释义',"#{word}的更多释义"]
    it_behaves_like '所有页面'
    specify{@page.title.should == "#{word}_有道手机词典"}
end

describe "首页" do
    $page = agent.get 'http://dict.youdao.com'
    
    $necessary_links = [] << ['http://dict.youdao.com/map/index.html','站点地图',nil]
    it_behaves_like "所有页面",$page
    
    specify{$page.title.should == '英语_汉语_法语_日语_韩语_有道多语言在线词典'}

    specify{$page.search("//meta[@name='keywords']").text.should include '词典'}
    
    specify{$page.search("//meta[@name='description']").text.should == '有道词典网页版,支持中文、英语、法语、日语、韩语五种语言,不仅提供常规的英汉、法汉、日汉、韩汉互译以及汉语词典的功能,还收录了各类词汇的网络释义、例句和百科知识。'}
    
    it "应该包含到'/map/index.html'的链接,而且没被标nofollow" do
        $page.link_with(:href => %r(/map/index.html)).rel.should be_empty
    end
    
    it "should not contain 'keyfrom' in uris" do
    end
end
