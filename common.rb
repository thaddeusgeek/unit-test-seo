#coding:UTF-8
require 'mechanize'
require 'pp'
require 'w3c_validators'
require 'yaml'
require 'pismo'
require 'rmmseg'
require 'fileutils'
require 'webpage'
require 'zlib'

FileUtils.rm '/tmp/w3errors' if File.exists? '/tmp/w3errors'
include W3CValidators

def get_regex(host)
    YAML.load(File.read("project/#{$project}/#{host}/regex"))||{}
end

def get_redirects(host)
    YAML.load(File.read("project/#{$project}/#{host}/redirects"))||{}
end

def get_links(host)
    YAML.load(File.read("project/#{$project}/#{host}/links"))||{}
end

def get_robots(host)
    File.read("project/#{$project}/#{host}/robots")
end

def uri_obj(uri)
    require 'uri'
    begin
        URI uri
    rescue URI::InvalidURIError
        URI URI.encode(uri)
    end
end

$framework = {}
Dir.glob("project/#{$project}/*").each do |file|
    host = File.basename(file)
    $framework[host] ||= {}
    $framework[host]['regex'] = get_regex(host)
    $framework[host]['redirects'] = get_redirects(host)
    $framework[host]['robots'] = get_robots(host).strip
    $framework[host]['links'] = get_links(host)
end

shared_examples "所有主机" do |host|
    it "检查配置" do
        $framework[host].should_not be_empty
        $framework[host]['regex'].should_not be_empty
        $framework[host]['redirects'].should_not be_empty
        $framework[host]['robots'].should_not be_empty
        $framework[host]['links'].should_not be_empty
    end
    
    robots_uri = "http://#{host}/robots.txt"
    
    it "#{robots_uri}文件应与配置文件一致,或请检查更新配置文件" do
        expect{Mechanize.new.get robots_uri}.not_to raise_error(Mechanize::ResponseCodeError,/^404/)
        $framework[host]['robots'].should == Mechanize.new.get(robots_uri).body.strip
    end

    $framework[host]['links'].each_pair do |link_from,link_tos|
        link_from = "http://#{host}#{link_from}" if URI(link_from).relative?
        it "保证#{link_from}页面存在" do
        end
        Mechanize.new.get link_from do |page|
            link_tos.each do|link_to|
                the_links = page.links_with(:href=>link_to[0]).delete_if{|link|link.rel=='nofollow'}.delete_if{|link|link.text.nil? or link.text != link_to[1]}.delete_if{|link|link.attributes['title'].nil? or link.attributes['title'] != link_to[2]}
                it "保证'#{link_from}'中有链接<a href=\"#{link_to[0]}\" title=\"#{link_to[2]}\">#{link_to[1]}</a> (不能有nofollow)" do
                    the_links.should_not be_empty
                    #page.links.any?{|link|link.href==link_to}.should == true
                end
            end
        end
    end
    
    $framework[host]['redirects'].each do |redirect|
        redirect[0] = "http://#{host}#{redirect[0]}" unless redirect[0].start_with? 'http://'
        redirect[1] = "http://#{host}#{redirect[1]}" unless redirect[1].start_with? 'http://'
=begin
        it "访问'#{redirect[0]}'不应返回4xx代码" do
            expect{agent.get redirect[0]}.not_to raise_error Mechanize::ResponseCodeError
        end
=end
        agent = Mechanize.new
        agent.redirect_ok = :permanent
        begin
            agent.get redirect[0] do |result|
                it "访问'#{redirect[0]}'应跳转到'#{redirect[1]}'" do
                    result.uri.to_s.should == redirect[1]
                end
                it "访问'#{redirect[0]}'应跳转到'#{redirect[1]}',只能跳一次" do
                    agent.history.size.should < 3
                end
            end
        rescue Mechanize::ResponseCodeError => e
            it "访问'#{redirect[0]}'最后一跳之后应返回200." do
                e.response_code.should == "200"
            end
        end
    end
end

shared_examples "基本页面" do |meta|
    this_uri = meta[:uri]
    this_page = Mechanize.new.get this_uri
    webpage = Webpage.new(meta[:content])
    keywords = meta[:keywords] || []
    online_h1 = webpage['h1']
    it "'#{this_uri}'的title应 == #{meta[:title]} " do
        this_page.title.should == meta[:title] unless meta[:title].nil?
    end

    if webpage['h1'].empty?
        it "应包含h1标签" do
            online_h1.to_a.should_not == []
        end
    else
        it "应包含正确的h1标签" do
            online_h1.text.should == meta[:h1] if meta[:h1]
        end
        it "<h1>应包含至少一个关键词#{keywords}" do
            meta[:keywords].any?{|keyword|online_h1.text.include? keyword}.should == true
        end
    end

    if webpage['canonical'].empty?
        it "应在<head>标签中包含<link rel=\"canonical\">" do
            webpage['canonical'].should_not be_empty
        end
    else
        it "应在<head>中包含唯一的canonical标签" do
            webpage['canonical'].size.should == 1
        end
        it "应在<head>标签中包含<link rel=\"canonical\" href=\"#{this_uri}\"\>" do
            webpage['canonical'].first['href'].should == meta[:uri]
        end
    end

    if webpage['keywords'].empty?
        it "应包含一个meta keywords标签" do
            webpage['keywords'].should_not be_empty
        end
    else
        it "应只包含一个meta keywords标签" do
            webpage['keywords'].size.should == 1
            keywords.size.should == 1
        end
        it "应包含与配置一致的keywords" do
            webpage.keywords.should == meta[:keywords]
        end
    end

    if webpage['description'].empty?
        it "应包含一个meta description标签" do
            webpage['description'].should_not be_empty
        end
    else
        it "应只包含一个meta description标签" do
            webpage['description'].size.should == 1
        end
        it "应包含与配置一致的description" do
            webpage.description.should == meta[:description]
        end
        it "description不能是keywords堆砌" do
            meta[:keywords].each{|keyword| webpage.description.delete keyword }
            description_online.size.should > 50
        end
    end
end

shared_examples "所有页面" do |meta|
    important_keys = %w(:uri :content)
    ##开始检测程序配置(与网站无关)
    it "meta配置应包含#{important_keys}(与网站无关)" do
        important_keys.each do |key|
            meta.should be_has_key key
        end
    end
    uri = meta[:uri]
    keywords = meta[:keywords] || []

    this_uri_obj = this_uri_obj(meta[:uri])
    this_host = this_uri_obj.host
    this_page = Webpage.new(meta[:content].downcase)
    inpage_anchors = (this_page.nodes_with('id')+this_page.nodes_with('name')).map{|node|node.value}
    #links_follow = page.links.delete_if{|link|link.rel.include? 'nofollow'}
    text_squeeze = this_pagetext.to_s.squeeze
    pismo_text = Pismo::Document.new(meta[:content]).body.squeeze

    it_behaves_like "基本页面" ,meta

    pismo_text_size = pismo_text.size
    if pismo_text_size > 0
        ##开始检测主体内容比重
        it "主体内容应占页面总内容的50%以上(功能不稳定)" do
            (pismo_text.size/text.to_s.squeeze.size.to_f).should > 0.5
        end
        ##开始检测关键词密度
        RMMSeg::Dictionary.load_dictionaries#  Ferret::Analysis::StopFilter
        rmmseg = RMMSeg::Algorithm.new(text_squeeze)
        seg_count = 0
        seg_count += 1 while rmmseg.next_token
        keywords.each do |keyword|
            it "'#{keyword}'的分词密度应该在1%到10%之间" do
                tmp_density = (text_squeeze.scan(/#{keyword}/).size.to_f / seg_count)
                tmp_density.should < 0.1
                tmp_density.should > 0.01
            end
        end
    else
        #开始检测是否有主体内容
        it "程序检测不到网页的主体内容，可能需要调整页面结构或者充实主体内容" do
            pismo_text_size.should > 0
        end
    end
    

    ##开始检测页面尺寸
    it "页面尺寸应小于100kb" do
        gzip = Zlib::Deflate.new
        gzip.deflate(this_page.text).bytesize.should < 102400
        gzip.close
    end

    ##开始检测链接数
    it "总链接数应小于101" do
        this_page.links.size.should < 101
    end
    
    ##开始检测nofollow链接数
    it "nofollow的链接应小于正常链接" do
        this_page.links.clone.delete_if{|link|!link['rel'].to_s.include? 'nofollow'}.size.should <= page.links.size/2
    end

    ##开始检测css
    it "应把css归类用<link>引入,不应包含<style>标签" do
        css = this_page['style']
        css.to_s.squeeze[0..100].should == nil unless css.empty?
    end
    
    ##开始检测<h1><h2><h3><h4><h5>标签
    it "应包含连续的<h>标签,假如有<h4>则应该存在<h3> <h2> <h1>" do
        this_page['h2'].should_not be_empty unless this_page['h3'].empty?
        this_page['h3'].should_not be_empty unless this_page['h4'].empty?
        this_page['h4'].should_not be_empty unless this_page['h5'].empty?
        this_page['h5'].should_not be_empty unless this_page['h6'].empty?
    end

    ##开始检测W3C规范
    it "不符合w3c规定的错误数应为0" do
        validator = MarkupValidator.new
        validator.set_doctype!(:html32)
        errors = validator.validate_text(meta[:content]).errors
        File.open("/tmp/w3errors",'a'){|f|
            f.puts "===============================#{this_uri}========================================"
            f.puts errors.join("\n")
        } unless errors.size == 0
        errors.size.should == 0
    end
    
    ##开始检测注释
    it "不应包含无用注释" do
        comment = this_page.nokogiri.xpath("//comment()").to_a.map{|comment|comment.to_s}.delete_if{|comment|comment.start_with?'[if ie' or comment.include?'google' or comment.include?'baidu'}
        comment.to_s[0..500].should == nil unless comment.empty?
    end
=begin
    ##开始检测空白内容
    text.each do|seg|
        it "不应包含多余空白内容" do
            seg.should_not include "\n\n"
            seg.should_not include "\t\t"
            seg.should_not include "  "
        end
    end unless text.nil?
=end
    
    ##开始检测html定义标签
    it "应使用HTML5定义标签<!doctype html>" do
        this_page.nokogiri.internal_subset.name.downcase.should == 'html'
        this_page.nokogiri.internal_subset.external_id.should == nil
        this_page.nokogiri.internal_subset.system_id.should == nil
    end
    
    ##开始检测javascript
    this_page['script'].each do |script|
        it "'#{script.to_s[0..200].split("\n").join("").squeeze}' 应外部引入" do
            script['src'].to_s.should_not be_empty
        end
    end
        #this_page.search("//script").to_a.delete_if{|script|!script.attributes['src'].to_s.empty?}.map{|script|script.to_s.squeeze[0..50]}.should == []
    %w(src href).each do |attr|
        this_page.nodes_with('attr').each do |node|
            it "应该使用绝对路径或根路径: #{node}" do
                node_uri_obj = this_uri_obj(node.attributes[attr].value)
                node_uri_obj.path.should start_with '/' unless node_uri_obj.absolute? or node_uri_obj.path.empty?
            end
        end
    end

    this_page.links.each do |link| #禁止href为空的,禁止javascript,禁止route_to为空的,而且fragment为空的
        next if link['href'].nil and !link['name'].empty?#页内锚点

        ##开始检测产见无意义链接
        useless_link_texts = %w(隐私政策 服务条款 设置 登录 登入 注册 快速注册)|meta[:useless_anchor_texts].to_a
        it "#{link} 常见的无用链接应该标记nofollow" do
            link['rel'].should == 'nofollow' if useless_link_texts.include?link.text
        end
        ##检测href空的链接,这种既不是普通链接，也不是inpage_anchor的landing
        if link['href'].nil?
            it "#{link} 禁止使用<a>当按钮" do
                link['href'].should_not == nil
            end
            next
        end

        ######################以下都是href不空的#######################

        begin
            link_uri_obj = URI(link['href']).normalize
        rescue URI::InvalidURIError
            link_uri_obj = URI(URI.encode(link['href'])).normalize
            it "#{link} URI应作URI_ENCODE,URI中只能包含这些字符A-Za-z0-9._~:/?#[]@!$&%'()*+,;=-" do
                expect{URI(link['href'])}.not_to raise_error(URI::InvalidURIError)
            end
            next
        end

        ##开始检测链接空白字符
        it "链接中不能包含空白符号" do
            URI.decode(link['href']).should_not =~ /\s/
        end

        if link_uri_obj.relative? #相对地址，肯定都是站内链接,要防止滥用inpage_anchor的情况
            link_host = this_host
        else#绝对地址，可以是站内或者站外链接,或者是javascript:或者 mailto:
            link_host = link_uri_obj.host
            if link['href'] =~ /^javascript:/
                it "#{link} 禁止使用<a>当按钮" do #todo: 分析href协议,不是http, https则 错误, 分析uri 和 fragment , uri 是本页,而且fragment空的 错误. 考虑href="http://本页地址#"
                    link['href'].should_not =~ /^javascript:/
                end
                next
            end
        end

        ##开始检测到本页的链接，fragment不在所有inpage_anchors内的
        it "#{link} 禁止使用<a>当按钮=================" do #todo: 分析href协议,不是http, https则 错误, 分析uri 和 fragment , uri 是本页,而且fragment空的 错误. 考虑href="http://本页地址#"
            inpage_anchors.should include link_uri_obj.fragment unless link_uri_obj.fragment.nil?#buttons = this_page.links_with(:href=>'#') + this_page.links_with(:href=>'#?') + this_page.links_with(:href=>nil) + this_page.links_with(:href=>/^javascript:/)
        end# if link['href'].start_with?'#'
        ####################以下都不是把<a>当按钮用#########################
        next if link['rel'].to_s.include? 'nofollow'#忽略nofollow,@todo 错加nofollow的情况
        link_path = link_uri_obj.path #假定所有uri都已静态化

        if !$framework.has_key?link_host and !link_host.end_with?meta[:domain] #不处理外域名,交给友情链接
            warn "#{link_uri_obj} does not belong to any of the regexs"
            next
        end
        ##开始处理link_host未配置的链接
        it "#{link}, 的#{link_host}未配置，可能是非法链接,请标nofollow或请更新regex" do
            $framework[link_host].should_not == nil
        end
        ##开始处理regex集合未包括的链接
        it "#{link}, 属于非法链接请纠正,或标nofollow,或请更新regex" do
            #($framework.has_key?link_host).should == true
            $framework[link_host]['regex'].any?{|regex|link_path =~ regex}.should == true
        end

        queries = link_uri_obj.query || ""
        queries.split('&').each do |query|
            it "#{link['href']}中的参数#{query}无意义,需删除.若为统计用,请试用其他方式." do
                Mechanize.new.get URI.join("http://#{link_host}","#{link_path}?#{query}") do |link_page|
                    link_page = Webpage.new(link_page.body)
                    #link_page.body = link_page.body.force_encoding(this_page.encoding).encode('UTF-8') unless this_page.encoding.downcase.start_with? 'utf'
                    #link_page.encoding = 'utf-8'
                    link_page.title.should_not == this_page.title
                end
            end
        end
    end
end
