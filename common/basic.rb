# coding: UTF-8

shared_examples "基本页面" do |meta, page|
    [:uri, :content, :keywords, :title, :description].each do |key|
      warn "key '#{key}' missing" unless meta.has_key? key
    end

    it "'#{meta[:uri]}'的title应 =~ #{meta[:title]} " do
        page.title.should =~ meta[:title] unless meta[:title].nil?
    end

    if page['canonical'].empty?
        # it "应在<head>标签中包含<link rel=\"canonical\">" do
        #     page['canonical'].should_not be_empty
        # end
    else
        it "应在<head>中包含唯一的canonical标签" do
            page['canonical'].size.should == 1
        end
        it "应在<head>标签中包含<link rel=\"canonical\" href=\"#{this_uri}\"\>" do
            page['canonical'].first['href'].should == meta[:uri]
        end
    end

    if page['keywords'].empty?
        it "应包含一个meta keywords标签" do
            page['keywords'].should_not be_empty
        end
    else
        it "应只包含一个meta keywords标签" do
            page['keywords'].size.should == 1
        end
        it "应包含与配置一致的keywords" do
            # meta_keys = meta[:keywords].split(',')
            # page_keys = page['keywords'][0].attributes['content'].value.split(',')
            # page['keywords'].should == meta[:keywords]
            page.keywords.sort.should == meta[:keywords].sort
        end
    end

    if page['description'].empty?
        it "应包含一个meta description标签" do
            page['description'].should_not be_empty
        end
    else
        it "应只包含一个meta description标签" do
            page['description'].size.should == 1
        end
        it "应包含与配置一致的description" do
            # page_description = page['description'][0].attributes['content'].value
            page.description.should == meta[:description]
        end
        it "description不能是keywords堆砌" do
            description_online = page.description
            meta[:keywords].each { |keyword| description_online.delete(keyword) }
            description_online.size.should > 50
        end
    end
end
##########

