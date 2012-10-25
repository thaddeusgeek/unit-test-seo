# coding: UTF-8

shared_examples "链接页面" do |meta, page|

  inpage_anchors = (page.nodes_with('id')+page.nodes_with('name')).map{|node|node.value}

  it_behaves_like "基本页面", meta, page 

  %w(src href).each do |attr|
    page.nodes_with(attr).each do |node|
			begin
				link_uri = URI.parse(node.value).normalize
			rescue URI::InvalidURIError
				link_uri = URI.parse(URI.encode(node.value)).normalize
				it "#{node.value} URI应作URI_ENCODE,URI中只能包含这些字符A-Za-z0-9._~:/?#[]@!$&%'()*+,;=-" do
					# expect{URI(link['href'])}.not_to raise_error(URI::InvalidURIError)
					node.value.should == link_uri.to_s
				end
				next
			end
      link_uri = URI.parse(node.value)
			next if link_uri.query
      it "应该使用绝对路径或根路径: #{node}" do
        link_uri.to_s.should match(%r{^/}) if !link_uri.absolute?
      end
    end
  end

  # page.links.each { |link| p link }
  page.links.each do |link| #禁止href为空的,禁止javascript,禁止route_to为空的,而且fragment为空的
    next if link['href'].nil? and !link['name'].nil? # 页内锚点 有name无href

    ##开始检测产见无意义链接
    useless_link_texts = %w(隐私政策 服务条款 设置 登录 登入 注册 快速注册)
    it "#{link} 常见的无用链接应该标记nofollow" do
      link['rel'].should == 'nofollow' if useless_link_texts.include?(link.text)
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
      link_uri = URI.parse(link['href']).normalize
    rescue URI::InvalidURIError
      link_uri = URI.parse(URI.encode(link['href'])).normalize
      it "#{link['href']} URI应作URI_ENCODE,URI中只能包含这些字符A-Za-z0-9._~:/?#[]@!$&%'()*+,;=-" do
        # expect{URI(link['href'])}.not_to raise_error(URI::InvalidURIError)
        link['href'].should == link_uri.to_s
      end
      next
    end

    link_uri = URI.parse(link['href'])

    ##开始检测链接空白字符
    # it "链接中不能包含空白符号" do
    #   URI.decode(link['href']).should_not =~ /\s/
    # end

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if link_uri.relative? #相对地址，肯定都是站内链接,要防止滥用inpage_anchor的情况
      link_host = URI.parse(meta[:uri]).host
    else #绝对地址，可以是站内或者站外链接,或者是javascript:或者 mailto:
      link_host = link_uri.host
      if link['href'] =~ /^javascript:/
        it "#{link} 禁止使用<a>当按钮" do 
				#todo: 分析href协议,不是http, https则 错误, 
        #分析link_uri 和 fragment , link_uri 是本页,而且fragment空的 错误. 考虑href="http://本页地址#"
          link['href'].should_not =~ /^javascript:/
        end
        next
      end
    end
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    ##开始检测到本页的链接，fragment不在所有inpage_anchors内的
		if link_uri.host == URI.parse(meta[:uri]).host && link_uri.path == URI.parse(meta[:uri]).path # 同一页面
      it "#{link} 禁止使用<a>当按钮=================" do 
		  #todo: 分析href协议,不是http, https则 错误, 
      #分析link_uri 和 fragment , link_uri 是本页,而且fragment空的 错误. 考虑href="http://本页地址#"
        inpage_anchors.should include link_uri.fragment if !link_uri.fragment.nil?
	  		#buttons = page.links_with(:href=>'#') + page.links_with(:href=>'#?') + page.links_with(:href=>nil) + page.links_with(:href=>/^javascript:/)
      end# if link['href'].start_with?'#'
		end
    ####################以下都不是把<a>当按钮用#########################
    next if link['rel'].to_s.include? 'nofollow'#忽略nofollow,@todo 错加nofollow的情况
    link_path = link_uri.path #假定所有link_uri都已静态化

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# $frameword含义不明
#    if !$framework.has_key?link_host and !link_host.end_with?meta[:domain] #不处理外域名,交给友情链接
#      warn "#{link_uri} does not belong to any of the regexs"
#      next
#    end
#    ##开始处理link_host未配置的链接
#    it "#{link}, 的#{link_host}未配置，可能是非法链接,请标nofollow或请更新regex" do
#      $framework[link_host].should_not == nil
#    end
#    ##开始处理regex集合未包括的链接
#    it "#{link}, 属于非法链接请纠正,或标nofollow,或请更新regex" do
#      #($framework.has_key?link_host).should == true
#      $framework[link_host]['regex'].any?{|regex|link_path =~ regex}.should == true
#    end
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # queries = link_uri.query || ""
		if link_uri.query.nil?
			next
		else
			queries = link_uri.query
		end
    queries.split('&').each do |query|
      it "#{link['href']}中的参数#{query}无意义,需删除.若为统计用,请试用其他方式." do
        agent = Mechanize.new.get URI.join("http://#{link_host}","#{link_path}?#{query}")
        link_page = Webpage.new(page.body)
        #link_page.body = link_page.body.force_encoding(page.encoding).encode('UTF-8') unless page.encoding.downcase.start_with? 'utf'
        #link_page.encoding = 'utf-8'
        link_page.title.should_not == page.title
      end
    end
  end

end
