Mapping ={
	:author     => "b.ZSORTAUTHOR",
	:title      => "b.ZBOOKTITLE",
	:sort_title => "b.ZSORTTITLE"
}

def error_handing(args, usage,strict=false)
   if  (strict && args.length != 2) || args.length < 2
     raise "Usage  #{usage}"
   end
	
	raise "File '#{args[0]}' does not exist." unless File.exists? args[0]	
	begin
		Integer(args[1])
	rescue Exception => e
		raise "#{args[1]} is not a integer"
	end
	
end


def parse_subsort(args)
	fields=[]
	args.each do |e|
		f = e.to_sym
		raise "Invalid sort field #{e}" unless Mapping.has_key? f
		fields << f
	end
	fields
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
	
	def sort_collection(collection_id, fields_arr)
		puts "Sorting #{collection_id}, by #{fields_arr}"
		@db.results_as_hash = true
		
		
		fields_arr.map! do |e|
			Mapping[e]
		end
		fields     = fields_arr.join ','
		
		query = <<-SQL
		Select  b.Z_PK, b.ZSORTTITLE ,b.ZSORTKEY, ZSORTAUTHOR, b.ZBOOKTITLE
		from ZBKCOLLECTIONMEMBER c
		Join ZBKBOOKINFO  b on c.ZDATABASEKEY = b.ZDATABASEKEY
		Join ZBKCOLLECTION cc on cc.Z_PK = c.ZCOLLECTION
		where cc.Z_PK='#{collection_id}'
		Order by #{fields}
		SQL
		
		results = @db.execute query
		
		# Get the sort keys highest first
		numbers  = results.collect do |e|
			e['ZSORTKEY']
		end.sort.reverse
		
		# pp numbers
		
		# set the sort keys
		results.each_with_index do |e, i|
			e['ZSORTKEY']= numbers[i]
		end
		
		puts "Highest sortkey appears first"
		results.each do |e|
			puts "%10d %-25s %s" % [e['ZSORTKEY'], e['ZSORTAUTHOR'], e['ZSORTTITLE']]
			puts "%10d %-25s %s" % [e['ZSORTKEY'], e['ZSORTAUTHOR'], e['ZBOOKTITLE']]
		end
		
		# Update
		results.each do |e|
			puts @db.execute(
				"Update ZBKBOOKINFO
				 Set ZSORTKEY = #{e['ZSORTKEY']}
				 where Z_PK   = #{e['Z_PK']}"
			)
		end
	end
	
end