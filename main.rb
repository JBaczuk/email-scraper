#!/usr/bin/ruby 

# To run: ruby main.rb company_list.csv email_output.csv
# then: ruby clean.rb email_list.csv
require 'mechanize'

$timer = 0
@file = File.open(ARGV[1], 'a')

def searchEmails(sub_url, url, company_name)
  begin
    page = @agent.get(sub_url)
    begin
      html = page.search('html').to_s
    rescue NoMethodError => e
      puts e.message
    end
    mail = html&.scan(/['.'\w|-]*@+[a-z]+[.]+\w{2,}/)&.map.to_a
    base = page.uri.to_s&.split("//", 2).last&.split("/", 2)&.first
    mail.each do |e|
      @file.puts company_name + ";" + e+";"+url unless e.include? "example.com" or  e.include? "email.com" or  e.include? "domain.com" or  e.include? "company.com" or e.length < 9 or e[0] == "@"
      end    
  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Mechanize::ResponseCodeError,  
       Net::ProtocolError, Mechanize::UnsupportedSchemeError, Exception => e
    puts e.message
  end
end

def harvest(url)
  begin
    page = @agent.get(url)
    page.links.each do |link|
      page_base = page.uri.to_s&.split("//", 2).last&.split("/", 2)&.first
      link_base = link.href.to_s&.split("//", 2).last&.split("/", 2)&.first
      if page_base == link_base || link_base == "" # FIXME: skips if doesn't start with a /
        puts link.href
        searchEmails(link.href, url, company_name)
        puts "searched"
      else
        puts link.href
        puts "not searched"
      end
    end
    puts url
    searchEmails(url, url, company_name)
    puts "searched"
  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Mechanize::ResponseCodeError,  
       Net::ProtocolError, Mechanize::UnsupportedSchemeError, Exception => e
    puts e.message
  end
end

@file.puts "email;company_domain;company_name"
@agent = Mechanize.new
@agent.follow_meta_refresh = true
@mail = []
urls  = File.open(ARGV[0], "r:UTF-8").read
urls = urls.force_encoding('iso-8859-1').encode('utf-8')
urls = urls.split("\n")
urls[1..-1].each do |url|
  company_name = url.split(',')[0]
  url = url.split(',')[7]
  cols = url.scan(/[:]/)
  url = url.reverse.split(":", 2).last.reverse if cols.length > 1
  puts "New Website: "
  puts url
  harvest(url, company_name)
end