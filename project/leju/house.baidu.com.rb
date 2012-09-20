#coding:UTF-8
require './common.rb'
domain = 'baidu.com'
domains = %w(house.baidu.com esf.baidu.com leju.com jiaju.baidu.com rent.baidu.com)
host = 'house.baidu.com'
uri_patterns = [] <<
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
describe "#{host}" do
    meta = {}
    meta[:domain] = domain
    meta[:host] = host
    meta[:redirects] = [] <<
    ['http://leju.baidu.com/baoding/detail/2345','/baoding/detail/2345'] <<
    ['http://house.leju.com/baoding/detail/2345','/baoding/detail/2345']
    it_behaves_like '所有主机',meta
end
uri = 'http://house.baidu.com/bj/'
describe "北京首页#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = "http://house.baidu.com/bj/search/"
describe "北京搜索首页#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/news/98401/4221810/'
describe "新闻详情页#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/detail/98401/'
describe "楼盘详情#{uri}" do
    meta= {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/photo/98401/'
describe "楼盘相册#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/price/98401/'
describe "楼盘价格#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/info/98401/'
describe "楼盘参数#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/quot/98401/'
describe "楼盘新闻#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/advantage/98401/'
describe "楼盘优缺点#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/device/98401/'
describe "楼盘交通配套#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end

uri = 'http://house.baidu.com/bj/pic/737/live/586626/'
describe "图片详情页#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end
