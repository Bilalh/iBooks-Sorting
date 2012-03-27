#!/usr/bin/env ruby19 -wKU
# Sorts a collection in iBooks by author then name.
# After updating the db, either close ibooks or turn the phone off then on again to see the changes.
# Bilal Hussain

require 'sqlite3'
require "pp"

(puts "#{File.basename $0} Collection Z_PK iBooks sqlite"; exit) if ARGV.length != 2

collectionId = ARGV[0]
IBooksDB = File.expand_path(ARGV[1])

db = SQLite3::Database.new( IBooksDB )
#db.results_as_hash = true;

query = <<-SQL
Select  b.Z_PK, b.ZSORTTITLE ,b.ZSORTKEY, ZSORTAUTHOR
from ZBKCOLLECTIONMEMBER c
Join ZBKBOOKINFO  b on c.ZDATABASEKEY = b.ZDATABASEKEY
Join ZBKCOLLECTION cc on cc.Z_PK = c.ZCOLLECTION
where cc.Z_PK='#{collectionId}'
Order by b.ZSORTAUTHOR, b.ZSORTTITLE
SQL

results = db.execute( query )

# Get the sort keys highest first
numbers  = results.collect do |e|
	e[2]
end.sort.reverse

# pp numbers

# set the sort keys
results.each_with_index do |e, i|
	e[2]= numbers[i]
end

puts
pp results

results.each do |e|
	puts db.execute(
		"Update ZBKBOOKINFO
		 Set ZSORTKEY = #{e[2]}
		 where Z_PK   = #{e[0]}"
	)
end
