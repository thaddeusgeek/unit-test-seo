#coding:UTF-8
require 'mechanize'
require 'pp'
require 'w3c_validators'
include W3CValidators

shared_examples_for "所有主机" do
    it "robots" do
        expect{Mechanize.new.get "http://#{$host}/robots.txt"}.not_to raise_error
    end
    
    $links.each do |link|
        link_from = link.shift
        Mechanize.new.get "http://#{$host}#{link_from}" do|page|
            link.each do|link_to|
                it "保证从'#{link_from}'链接到'#{link_to}' 而且没有nofollow" do
                    page.links.any?{|link|link.href==link_to}.should == true
                end
            end
        end
    end unless $links.nil?
    
    $redirects.each do |redirect|
        redirect[0] = "http://#{$host}#{redirect[0]}" unless redirect[0].start_with? 'http://'
        redirect[1] = "http://#{$host}#{redirect[1]}" unless redirect[1].start_with? 'http://'
=begin
        it "访问'#{redirect[0]}'不应返回4xx代码" do
            expect{agent.get redirect[0]}.not_to raise_error Mechanize::ResponseCodeError
        end
=end
        agent = Mechanize.new
        agent.redirect_ok = :permanent
        begin
            agent.get redirect[0] do |result|
                it "访问'#{redirect[0]}'应跳转到'#{redirect[1]}',且跳转一次" do
                    agent.history.size.should == 2
                end
                it "访问'#{redirect[0]}'应跳转到'#{redirect[1]}'" do
                    result.uri.to_s.should == redirect[1]
                end
            end
        rescue Mechanize::ResponseCodeError => e
            it "访问'#{redirect[0]}'不应返回404代码" do
                e.response_code.should == "200"
            end
        end
    end unless $redirects.nil?
end
shared_examples_for "固定链接页面" do
    $necessary_links.each do |nlink|
        it "应包含必要链接到#{nlink[0]}" do
            #$page.links.any?{|link|link.href == nlink[0] and link.text == nlink[1] and link.title == nlink[2]}.should == true #
            index = $page.links.index{|link|link.href == nlink[0]}
            index.should_not == nil
            next if index.nil?
            link = $page.links[index]
            unless nlink[2].nil?
                it "链接\"#{nlink[0]}\"的title应该是 #{nlink[2]}" do
                    link.title.should == nlink[2]
                end
            end
            link.text.should == nlink[1]
        end
    end unless $necessary_links.nil?
end

shared_examples_for "基本页面" do
    
    it "'#{$uri}'的title应 == #{$title} " do
        $page.title.should == $title unless $title.nil?
    end
    
    it "应包含正确的h1标签" do
        h1 = $page.search("//h1").should_not be_empty
        h1.first.text.should == $h1 unless $h1.nil?
        h1.each do |h|
            $keywords.any{|keyword|h.text.include? keyword}.should == true
        end unless $keywords.nil?
    end

    it "必须有唯一的canonical标签,而且其href值和标准uri一致" do
        canonical = $page.search "//link[@rel='canonical']"
        canonical.should_not be_empty
        canonical.size.should == 1
        canonical.first.attr('href').should == $uri
    end

    it "应包含唯一一个正确的meta keywords标签" do
        keywords = $page.search("//meta[@name='keywords']")
        keywords.size.should == 1
        keywords.first.content.should == $keywords unless $keywords.nil?
    end
    
    it "应包含唯一一个正确的meta description标签" do
        description = $page.search("//meta[@name='description']")
        description.size.should == 1
        description.first.content.should == $desciption unless $desciption.nil?
    end
end

shared_examples_for "所有页面" do

    it_behaves_like "基本页面"
    
    it "应把css归类用<link>引入,不应包含<style>标签" do
        $page.search("//style").should be_empty
    end
    
    it "应包含连续的<h>标签,假如有<h4>则应该存在<h3> <h2>" do
        $page.search("//h2").should_not be_empty unless $page.search("//h3").empty?
        $page.search("//h3").should_not be_empty unless $page.search("//h4").empty?
        $page.search("//h4").should_not be_empty unless $page.search("//h5").empty?
        $page.search("//h5").should_not be_empty unless $page.search("//h6").empty?
    end
    
    it "应遵守w3c规定" do
        @validator = MarkupValidator.new
        @validator.set_doctype!(:html32)
        @validator.validate_text($page.body).errors.should == nil
    end
    
    it "不应包含注释" do
        $page.search("//comment()").should == nil
    end
    
    it "不应包含多余空白符号" do
        text = $page.search("//text()")
        text.should_not include "\n\n"
        text.should_not include "\t\t"
        text.should_not include "  "
    end
    
    it "应使用HTML5定义标签" do
        doc = Nokogiri::HTML($page.body)

        doc.internal_subset.name.downcase.should == 'html'
        doc.internal_subset.external_id.should == nil
        doc.internal_subset.system_id.should == nil
    end
    
    
    it '应把js归类用<script src="">引入,不应包含<script type="text/javascript">' do
        $page.search("//script[@type='text/javascript']").should be_empty
    end

    it "每个URI应该都符合w3c标准" do
        $page.links.each do|link|
            expect{URI(link.href)}.not_to raise_error(URI::InvalidURIError)
        end
    end
    
    it "图片必须使用绝对路径,不许使用相对路径" do
        $page.images.each do|image|
            URI(image.src).path.should start_with '/'
        end
    end

    it "链接中不能包含空白符号" do
        $page.links.each do |link|
            link.href.should_not =~ /\s/
            link.href.should_not include "%20"
            link.href.should_not include "%09"
        end
    end
    
    it "没标nofollow的链接,必须遵守URI正则规范" do
        $page.links.each do |link|
            next if link.rel.first == 'nofollow' or link.href.nil?
            host = URI(link.href).host
            next if host.nil? or $domains.any?{|domain|host.end_with?domain}
            path = URI(link.href).path
            next unless path
            link.should do
                $uri_patterns.any?{|pattern|path =~ pattern}.should == true
            end
        end
    end
    
    $useless_link_texts = %w(隐私政策 服务条款 设置 登录 登入 注册 快速注册)
    $page.links.each do |link|
        it "一般无用链接应该标记nofollow" do
            link.rel.first.should == 'nofollow' if $useless_link_texts.include?link.text
        end
    end

    $page.links.each do |link|
        next if link.href.nil?
        begin
            host = URI(link.href).host
        rescue
            host = URI(URI.encode(link.href)).host
        end
        next if host.nil? or $domains.any?{|domain|host.end_with?domain}
        it "#{link.inspect}, 属于站外链接应该标nofollow" do
            link.rel.first.should == 'nofollow'
        end
    end
    
    it "禁止使用<a>当按钮" do
        #($page.links_with(:href=>nil) + page.links_with(:href=>'#')).should == nil
        buttons = $page.links_with(:href=>'#') +  $page.links_with(:href=>nil)
        buttons = nil if buttons.empty?
        buttons.should == nil
    end
end
