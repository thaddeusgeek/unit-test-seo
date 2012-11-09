#coding:UTF-8
require './common.rb'
$domain = 'jiaju.com'
describe "首页" do
    $necessary_links = []
    $uri = 'http://www.jiaju.com/'
    $page = Mechanize.new.get $uri

    it_behaves_like '所有页面'
end

describe "www.jiaju.com" do
    $redirects = []
    $host = 'www.yifen.com'
    it_behaves_like '所有主机'
end
