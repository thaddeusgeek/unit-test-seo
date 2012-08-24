#coding:UTF-8
$project = '163'
require './common.rb'
describe "网易首页" do
    meta = {}
    meta[:title] = '网易'
    meta[:uri] = 'http://www.163.com/'
    meta[:keywords] = %w(网易 邮箱 游戏 新闻 体育 娱乐 女性 亚运 论坛 短信 数码 汽车 手机 财经 科技 相册)
    meta[:description] = '网易是中国领先的互联网技术公司，为用户提供免费邮箱、游戏、搜索引擎服务，开设新闻、娱乐、体育等30多个内容频道，及博客、视频、论坛等互动交流，网聚人的力量。'
    it_behaves_like "所有页面", meta
end

describe "网易新闻首页" do
    meta = {}
    meta[:title] = '网易新闻'
    meta[:uri] = 'http://news.163.com/'
    meta[:keywords] = %w(新闻 新闻中心 新闻频道 时事报道)
    meta[:description] = '新闻,新闻中心,包含有时政新闻,国内新闻,国际新闻,社会新闻,时事评论,新闻图片,新闻专题,新闻论坛,军事,历史,的专业时事报道门户网站'
    it_behaves_like "所有页面", meta
end

describe "新闻页" do
    meta = {}
    meta[:title] = '改变中国命运的历史抉择_网易新闻中心'
    meta[:uri] = 'http://news.163.com/12/0710/02/86150JNN00014AED.html'
    meta[:keywords] = %w(社会主义市场经济 市场经济体制 体制改革)
    it_behaves_like "所有页面", meta
end

describe "新闻页" do
    meta = {}
    meta[:title] = '卫生部解除女同性恋者献血禁令_网易新闻中心'
    meta[:uri] = 'http://news.163.com/12/0709/23/860QBJ920001124J.html'
    meta[:keywords] = %w(献血 男同 禁止)
    meta[:description] = '核心提示：7月起，新版《献血者健康检查要求》正式实施。新规指出，有性行为的男同性恋仍被禁止献血，女同性恋者捐献血的禁令被解除。专家称，女同性恋有性行为也不易传播疾病，男男同性恋艾滋感染比例较高。另外，对献全血的志愿者，新规定有400ml、300ml、200ml三种选择。'
    it_behaves_like "所有页面", meta
end
