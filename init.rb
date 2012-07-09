require 'fileutils'
project = '163'
#hosts = %w(tuan.elong.com bid.elong.com flight.elong.com globalhotel.elong.com hotel.elong.com huixuan.elong.com trip.elong.com tuan.elong.com www.elong.com)
#hosts = %w(video.youdao.com zhushou.youdao.com fanyi.youdao.com f.youdao.com fanfan.youdao.com)
hosts = %w(fanxian.163.com)
hosts.each do |host|
    path = File.join('project',project,host)
    FileUtils.mkdir_p path
    ['redirects','robots','regex','links'].each do |filename|
        FileUtils.touch File.join(path,filename)
    end
end
