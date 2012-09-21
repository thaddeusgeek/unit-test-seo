#coding:UTF-8
require './common.rb'
$project = 'elong'
hosts = %w(tuan.elong.com bid.elong.com flight.elong.com globalhotel.elong.com hotel.elong.com huixuan.elong.com trip.elong.com tuan.elong.com www.elong.com)
hosts.each do |host|
    describe "#{host}" do
        meta = {:host=>host}
        it_behaves_like '所有主机',meta
    end
end
uri = 'http://www.elong.com/'
describe "首页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end

uri = 'http://hotel.elong.com/'
describe "酒店预订-首页 #{uri}" do
    meta = {:uri => uri}
    it_behaves_like '所有页面',meta
end

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
