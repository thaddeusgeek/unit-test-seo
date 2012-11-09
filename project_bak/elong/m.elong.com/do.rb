#coding:UTF-8
require '../../../common/common.rb'
require '../../../common/basic.rb'
$project = get_project_name

uri = 'http://m.elong.com/w4m/'
describe "酒店预订-首页 #{uri}" do
    meta = {}
    meta[:uri] = uri
    meta[:content] = Mechanize.new.get(uri).body
    meta[:keywords] = %w(酒店 酒店预订)
    meta[:title] = '【宾馆酒店机票预订】快捷连锁酒店_星级酒店预定_手机艺龙网'
    meta[:description] = '艺龙旅行网在线预订酒店返现高达20%。提供国内631多个城市,80多个品牌,包括洲际,万豪,雅高,喜达屋等国际知名酒店品牌,以及如家,锦江之星,格林豪泰等经济型商务连锁酒店,超过3万家酒店的在线和电话预订(预定)服务。,24小时免费预订电话4009-333333'
    it_behaves_like '基本规范',meta
end
