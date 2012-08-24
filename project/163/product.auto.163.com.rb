#coding:UTF-8
require './common.rb'
domains = %w(auto.163.com)
hosts = %w(auto.163.com product.auto.163.com)
uri_patterns = [] <<
    %r(^/brand/$) <<
    %r(^/brand/\d+\.html$) <<
    %r(^/series/\d+\.html$) <<
    %r(^/series/config1/\d+\.html$) <<
    %r(^/compare/\d+,\d+\.html$) <<
    %r(^/series/photo/\d+\.html$) <<
    %r(^/review/\d+\.html$) <<
    %r(^/test/\d+\.html$) <<
    %r(^/gas/\d+\.html$) <<
    %r(^/series/article/\d+\.html$) <<
    %r(^/series/complain/\d+\.html$) <<
    %r(^/product/[a-zA-Z0-9]+.html$) <<
    %r(^/include/auto_calculate\.html$) << #全款计算器
    %r(^/include/auto_calculate_dk\.html$) << #贷款计算器
    %r(^/include/auto_calculate_bf\.html$) << #保险计算器
    %r(^/opinion_more/\d+/\d_\d.html$)
outter_uri_patterns = [] <<
    %r(^http://auto\.163\.com/\d\d/\d{4}/\d\d/[A-Z0-0]+\.html$) << #新闻页
    %r(^http://dealer\.auto\.163\.com/\d+/$) << #经销商
    %r(^http://dealer\.auto\.163\.com/\d+/news/201\d+/\d+\.html$) << #经销商新闻
    %r(^http://auto\.163\.com/$)
    
host = 'product.auto.163.com'
redirects = [] <<
%w(/search.html /) <<
%w(/index.html /) <<
%w(/auto!search2.action /) <<
%w(/auto!search.action /) <<
%w(/config_pk.html /compare/index.html) <<
%w(/series/config/2502.html /series/config1/2502.html) <<
%w(/opinion_more/1970/%CE%B6%B5%C0/000a.html /opinion_more/1970/%CE%B6%B5%C0/1_1.html) <<
%w(/car/series2/id=00080BSA0BJI0BJc.html /brand/1714.html) <<
%w(/auto!pk.action?productids=0000JZBC,0000JbYf,0000JbZA,0000GZeU /config_compare/0000JZBC,0000JbYf,0000JbZA,0000GZeU.html) <<
%w(/car/petrol/id=00080BSA0BeQ0BWT0BWX.html /gas/2366.html) <<
%w(/car/parameter/id=00080BSA0BeQ0BSK0BSO.html /series/config1/2225.html) <<
%w(/2/00LS.html /series/2171.html) <<
%w(/car/auto_news/key=00080BSA0BeQ0BTL.html /brand/1654.html)
describe host do
    meta = {}
    meta[:robots] = ['User-agent: *','Allow: /','Sitemap: /sitemap/sitemap.xml']
    meta[:domains] = domains
    meta[:uri_patterns] = uri_patterns
    meta[:host] = host
    meta[:redirects] = redirects
    it_behaves_like '所有主机',meta
end
uri = 'http://product.auto.163.com'
describe "汽车产品库首页#{uri}" do
    meta = {}
    meta[:uri] = uri
    meta[:page] = Mechanize.new.get(uri)
    #.body.force_encoding('gb2312').encode('utf-8')
    it_behaves_like '所有页面',meta
end

uri = 'http://auto.163.com/12/0628/07/852Q3NJE00084TUQ.html'
describe "汽车新闻页#{uri}" do
    meta = {}
    meta[:uri] = uri
    meta[:page] = Mechanize.new.get uri
    it_behaves_like '所有页面',meta
end
