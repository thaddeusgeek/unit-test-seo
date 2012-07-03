#coding:UTF-8
require './common.rb'
$domains = %w(youdao.com 163.com)
$redirects = [] << ['/index.html','/'] << ['/Translate','/'] << ['/WebpageTranslate','/'] << ['/fanyiapi','/openapi'] << ['/fufei/','http://f.youdao.com/'] << ['/fufei','http:/f.youdao.com'] << ['/rengong/','http://f.youdao.com/'] << ['/rengong/','http://f.youdao.com/'] << ['/web2/index.html','/web2/']
$uri_patterns = [] <<
    %r(^/resume/$) <<
    %r(^/web2/$)<<
    %r(^/openapi$)

describe "首页" do
    $uri = 'http://fanyi.youdao.com/'
    $page = Mechanize.new.get $uri
    $keywords = %w(在线 翻译)
    $title = '有道英汉互译_日语_法语_韩语_英语在线翻译器'
    $description = "有道翻译免费为您提供:英译中、中译英的英汉双向翻译.同时也支持日语、法语、韩语到中文的双向翻译.有道多语言在线翻译器,做您日常工作中的好帮手."
    $h1 = '中英、中日、中法、中韩免费在线翻译'
    it_behaves_like "所有页面"
    
    it '应删除<div id="ym"/>' do
        $page.search("//div[@id='ym1']").should be_empty
    end
end

describe "日语翻译页" do
    $uri = 'http://fanyi.youdao.com/jp/'
    begin
        $page = Mechanize.new.get $uri
    rescue Mechanize::ResponseCodeError
        it "应存在#{$uri}页面" do
            expect{Mechanize.new.get $uri}.not_to raise_error Mechanize::ResponseCodeError
        end
        next
    end
    $title = '日语(日文)在线翻译_日译中_中译日_有道翻译'
    $keywords = %w(日语 日文 在线 翻译)
    $description = "有道日语在线翻译,提供较准确的日译中,中译日服务,翻译准确率达到${percent}%,累计为用户节省${hour}小时."
    $h1 = '日语在线翻译'
    it_behaves_like '所有页面'
end
describe "法语翻译页" do
    $uri = 'http://fanyi.youdao.com/fr/'
    begin
        $page = Mechanize.new.get $uri
    rescue Mechanize::ResponseCodeError
        it "应存在#{$uri}页面" do
            expect{Mechanize.new.get $uri}.not_to raise_error Mechanize::ResponseCodeError
        end
        next
    end
    $title = '法语(法文)在线翻译_法译中_中译法_有道翻译'
    $keywords = %w(法语 法文 在线 翻译)
    $description = "有道法语在线翻译,提供较准确的法译中,中译法服务,翻译准确率达到${percent}%,累计为用户节省${hour}小时."
    $h1 = '法语在线翻译'
    it_behaves_like '所有页面'
end
describe "韩语翻译页" do
    $uri = 'http://fanyi.youdao.com/kr/'
    begin
        $page = Mechanize.new.get $uri
    rescue Mechanize::ResponseCodeError
        it "应存在#{$uri}页面" do
            expect{Mechanize.new.get $uri}.not_to raise_error Mechanize::ResponseCodeError
        end
        next
    end
    $title = '韩语(韩文)在线翻译_韩译中_中译韩_有道翻译'
    $keywords = %w(韩语 韩文 在线 翻译)
    $description = "有道韩语在线翻译,提供较准确的韩译中,中译韩服务,翻译准确率达到${percent}%,累计为用户节省${hour}小时."
    $h1 = '韩语在线翻译'
    it_behaves_like '所有页面'
end
