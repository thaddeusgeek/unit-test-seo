#coding:UTF-8
shered_examples "前端规范" do |meta|
    this_page = Webpage.new(meta[:content].downcase)
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

    ##开始检测javascript
    this_page['script'].each do |script|
        it "'#{script.to_s[0..200].split("\n").join("").squeeze}' 应外部引入" do
            script['src'].to_s.should_not be_empty
        end
    end
    it "应包含h1标签" do
        webpage['h1'].to_a.should_not == []
    end
    it "应包含正确的h1标签" do
        webpage['h1'].text.should == meta[:h1] if meta[:h1]
    end
    it "<h1>应包含至少一个关键词#{keywords}" do
        meta[:keywords].any?{|keyword|webpage['h1'].text.include? keyword}.should == true
    end
end
