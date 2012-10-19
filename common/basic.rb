#coding:UTF-8
shared_examples "基本页面" do |meta|
    %(:uri :content :keywords :title :description).each do |key|
      abort "key '#{key}' missing" unless meta.has_key? key
    end
    this_uri = meta[:uri]
    this_page = Mechanize.new.get this_uri
    webpage = Webpage.new(meta[:content])
    keywords = meta[:keywords] || []
    it "'#{this_uri}'的title应 == #{meta[:title]} " do
        this_page.title.should == meta[:title] unless meta[:title].nil?
        thititles_page.should =~ meta[:title] unless meta[:title].nil?
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
##########

