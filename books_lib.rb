
def error_handing(args, usage)
   if args.length != 2
     raise "Usage  #{usage}"
   end
	
	raise "File '#{args[0]}' does not exist." unless File.exists? args[0]	
	begin
		Integer(args[1])
	rescue Exception => e
		raise "#{args[1]} is not a integer"
	end
	
end



class Books
	require 'sqlite3'
	require "pp"
	
	def initialize(db)
		@db = SQLite3::Database.new( db )
	end
	
	def list_collections
		query = <<-SQL
			Select cc.Z_PK, cc.ZTITLE
			From ZBKCOLLECTION cc
			Order by Z_PK
		SQL
		
		results = @db.execute query
		results.each do |e|
			puts " %2d %s" % e
		end
		
	end
	
	def sort_collection(collection_id, field)
		puts "#{collection_id}, #{field}"
		query = <<-SQL
		Select  b.Z_PK, b.ZSORTTITLE ,b.ZSORTKEY, ZSORTAUTHOR
		from ZBKCOLLECTIONMEMBER c
		Join ZBKBOOKINFO  b on c.ZDATABASEKEY = b.ZDATABASEKEY
		Join ZBKCOLLECTION cc on cc.Z_PK = c.ZCOLLECTION
		where cc.Z_PK='#{collection_id}'
		Order by b.ZSORTAUTHOR, b.ZSORTTITLE
		SQL
		
		results = @db.execute query
		
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
		
		# Update
		results.each do |e|
			puts @db.execute(
				"Update ZBKBOOKINFO
				 Set ZSORTKEY = #{e[2]}
				 where Z_PK   = #{e[0]}"
			)
		end
	end
	
end