#coding:UTF-8
require '../../../common/common.rb'
require '../../../common/basic.rb'
$project = get_project_name
hosts = %w(tuan.elong.com bid.elong.com flight.elong.com globalhotel.elong.com hotel.elong.com huixuan.elong.com trip.elong.com tuan.elong.com www.elong.com)
=begin
hosts.each do |host|
    describe "#{host}" do
        meta = {:host=>host}
        it_behaves_like '所有主机',meta
    end
uri = 'http://www.elong.com/'
describe "首页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end
=end

uri = 'http://hotel.elong.com/'
describe "酒店预订-首页 #{uri}" do
    meta = {}
    meta[:uri] = uri
    meta[:content] = Mechanize.new.get(uri).body
    meta[:keywords] = %w(酒店 酒店预订)
    meta[:title] = '酒店预订 - 酒店 - 免费预订电话 4009-333333 - 艺龙旅行网'
    meta[:description] = '艺龙旅行网提供国内631多个城市，80 多个品牌,包括洲际、万豪、雅高、喜达屋等国际知名酒店品牌，以及如家、锦江之星、格林豪泰等经济型商务连锁酒店，超过3万家酒店的在线预订和电话预订服务。在线预订酒店返现高达20%，24小时免费预订电话 4009-333333。'
    it_behaves_like '基本规范',meta
end
__END__
uri = 'http://hotel.elong.com/city/Beijing-0C0101-hotels/'
describe "酒店预订-城市页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end

uri = 'http://hotel.elong.com/business_district/XidanFinancial_Street-Beijing-0A010131C0101-hotels/'
describe "酒店预订-城市-商业区页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end

uri = 'http://hotel.elong.com/city/Beijing-Home_Inn-0C0101B32-hotels/'
describe "酒店预订-城市-酒店品牌页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end

uri = 'http://hotel.elong.com/district/Dongcheng-Beijing-0R0002C0101-hotels/'
describe "酒店预订-城市-行政区页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end

uri = 'http://hotel.elong.com/place/XianFengGu-Beijing-0P5268496C0101-hotels/'
describe "酒店预订-城市-景点 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end
