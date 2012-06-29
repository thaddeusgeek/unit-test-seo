#coding:UTF-8
require './common.rb'
$domains = %w(youdao.com 163.com)
$host = 'dict.youdao.com'
$uri_patterns = [] <<
    %r(^/(eng|fr|ko|jap|wiki|wikis)/[^/]+/$) << #/eng/go/
    %r(^/(eng|fr|ko|jap)/[^/]+/example/$) << #/eng/go/example/
    %r(^/(eng|fr|ko|jap)/[^/]+/example/(media|video|audio|auth|paper|oral|written)\.html$) << #/eng/go/example/media.html
=begin
    %r(^/example/[^/]+/$) <<
    %r(^/example/oral/[^/]+/$) <<
    %r(^/example/written/[^/]+/$) <<
    %r(^/example/paper/[^/]+/$) <<
    %r(^/example/media/[^/]+/$) <<
    %r(^/example/audio/[^/]+/$) <<
    %r(^/example/video/[^/]+/$) <<
=end
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
describe "站点地图/map/index.html" do
    $necessary_files = %w(/map/index.html /map/style.css /map/nav.png)
    $necessary_files.each do |file|
        it "必要文件#{file}不能丢失" do
            expect{Mechanize.new.get "http://#{$host}#{file}"}.not_to raise_error
        end
    end
end

describe "#{$host}" do
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


    word_cn = URI.encode("心理学")
    word_ko = URI.encode("음악")
    word_jap = URI.encode('ワード')
    word_fr = URI.encode('écrire')
    $links = [] <<
    ["/eng/go/","/m/go/","/eng/go/example/","/eng/go/example/media.html","/eng/go/example/auth.html","/wiki/go/","/wikis/go/","/eng/going/","/eng/gone/","/eng/went/","/eng/goes/","http://fanyi.youdao.com/"] <<
    %w(/m/go/ /m/go/online.html /m/go/example.html)
    ["/eng/#{word_cn}/","/m/#{word_cn}/","/eng/#{word_cn}/example/","/eng/#{word_cn}/example/media.html","/eng/#{word_cn}/example/auth.html","/wiki/#{word_cn}/","/wikis/#{word_cn}","/eng/mental_philosophy/"] <<
    ["/ko/#{word_ko}/","/m/#{word_ko}/","/ko/#{word_ko}/example/","/ko/#{word_ko}/example/media.html","/ko/#{word_ko}/example/auth.html","/wiki/#{word_ko}/","/wikis/#{word_ko}","/wiki/#{URI.encode("音乐")}/","/wikis/#{URI.encode("音乐")}/"] <<
    ["/jap/#{word_jap}/","/m/#{word_jap}/","/jap/#{word_jap}/example/","/jap/#{word_jap}/example/media.html","/jap/#{word_jap}/example/auth.html","/wiki/#{word_jap}/","/wikis/#{word_jap}","/wiki/#{URI.encode("字_(计算机)")}/","/wikis/#{URI.encode("字_(计算机)")}/"] <<
    ["/fr/#{word_fr}/","/m/#{word_fr}/","/fr/#{word_fr}/example/","/fr/#{word_fr}/example/media.html","/eng/#{word_fr}/example/auth.html","/wiki/#{word_fr}/","/wikis/#{word_fr}","/wiki/#{URI.encode("书")}/","/wikis/#{URI.encode("书")}/"] <<
    %w(/eng/going/ /eng/go/) <<
    %w(/eng/gone/ /eng/go/) <<
    %w(/eng/went/ /eng/go/) <<
    %w(/eng/goes/ /eng/go/) <<
    %w(/eng/fern/ /eng/ferns/) <<
    %w(/eng/ferns/ /eng/fern/)
    it_behaves_like "所有主机"
    
    baduri = 'http://dict.youdao.com/example/written/make_a_dash_through_the_smoke_and_fire/'
    ['Sogou web spider/4.0','Sogou inst spider/4.0','YodaoBot','Googlebot','Baiduspider','Sosospider'].each do |ua|
        agent.user_agent = ua
        it "当查询#{baduri} 无结果时,应针对#{ua}返回404" do
            expect{$page = agent.get baduri}.to raise_error(Mechanize::ResponseCodeError,/^404/)
        end
    end
end

describe "一般单词页面" do
    %w(abc go fine).each do |word|
        $uri = "http://dict.youdao.com/eng/#{word}/"
=begin
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
=end

        $page = agent.get($uri)
        it_behaves_like "所有页面"

        it '<div id="ads" class="ads"> 中不能有内容(需要用js显示)' do
            $page.search("//div[@id='ads']").first.text.should be_empty
        end
    end
end

describe "法语页面" do
    %w(écrire bon fleur).each do |word|
        $uri = "http://dict.youdao.com/fr/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】什么意思_#{word}在线翻译成中文_有道词典"
        it_behaves_like "基本页面"
    end
end

describe "日语页面" do
    %w(にほん ちゅうごく アメリカ合衆国).each do |word|
        $uri = "http://dict.youdao.com/jap/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】什么意思_#{word}在线翻译成中文_有道词典"
        it_behaves_like "基本页面"
    end
end

describe "韩语页面" do
    %w(중국 한국 미국).each do |word|
        $uri = "http://dict.youdao.com/ko/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】什么意思_#{word}在线翻译成中文_有道词典"
        it_behaves_like "基本页面"
    end
end

describe "英语页面" do
    %w(china america world).each do |word|
        $uri = "http://dict.youdao.com/eng/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】什么意思_#{word} 英语怎么说_在线翻译成英文_有道词典"
        it_behaves_like "基本页面"
    end
end

%w(无 有 心理学).each do |word|
    describe "汉英#{word}页面" do
        $uri = "http://dict.youdao.com/eng/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "<title>【#{word}】英语怎么说_ #{word} 在线翻译成英文_有道词典</title>"
        it_behaves_like "基本页面"
    end

    describe "汉法查#{word}页面" do
        $uri = "http://dict.youdao.com/fr/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】法语怎么说_#{word}在线翻译成法语_有道词典"
        it_behaves_like "基本页面"
    end
    describe "汉韩查#{word}页面" do
        $uri = "http://dict.youdao.com/ko/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】韩语怎么说_#{word}在线翻译成韩语_有道词典"
        it_behaves_like "基本页面"
    end
    describe "汉日查#{word}页面" do
        $uri = "http://dict.youdao.com/jap/#{URI.encode(word)}/"
        $page = Mechanize.new.get $uri
        $title = "【#{word}】日语怎么说_#{word}在线翻译成日语_有道词典"
        it_behaves_like "基本页面"
    end
end


describe "首页" do
    $page = agent.get 'http://dict.youdao.com'
    
    $necessary_links = [] << ['http://dict.youdao.com/map/index.html','站点地图',nil]
    
    specify{$page.title.should == '英语_汉语_法语_日语_韩语_有道多语言在线词典'}

    specify{$page.search("//meta[@name='keywords']").text.should include '词典'}
    
    specify{$page.search("//meta[@name='description']").text.should == '有道词典网页版,支持中文、英语、法语、日语、韩语五种语言,不仅提供常规的英汉、法汉、日汉、韩汉互译以及汉语词典的功能,还收录了各类词汇的网络释义、例句和百科知识。'}
    
    it "应该包含到'/map/index.html'的链接,而且没被标nofollow" do
        $page.link_with(:href => %r(/map/index.html)).rel.should be_empty
    end
    
    it_behaves_like "所有页面"
end
