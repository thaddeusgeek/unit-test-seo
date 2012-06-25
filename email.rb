#coding:UTF-8

require "base64"
require 'net/smtp'

def send_email(to,body,opts={})
    opts[:server]      ||= 'soda.rd.netease.com'
    opts[:from]        ||= 'liuming@rd.netease.com'
    #opts[:from_alias]  ||= '刘明'
    opts[:subject]     ||= "错误报告"

msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}
Content-Transfer-Encoding:8bit
Content-type: text/plain; charset=utf-8\r\n

#{body}
END_OF_MESSAGE

Net::SMTP.start(opts[:server]) do |smtp|
      smtp.send_message msg, opts[:from], to
    end
end
body = `rspec do.rb`
send_email('lvbo@rd.netease.com',body)
