# coding: utf-8

shared_examples "BASIC" do
  it "标题符合规范" do
	  @page.title == @meta.title
	end
	
	it "关键字符合规范" do
	  @page.keywords == @meta.keywords
	end

	it "描述符合规范" do
	  @page.description == @meta.description
	end
end
