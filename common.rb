#coding:UTF-8
require 'rubygems'
require 'mechanize'
require 'pp'
require 'w3c_validators'
require 'yaml'
require 'pismo'
require 'rmmseg'
require 'fileutils'
require 'webpage'
require 'zlib'

describe 'base config' do
    it "should has defined $project" do
        $project.should_not be_emtpy
    end
    it "should has defined host" do
        host.should_not be_empty
    end
end
FileUtils.rm '/tmp/w3errors' if File.exists? '/tmp/w3errors'
include W3CValidators

def get_regex(host)
    YAML.load(File.read("project/#{$project}/#{host}/regex"))||{}
end

def get_redirects(host)
    YAML.load(File.read("project/#{$project}/#{host}/redirects"))||{}
end

def get_links(host)
    YAML.load(File.read("project/#{$project}/#{host}/links"))||{}
end

def get_robots(host)
    File.read("project/#{$project}/#{host}/robots")
end

def uri_obj(uri)
    require 'uri'
    begin
        URI uri
    rescue URI::InvalidURIError
        URI URI.encode(uri)
    end
end
$framework = {}
Dir.glob("project/#{$project}/*").each do |file|
    host = File.basename(file)
    $framework[host] ||= {}
    $framework[host]['regex'] = get_regex(host)
    $framework[host]['redirects'] = get_redirects(host)
    $framework[host]['robots'] = get_robots(host).strip
    $framework[host]['links'] = get_links(host)
end


shared_examples "完整页面" do |meta|
  it_behaves_like ""
  it_behaves_like ""
  it_behaves_like ""
  it_behaves_like ""
end
