#coding:UTF-8
require './common.rb'
host = 'cidian.youdao.com'
uri_patterns = [] <<
    %r(^/(android|ipad|windows-phone|iphone|mac|changelog|feature|history|)\.html)
describe host do
    meta[:redirects] = [] << 
    %w(/cet /cet/) <<
    %w(/cet /cet/) <<
    %w(/dictlib.html /) <<
    %w(/faq2.html /faq.html) <<
    %w(/5.0/help/deskdict5beta/faq/index.html /faq.html) <<
    %w(/beta /beta/) <<
    %w(/qiye /qiye/) <<
    %w(/features /features/) <<
    %w(/v3 /) <<
    %w(/v2/ /) <<
    %w(/v2 /) <<
    %w(/4.1/ /) <<
    %w(/4.1 /) <<
    %w(/4.0/ /) <<
    %w(/4.0 /) <<
    %w(/5.0 /) <<
    %w(/5.0/ /) <<
    %w(?sitemap /)
end
uri = 'http://cidian.youdao.com/'
describe "桌面词典首页#{uri}" do
    meta = {}
    meta[:uri] = uri
    meta[:title] = ''
    it_behaves_like '所有页面',meta
end
