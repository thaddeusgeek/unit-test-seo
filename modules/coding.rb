#coding:UTF-8
shared_examples "程序" do |meta|
    this_page = Webpage.new(meta[:content].downcase)
end
