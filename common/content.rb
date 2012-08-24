#coding:UTF-8
shared_examples "页面 - 内容" do |meta|
    %(:uri :content :keywords).each do |key|
      abort "key '#{key}' missing" unless meta.has_key? key
    end
    this_page = Webpage.new(meta[:content].downcase)
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
    ##开始检测html定义标签
    it "应使用HTML5定义标签<!doctype html>" do
        this_page.nokogiri.internal_subset.name.downcase.should == 'html'
        this_page.nokogiri.internal_subset.external_id.should == nil
        this_page.nokogiri.internal_subset.system_id.should == nil
    end
end
