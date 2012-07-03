#coding:UTF-8

require 'mechanize'
require 'pp'
require 'w3c_validators'
include W3CValidators

shared_examples "所有主机" do |meta|
    begin
        robots = Mechanize.new.get("http://#{meta[:host]}/robots.txt").body.lines.map{|line|line.strip}
        meta[:robots].each do |line|
            it "#{meta[:host]}/robots.txt应包含#{line}" do
                robots.should include line
            end
        end unless meta[:robots].nil?
    rescue Mechanize::ResponseCodeError
        it "robots" do
            expect{Mechanize.new.get "http://#{meta[:host]}/robots.txt"}.not_to raise_error
        end
    end
    
    meta[:links].each do |link|
        link_from = link.shift
        Mechanize.new.get "http://#{meta[:host]}#{link_from}" do|page|
            link.each do|link_to|
                it "保证从'#{link_from}'链接到'#{link_to}' 而且没有nofollow" do
                    page.links.any?{|link|link.href==link_to}.should == true
                end
            end
        end
    end unless meta[:links].nil?
    
    meta[:redirects].each do |redirect|
        redirect[0] = "http://#{meta[:host]}#{redirect[0]}" unless redirect[0].start_with? 'http://'
        redirect[1] = "http://#{meta[:host]}#{redirect[1]}" unless redirect[1].start_with? 'http://'
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
            it "访问'#{redirect[0]}'最后一跳之后应返回200." do
                e.response_code.should == "200"
            end
        end
    end unless meta[:redirects].nil?
end
shared_examples "固定链接页面" do |meta|
    meta[:page] = Mechanize.new.get meta[:uri] if meta[:page].nil?
    meta[:necessary_links].each do |nlink|
        it "应包含必要链接到#{nlink[0]}" do
            #meta[:page].links.any?{|link|link.href == nlink[0] and link.text == nlink[1] and link.title == nlink[2]}.should == true #
            index = meta[:page].links.index{|link|link.href == nlink[0]}
            index.should_not == nil
            next if index.nil?
            link = meta[:page].links[index]
            unless nlink[2].nil?
                it "链接\"#{nlink[0]}\"的title应该是 #{nlink[2]}" do
                    link.title.should == nlink[2]
                end
            end
            link.text.should == nlink[1]
        end
    end unless meta[:necessary_links].nil?
end

shared_examples "基本页面" do |meta|
    meta[:page] = Mechanize.new.get meta[:uri] if meta[:page].nil?
    it "'#{meta[:uri]}'的title应 == #{meta[:title]} " do
        meta[:page].title.should == meta[:title] unless meta[:title].nil?
    end
    
    meta[:page].links.each do |link|
        next if link.href.nil?
        begin
            queries = URI(link.href).query
        rescue URI::InvalidURIError
            queries = URI(URI.encode(link.href)).query
        end
        queries.split('&').each do |query|
            query = query.split('=')[0]
            it "'#{link.href}'.URI中不能包含keyfrom或vendor" do
                query.should_not == 'vendor'
                query.should_not == 'keyfrom'
            end
        end unless queries.nil?
    end
    
    it "应包含正确的h1标签" do
        h1 = meta[:page].search("//h1")#.should_not be_empty
        h1.first.text.should == meta[:h1] unless meta[:h1].nil?
        h1.each do |h|
            meta[:keywords].any{|keyword|h.text.include? keyword}.should == true
        end unless meta[:keywords].nil?
    end

    it "必须有唯一的canonical标签,而且其href值和标准uri一致" do
        canonical = meta[:page].search "//link[@rel='canonical']"
        canonical.should_not be_empty
        canonical.size.should == 1
        canonical.first.attr('href').should == meta[:uri]
    end

    it "应只包含一个meta keywords标签" do
        keywords = meta[:page].search("//meta[@name='keywords']")
        keywords.size.should == 1
    end
    
    it "keywords = '#{meta[:keywords]}'" do
        keywords = meta[:page].search("//meta[@name='keywords']")
        text = ''
        keywords.each do |key|
            text += key.attributes['content'].value
        end
        text.should == meta[:keywords].join(',') unless meta[:keywords].nil?
    end

    it "应只包含一个meta description标签" do
        meta[:page].search("//meta[@name='description']").size.should == 1
    end
    
    it "description = '#{meta[:description]}'" do
        description = meta[:page].search("//meta[@name='description']")
        text = ''
        description.each do |desc|
            text += desc.attributes['content'].value
        end
        text.should == meta[:description] unless meta[:description].nil?
    end
end

shared_examples "所有页面" do |meta|
    meta[:page] = Mechanize.new.get meta[:uri] if meta[:page].nil?

    it_behaves_like "基本页面" ,meta
    it "页面尺寸应小于100kb" do
        meta[:page].body.bytesize.should < 102400
    end
    it "总链接数应小于101" do
        meta[:page].links.size.should < 101
    end
    it "nofollow的链接应小于正常链接" do
        count_nofollow = 0
        meta[:page].links.each do |link|
            count_nofollow += 1 if link.rel.first == 'nofollow'
        end
        count_nofollow.should < meta[:page].links.size/2.0
    end
    it "应把css归类用<link>引入,不应包含<style>标签" do
        css = meta[:page].search("//style")
        css.to_s.should == nil unless css.empty?
    end
    
    it "应包含连续的<h>标签,假如有<h4>则应该存在<h3> <h2>" do
        meta[:page].search("//h2").should_not == nil unless meta[:page].search("//h3").empty?
        meta[:page].search("//h3").should_not be_empty unless meta[:page].search("//h4").empty?
        meta[:page].search("//h4").should_not be_empty unless meta[:page].search("//h5").empty?
        meta[:page].search("//h5").should_not be_empty unless meta[:page].search("//h6").empty?
    end
    
    it "不符合w3c规定的错误数应为0" do
        validator = MarkupValidator.new
        validator.set_doctype!(:html32)
        errors = validator.validate_text(meta[:page].body).errors
        `rm /tmp/w3errors` if File.exists? '/tmp/w3errors'
        File.open("/tmp/w3errors",'a'){|f|
            f.puts "===============================#{meta[:uri]}========================================"
            f.puts errors.join("\n")
        } unless errors.size == 0
        errors.size.should == 0
    end
    
    it "不应包含注释" do
        comment = meta[:page].search("//comment()")
        comment.to_s.should == nil unless comment.empty?
    end
    
    text = meta[:page].search("//text()")
    text.each do|seg|
        it "不应包含多余空白符号" do
            seg.should_not include "\n\n"
            seg.should_not include "\t\t"
            seg.should_not include "  "
        end
    end unless text.nil?
    
    it "应使用HTML5定义标签" do
        doc = Nokogiri::HTML(meta[:page].body)

        doc.internal_subset.name.downcase.should == 'html'
        doc.internal_subset.external_id.should == nil
        doc.internal_subset.system_id.should == nil
    end
    
    
    it '应把js归类用<script src="">引入,不应包含<script type="text/javascript">' do
        js = meta[:page].search("//script[@type='text/javascript']")
        js.to_s.should == nil unless js.nil?
    end

    it "每个URI应该都符合w3c标准" do
        meta[:page].links.each do|link|
            expect{URI(link.href)}.not_to raise_error(URI::InvalidURIError)
        end
    end
    
    it "图片必须使用绝对路径,不许使用相对路径" do
        meta[:page].images.each do|image|
            URI(image.src).path.should start_with '/'
        end
    end

    it "链接中不能包含空白符号" do
        meta[:page].links.each do |link|
            link.href.should_not =~ /\s/
            link.href.should_not include "%20"
            link.href.should_not include "%09"
        end
    end
    
    it "没标nofollow的链接,必须遵守URI正则规范" do
        meta[:page].links.each do |link|
            next if link.rel.first == 'nofollow' or link.href.nil?
            host = URI(link.href).host
            next if host.nil? or meta[:domains].any?{|domain|host.end_with?domain}
            path = URI(link.href).path
            next unless path
            link.should do
                meta[:uri_patterns].any?{|pattern|path =~ pattern}.should == true
            end
        end
    end
    
    useless_link_texts = %w(隐私政策 服务条款 设置 登录 登入 注册 快速注册)
    meta[:page].links.each do |link|
        it "一般无用链接应该标记nofollow #{useless_link_texts.join(' ')}" do
            link.rel.first.should == 'nofollow' if useless_link_texts.include?link.text
        end
    end

    meta[:page].links.each do |link|
        next if link.href.nil?
        begin
            host = URI(link.href).host
        rescue
            host = URI(URI.encode(link.href)).host
        end
        next if host.nil? or meta[:domains].any?{|domain|host.end_with?domain}
        it "#{link.inspect}, 属于站外链接应该标nofollow" do
            link.rel.first.should == 'nofollow'
        end
    end unless meta[:domains].nil?
    
    it "禁止使用<a>当按钮" do
        #(meta[:page].links_with(:href=>nil) + page.links_with(:href=>'#')).should == nil
        buttons = meta[:page].links_with(:href=>'#') +  meta[:page].links_with(:href=>nil)
        buttons.map{|b|b.to_s}.should == nil unless buttons.empty?
    end
end
