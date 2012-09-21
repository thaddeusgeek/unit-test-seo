#coding:UTF-8
$project = '163'
require './common.rb'
host = 'fanxian.163.com'
describe "#{host}" do
    meta = {}
    meta[:host] = host
    it_behaves_like "所有主机", meta
end
uri = 'http://fanxian.163.com/'
describe "#{uri} 返现首页" do
    meta = {}
    meta[:uri] = uri
    meta[:keywords] = %w(返现 返利 购物 折扣)
    meta[:title] = '网易返现 - 淘宝网,京东,凡客,折扣精选,优惠券,购物返利返现金!'
    it_behaves_like '所有页面',meta
end

uri = 'http://fanxian.163.com/detail?id=c9ab30af27868625'
describe "#{uri} 产品详细页" do
    meta = {}
    product_name = 'Intel 酷睿i7 2600（盒） CPU'
    meta[:uri] = uri
    meta[:keywords] = [product_name,'cpu']
    meta[:title] = "【#{product_name}】返现_评价怎么样_详细参数 最新消息"
    meta[:description] = "#{product_name}的商城比价:最低价格[0-9\.]+元.用户评论:[0-9\.]+星,共\d+人评论.详细参数.相关资讯."
    it_behaves_like '所有页面',meta
end

describe "无内容页面应返回404" do
    ran = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    %w(http://fanxian.163.com/search?q= http://fanxian.163.com/mall/search?q= http://fanxian.163.com/coupons/search?q= http://fanxian.163.com/detail?id=).each do |uri_seg|
        uri = uri_seg+ran
        it "#{uri}应返回404" do
            expect{Mechanize.new.get uri}.to raise_error(Mechanize::ResponseCodeError,/^404/)
        end
    end
end
