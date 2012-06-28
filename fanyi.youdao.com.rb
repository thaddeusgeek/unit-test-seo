#coding:UTF-8
require './common.rb'
$domain = 'youdao.com'
$redirects = [] << ['/index.html','/'] << ['/Translate','/'] << ['/WebpageTranslate','/'] << ['/fanyiapi','/openapi'] << ['/fufei/','http://f.youdao.com/'] << ['/fufei','http:/f.youdao.com'] << ['/rengong/','http://f.youdao.com/'] << ['/rengong/','http://f.youdao.com/'] << ['/web2/index.html','/web2/']

describe "首页" do
    $page = Mechanize.new.get 'http://www.cnbeta.com/'
end
__END__
    specify{$page.title.should == '有道英汉互译_日语_法语_韩语_英语在线翻译器'}
    specify{$page.search('<meta name="description" content="我们免费为您提供:英译中、中译英的英汉双向翻译。同时也支持日语、法语、韩语到中文的双向翻译。有道多语言在线翻译器，做您日常工作中的好帮手。"/>')}
    
    <h1>中英、中日、中法、中韩免费翻译</h1>
    
    del '删除<div id="ym"/>'
    去掉keyfrom
end

describe "robots" do
    删除Allow: /fufei
    删除Allow: /rengong
end

describe "关于有道" do
end
