#coding:UTF-8
require './common.rb'
$domain = 'baidu.com'
$domains = %w(house.baidu.com esf.baidu.com leju.com jiaju.baidu.com rent.baidu.com)
$host = 'house.baidu.com'
$uri_patterns = [] <<
    %r(^/\w+/$) <<
    %r(^/\w+/search/$) <<
    %r(^/\w+/news/\d+/\d+/$) <<
    %r(^/\w+/detail/\d+/$) <<
    %r(^/\w+/photo/\d+/$) <<
    %r(^/\w+/price/\d+/$) <<
    %r(^/\w+/info/\d+/$) <<
    %r(^/\w+/quot/\d+/$) <<
    %r(^/\w+/advantage/\d+/$) <<
    %r(^/\w+/device/\d+/$) <<
    %r(^/bj/pic/\d+/\w+/\d+/$)
describe "#{$host}" do
    it_behaves_like '所有主机'
end
$uri = 'http://house.baidu.com/bj/'
describe "北京首页#{$uri}" do
    $page = Mechanize.new.get $uri
    it_behaves_like '所有页面'
end

$uri = "http://house.baidu.com/bj/search/"
describe "北京搜索首页#{$uri}" do
    it_behaves_like '所有页面'
end

