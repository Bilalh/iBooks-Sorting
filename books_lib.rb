# Bilal Syed Hussain

Mapping ={
	:author      => "b.ZSORTAUTHOR",
	:real_author => "b.ZBOOKAUTHOR",
	:title       => "b.ZBOOKTITLE",
	:sort_title  => "b.ZSORTTITLE",
	:series      => "b.ZGENRE",
}

def short_help
	"books_db collection_id [extra sort fields]"
end
def command_help
"""
	Can use extra sort fields: #{Mapping.keys.join ", "}
"""
end

def preform_actions(c,global_options,options,args)
	error_handing args, c.usage
	
	fields = parse_subsort args[2..-1]
	fields.unshift c.name
	
	reverse = global_options.has_key?(:reverse) ? global_options[:reverse] : false
	
	books = Books.new args[0]
	books.sort_collection args[1].to_i, fields, reverse
end

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
	
	def move_all_books(from, to)
		puts "Moving all books from collection #{from} to collection #{to}"
		query = <<-SQL
			update ZBKCOLLECTIONMEMBER
			set   ZCOLLECTION  = #{to}
			where ZCOLLECTION  = #{from}
		SQL
		puts @db.execute query
	end
	
	def sort_collection(collection_id, fields_arr,reverse=false)
		puts "Sorting #{collection_id}, by #{fields_arr} #{reverse}"
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
		end.sort
		
		numbers.reverse! if !reverse
		
		# pp numbers
		
		# set the sort keys
		results.each_with_index do |e, i|
			e['ZSORTKEY']= numbers[i]
		end
		
		puts "Highest sortkey appears first in iBooks"
		results.each do |e|
			puts "%10s %-25s %s" % [e['ZSORTKEY'], e['ZSORTAUTHOR'], e['ZSORTTITLE']]
			puts "%10s %-25s %s" % ["","", e['ZBOOKTITLE']]
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