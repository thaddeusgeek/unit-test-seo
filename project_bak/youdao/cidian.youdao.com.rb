#coding:UTF-8
$project = 'youdao'
require './common.rb'
host = 'cidian.youdao.com'
describe host do
    it_behaves_like '所有主机',host
end
uri = 'http://cidian.youdao.com/'
describe "桌面词典首页#{uri}" do
    meta = {}
    meta[:uri] = uri
    meta[:title] = '英语_汉语_法语_日语_韩语_有道多语言桌面词典_字典_翻译软件'
    it_behaves_like '所有页面',meta
end
