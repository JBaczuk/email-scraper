file = File.open(ARGV[0]).read.to_s
entries = file.split("\n")
mail = []
entries.each{|e| mail << e.downcase if e[0] != "@"}
mail = mail.uniq
File.open(ARGV[0], "w"){|f| f.puts mail}
