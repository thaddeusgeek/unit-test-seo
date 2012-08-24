#coding:UTF-8
shared_examples "增强页面" do |meta|
    %(:content).each do |key|
      abort "key '#{key}' missing" unless meta.has_key? key
    end
    pismo_text = Pismo::Document.new(meta[:content]).body.squeeze
    if pismo_text.size> 0
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
    ##开始检测W3C规范 it "不符合w3c规定的错误数应为0" do
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
end

