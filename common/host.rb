#coding:UTF-8
shared_examples "主机" do |host|
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

