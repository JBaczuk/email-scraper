#!/usr/bin/ruby 
require 'mechanize'

$timer = 0
  def harvest(url, company_name)
    ext = [
      'contact', 'contact_us', 'contact-us',
      'contact.html', 'contact_us.html', 'contact_us.html',
      'contact.php', 'contact_us.php', 'contact_us.php'
    ]

       begin
        page = @agent.get(url)
        html = @agent.get(url).search('html').to_s
        mail = html.scan(/['.'\w|-]*@+[a-z]+[.]+\w{2,}/).map.to_a
        base = page.uri.to_s.split("//", 2).last.split("/", 2).first
        puts company_name
        mail.each{|e| @file.puts company_name + ";" + e+";"+url unless e.include? "example.com" or  e.include? "email.com" or  e.include? "domain.com" or  e.include? "company.com" or e.length < 9 or e[0] == "@"}
        for i in 0..ext.length
          begin
            html = @agent.get("http://#{base}/#{ext[i]}").search('html').to_s
            mail = html.scan(/['.'\w|-]*@+[a-z]+[.]+\w{2,}/).map.to_a
            mail.each{|e| @file.puts company_name + ";" + e+";"+url unless e.include? "example.com" or  e.include? "email.com" or  e.include? "domain.com" or  e.include? "company.com" or e.length < 9 or e[0] == "@"}
          rescue Exception => e
            puts e
          end
        end
      rescue Exception
      end
  end
@file = File.open(ARGV[1], 'a')
@file.puts "company_name;email;company_domain"
@agent = Mechanize.new
@mail = []
urls  = File.open(ARGV[0], "r:UTF-8").read
urls = urls.force_encoding('iso-8859-1').encode('utf-8')
urls = urls.split("\n")
urls[1..-1].each do |url|
  company_name = url.split(',')[0]
  url = url.split(',')[7]
  cols = url.scan(/[:]/)
  url = url.reverse.split(":", 2).last.reverse if cols.length > 1
  puts url
  harvest(url, company_name)
end