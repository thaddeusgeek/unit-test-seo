#coding:UTF-8
require 'mechanize'
require 'pp'
agent = Mechanize.new
patterns = Array.new
domain = 'youdao.com'
#patterns << %r(^/w/[^/]+/$)
patterns << %r(^/example/[^/]+/$)
patterns << %r(^/example/oral/[^/]+/$)
patterns << %r(^/example/written/[^/]+/$)
patterns << %r(^/example/paper/[^/]+/$)
patterns << %r(^/example/media/[^/]+/$)
patterns << %r(^/example/audio/[^/]+/$)
patterns << %r(^/example/video/[^/]+/$)
patterns << %r(^/fr/[^/]+/$)
patterns << %r(^/jap/[^/]+/$)
patterns << %r(^/ko/[^/]+/$)

shared_examples_for "所有页面规则" do
    it "每个URI应该都符合w3c标准" do
        $page.links.each do|link|
            expect{URI(link.href)}.not_to raise_error(URI::InvalidURIError)
        end
    end
    
    it "图片必须使用绝对路径,不许使用相对路径" do
        $page.images.each do|image|
            URI(image.src).path.should start_with '/'
        end
    end
    
    it "没标nofollow的链接,必须遵守URI正则规范" do
        $page.links.each do |link|
            next if link.rel.first == 'nofollow' or link.href.nil?
            host = URI(link.href).host
            next if host.nil? or host.end_with?domain
            path = URI(link.href).path
            next unless path
            link.should do
                patterns.any?{|pattern|path =~ pattern}.should == true
            end
        end
    end
    
    $page.links.each do |link|
        next if link.href.nil?
        begin
            host = URI(link.href).host
        rescue
            host = URI(URI.encode(link.href)).host
        end
        next if host.nil? or host.end_with?domain
        it "#{link.inspect}, 属于站外链接应该标nofollow" do
            link.rel.first.should == 'nofollow'
        end
    end
    
    it "禁止使用<a>当按钮" do
        #($page.links_with(:href=>nil) + page.links_with(:href=>'#')).should == nil
        buttons = $page.links_with(:href=>'#') +  $page.links_with(:href=>nil)
        buttons = nil if buttons.empty?
        buttons.should == nil
    end
end
describe "英汉单词页面" do
    word = 'go'
    $page = agent.get("http://dict.youdao.com/w/#{word}/")
    baduri = 'http://dict.youdao.com/example/written/make_a_dash_through_the_smoke_and_fire/'
    
    it_behaves_like "所有页面规则"
    
    it "应包含到手机网页版的链接 dict.youdao.com/m/#{word}" do
        $page.links.any?{|link|link.href =~ %r(/m/#{word}/)}.should == true
    end
    
    ['Sogou web spider/4.0','Sogou inst spider/4.0','YodaoBot','Googlebot','Baiduspider','Sosospider'].each do |ua|
        agent.user_agent = ua
        it "当查询#{baduri} 无结果时,应针对#{ua}返回404" do
            expect{$page = agent.get baduri}.to raise_error(Mechanize::ResponseCodeError,/^404/)
        end
    end
    
    it '<div id="ads" class="ads"> 中不能有内容(需要用js显示)' do
        $page.search("//div[@id='ads']").first.text.should be_empty
    end
    
end

describe "homepage" do
    $page = agent.get 'http://dict.youdao.com'
    it_behaves_like "所有页面规则"
    
    it "<title>完整匹配" do
        $page.title.should == '英语_汉语_法语_日语_韩语_有道多语言在线词典'
    end

    it "应该有keywords标签,而且keywords包含'词典'" do
        $page.search("//meta[@name='keywords']").text.should include '词典'
    end
    
    it "应该有description标签,而且内容完整匹配" do
        $page.search("//meta[@name='description']").text.should == '有道词典网页版,支持中文、英语、法语、日语、韩语五种语言,不仅提供常规的英汉、法汉、日汉、韩汉互译以及汉语词典的功能,还收录了各类词汇的网络释义、例句和百科知识。'
    end
    
    it "应该包含到'/map/index.html'的链接,而且没被标nofollow" do
        $page.link_with(:href => %r(/map/index.html)).rel.should be_empty
    end
    
    it "should not contain 'keyfrom' in uris" do
    end
end
