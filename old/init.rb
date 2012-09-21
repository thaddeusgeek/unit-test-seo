require 'fileutils'
project = '163'
#hosts = %w(tuan.elong.com bid.elong.com flight.elong.com globalhotel.elong.com hotel.elong.com huixuan.elong.com trip.elong.com tuan.elong.com www.elong.com)
#hosts = %w(video.youdao.com zhushou.youdao.com fanyi.youdao.com f.youdao.com fanfan.youdao.com)
hosts = %w(news.163.com fanxian.163.com www.163.com data.163.com gov.163.com blog.163.com bbs.163.com v.163.com gongyi.163.com sports.163.com ent.163.com money.163.com auto.163.com tech.163.com mobile.163.com lady.163.com house.163.com home.163.com edu.163.com book.163.com game.163.com t.163.com)
hosts.each do |host|
    path = File.join('project',project,host)
    FileUtils.mkdir_p path
    ['redirects','robots','regex','links'].each do |filename|
        FileUtils.touch File.join(path,filename)
    end
end
