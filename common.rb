#coding:UTF-8
require 'mechanize'
require 'pp'
require 'w3c_validators'
require 'yaml'
require 'pismo'
require 'rmmseg'
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
class Mechanize::Page::Link
    def title
        attributes['title']
    end
    def to_html
        code = "<a href=\"#{href}\""
        code += " title=\"#{title}\"" unless title.nil?
        code += " rel=\"#{rel}\"" unless rel.nil?
        code += ">#{text}</atest>"
        return code
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

shared_examples "所有主机" do |meta|
    host = meta[:host]
    it "检查配置" do
        $framework[host].should_not be_empty
        $framework[host]['regex'].should_not be_empty
        $framework[host]['redirects'].should_not be_empty
        $framework[host]['robots'].should_not be_empty
        $framework[host]['links'].should_not be_empty
    end
    
    robots_uri = "http://#{host}/robots.txt"
    begin
        it "robots文件应与配置文件一致,请检查更新配置文件" do
            $framework[host]['robots'].should == Mechanize.new.get(robots_uri).body.strip
        end
    rescue Mechanize::ResponseCodeError
        it "应该有robots文件 #{robots_uri}" do
            expect{Mechanize.new.get robots_uri}.not_to raise_error
        end
    end

    $framework[host]['links'].each_pair do |link_from,link_tos|
        link_from = "http://#{host}#{link_from}" if URI(link_from).relative?
        it "保证#{link_from}页面存在" do
        end
        Mechanize.new.get link_from do |page|
            link_tos.each do|link_to|
                the_links = page.links_with(:href=>link_to[0]).delete_if{|link|link.rel=='nofollow'}.delete_if{|link|link.text.nil? or link.text != link_to[1]}.delete_if{|link|link.attributes['title'].nil? or link.attributes['title'] != link_to[2]}
                it "保证'http://#{host}#{link_from}'中有链接<a href=\"#{link_to[0]}\">#{link_to[1]} title=\"#{link_to[2]}\"</a> (不能有nofollow)" do
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
    uri = meta[:uri]
    #page = meta[:page].nil? ? Mechanize.new.get(uri) : meta[:page]
    page = Mechanize.new.get uri
    title = meta[:title]
    h1 = meta[:h1]
    keywords = meta[:keywords] || []
    it "'#{uri}'的title应 == #{title} " do
        page.title.should == title unless title.nil?
    end

    
    h1_online = page.search("//h1").to_a#.should_not be_empty
    it "应包含正确的h1标签" do
        h1_online.first.text.should == h1 unless h1.nil?
    end
    
    it "<h1>应包含至少一个关键词#{keywords}" do
        h1_online.each do |h|
            keywords.any?{|keyword|h.text.include? keyword}.should == true
        end
    end

    it "必须有唯一的canonical标签,而且其href值和标准uri一致" do
        canonical = page.search "//link[@rel='canonical']"
        canonical.should_not be_empty
        canonical.size.should == 1
        canonical.first.attr('href').should == uri
    end

    it "应只包含一个meta keywords标签" do
        keywords = page.search("//meta[@name='keywords']")
        keywords.size.should == 1
    end
    
    it "keywords = '#{meta[:keywords]}'" do
        keywords_online = ''
        page.search("//meta[@name='keywords']").each do |key|
            keywords_online += key.attributes['content'].value
        end
        keywords_online.should == meta[:keywords].join(',') unless meta[:keywords].nil?
    end

    it "应只包含一个meta description标签" do
        page.search("//meta[@name='description']").size.should == 1
    end
    
    description_online = ''
    page.search("//meta[@name='description']").each do |desc|
        description_online += desc.attributes['content'].value
    end
    it "description = '#{meta[:description]}'" do
        description_online.should =~ /#{meta[:description]}/ unless meta[:description].nil?
    end
    it "description不能是keywords堆砌" do
        keywords.each{|keyword| description_online.delete keyword }
        description_online.size.should > 50
    end
end

shared_examples "所有页面" do |meta|
    uri = meta[:uri]
    keywords = meta[:keywords] || []
    begin
        uri_obj = URI(uri)
    rescue URI::InvalidURIError
        uri_obj = URI(URI.encode(uri))
    end
    host = uri_obj.host
    domain = (host.match /\.?([a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)$/)[1]
    #page = meta[:page].nil? ? Mechanize.new.get(uri) : meta[:page]
    page = Mechanize.new.get uri
    page.body = page.body.force_encoding('GBK').encode('UTF-8') if page.encoding.downcase.start_with? 'gb'
    page.body = page.body.downcase
    page.encoding = 'utf-8'
    anchors = page.search("//@id | //@name").map{|node|node.value}
    links_follow = page.links.delete_if{|link|link.rel.include? 'nofollow'}
    links_nofollow = page.links.delete_if{|link|link.rel.nil? or !link.rel.include? 'nofollow'}
    text = page.search("//text()")
    text_squeeze = text.to_s.squeeze
    pismo_text = Pismo::Document.new(page.body).body.squeeze

    it_behaves_like "基本页面" ,meta

    it "主体内容应占总内容的50%以上(功能不稳定)" do
        (pismo_text.size/text.to_s.squeeze.size.to_f).should > 0.5
    end
    
    RMMSeg::Dictionary.load_dictionaries#  Ferret::Analysis::StopFilter
    rmmseg = RMMSeg::Algorithm.new(text_squeeze)
    seg_count = 0
    seg_count += 1 while rmmseg.next_token
    keywords.each do |keyword|
        it "'#{keyword}'的密度应该在2%到10%之间" do
            tmp_density = (text_squeeze.scan(/#{keyword}/).size.to_f / seg_count)
            tmp_density.should < 0.1
            tmp_density.should > 0.02
        end
    end

    
    it "页面尺寸应小于100kb" do
        page.body.bytesize.should < 102400
    end

    it "总链接数应小于101" do
        page.links.size.should < 101
    end

    it "nofollow的链接应小于正常链接" do
        links_nofollow.size.should <= page.links.size/2
    end

    it "应把css归类用<link>引入,不应包含<style>标签" do
        css = page.search("//style")
        css.to_s.should == nil unless css.empty?
    end
    
    it "应包含连续的<h>标签,假如有<h4>则应该存在<h3> <h2>" do
        page.search("//h2").should_not be_empty unless page.search("//h3").empty?
        page.search("//h3").should_not be_empty unless page.search("//h4").empty?
        page.search("//h4").should_not be_empty unless page.search("//h5").empty?
        page.search("//h5").should_not be_empty unless page.search("//h6").empty?
    end
=begin
    it "不符合w3c规定的错误数应为0" do
        validator = MarkupValidator.new
        validator.set_doctype!(:html32)
        errors = validator.validate_text(page.body).errors
        File.open("/tmp/w3errors",'a'){|f|
            f.puts "===============================#{uri}========================================"
            f.puts errors.join("\n")
        } unless errors.size == 0
        errors.size.should == 0
    end
=end
    
    it "不应包含注释" do
        comment = page.search("//comment()").to_a.map{|comment|comment.to_s}.delete_if{|comment|comment.start_with?'[if IE'}
        comment.to_s[0..500].should == nil unless comment.empty?
    end
    
    text.each do|seg|
        it "不应包含多余空白符号" do
            seg.should_not include "\n\n"
            seg.should_not include "\t\t"
            seg.should_not include "  "
        end
    end unless text.nil?
    
    it "应使用HTML5定义标签" do
        doc = Nokogiri::HTML(page.body)

        doc.internal_subset.name.downcase.should == 'html'
        doc.internal_subset.external_id.should == nil
        doc.internal_subset.system_id.should == nil
    end
    
    
    it "javascript应外部引入" do
        page.search("//script").to_a.delete_if{|script|!script.attributes['src'].to_s.empty?}.map{|script|script.to_s[0..50]}.should == []
    end

=begin
    it "链接中不能包含空白符号" do
        page.links.each do |link|
            next if link.href.nil?
            link.href.should_not =~ /\s/
            link.href.should_not include "%20"
            link.href.should_not include "%09"
        end
    end
=end
    
    it "图片必须使用绝对路径,不许使用相对路径" do
        page.images.each do|image|
            uri_obj(image.src).path.should start_with '/' if URI(image.src).relative?
        end
    end

    
    useless_link_texts = %w(隐私政策 服务条款 设置 登录 登入 注册 快速注册)
    page.links.each do |link|
        it "一般无用链接应该标记nofollow #{useless_link_texts.join(' ')}" do
            link.rel.first.should == 'nofollow' if useless_link_texts.include?link.text
        end
    end
    page.links do |link| #禁止href为空的,禁止javascript,禁止route_to为空的,而且fragment为空的
        next unless link.name.nil? #页内锚点
        begin
            link_uri_obj = URI(link.href)
        rescue URI::InvalidURIError
            it "#{link.to_html} URI应符合w3c标准" do
                expect{URI(link.href)}.not_to raise_error(URI::InvalidURIError)
            end
            link_uri_obj = URI(URI.encode(link.href))
        end
        link_absolute_href = File.join("http://#{host}",link.href.to_s) if link_uri_obj.relative?
        link_route_href = uri_obj.route_to(link_absolute_href)
        if link_route_href.to_s.empty?
            it "#{link.to_html} 禁止使用<a>当按钮" do #todo: 分析href协议,不是http, https则 错误, 分析uri 和 fragment , uri 是本页,而且fragment空的 错误. 考虑href="http://本页地址#"
            #(page.links_with(:href=>nil) + page.links_with(:href=>'#')).should == nil
                link_route_href.to_s.should_not == ""
                anchors.should include link_uri_obj.fragment #buttons = page.links_with(:href=>'#') + page.links_with(:href=>'#?') + page.links_with(:href=>nil) + page.links_with(:href=>/^javascript:/)
            end
        else#现在只有几种情况:javascript协议的,非根路径的,不符合regex的,包含无用参数的
            it "#{link.to_html} 链接必须使用根路径" do
                link.href.should start_with start_with '/'
            end if link.uri_obj.relative?
            
            it "#{link.to_html} 禁止使用<a>当按钮" do #todo: 分析href协议,不是http, https则 错误, 分析uri 和 fragment , uri 是本页,而且fragment空的 错误. 考虑href="http://本页地址#"
                link.href.downcase.should_not =~ /^javascript:/
            end

            it "#{link.to_html} 需要URI encode" do #可能跟w3c认证重合
                link.href.delete("A-Za-z0-9._~:/?#[]@!$&%'()*+,;= -").should == ""
            end

            link_host = link_route_href.host
            link_path = link_route_href.path.to_s
            link_path += "?"+link_route_href.query.to_s unless link_route_href.query.empty?
            next unless !$framework.has_key?link_host and !link_host.end_with?domain #不处理外域名,交给友情链接
            it "#{link.to_html}, 属于非法链接请纠正,或标nofollow,或请更新regex" do
                #($framework.has_key?link_host).should == true
                $framework[link_host]['regex'].any?{|regex|link_path =~ regex}.should == true
            end

            queries = link_route_href.query || ""
            queries.split('&').each do |query|
                key,value = query.split('=')
                it "#{link.href}中的参数#{query}无意义,需删除.若为统计用,请试用其他方式." do
                    newhref = uri_obj.route_to(link.uri_obj)
                    Mechanize.new.get File.join("http://#{link_host}","#{link_path}?#{query}") do |link_page|
                        link_page.title.should_not == page.title
                    end
                end
            end
        end
    end
    page.links.each do |link|
        next if link.href.nil?
        queries = uri_obj(link.href).query
        queries.split('&').each do |query|
            query = query.split('=')[0]
            it "'#{link.href}'.URI中不能包含keyfrom或vendor" do
                query.should_not == 'vendor'
                query.should_not == 'keyfrom'
            end
        end unless queries.nil?
    end
end
