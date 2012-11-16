#coding:UTF-8
require './common.rb'

uri = 'http://m.youdao.com/'
describe "手机首页#{uri}" do
    meta = {}
    meta[:uri] = uri
    it_behaves_like '所有页面',meta
end
