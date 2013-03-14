#! ruby -Ks

require "csv"

POINT = 0
UMA = 1
RANK = 2

class Senseki
	def initialize(data = [["0","0","1"],["0","0","1"]])
		@rank_count = [0, 0, 0, 0, 0]
		@total_count = 0
		@sum_point = 0
		@rank_point = [0, 0, 0, 0 ,0]

		data.each { |column|
			@rank_count[column[RANK].to_i] += 1
			@sum_point += (column[POINT].to_i + column[UMA].to_i)
			@rank_point[column[RANK].to_i] += column[POINT].to_i
		}
		@total_count = @rank_count[1]+@rank_count[2]+@rank_count[3]+@rank_count[4]
	end

	def get_rank_count
		return @rank_count
	end
		
	def get_total_count
		return @total_count
	end
	
	def get_sum_point
		return @sum_point
	end
	
	def calc_average_rank
	    return (@rank_count[1]*1 + @rank_count[2]*2 +@rank_count[3]*3 +@rank_count[4]*4) / (@total_count.to_f)
	end
	
	def calc_rank_retio(rank)
		return @rank_count[rank] / (@total_count.to_f) * 100.0
	end

	def calc_rank_average_point(rank)
		if (@rank_count[rank] == 0)
			return 0
		else
			return @rank_point[rank] / (@rank_count[rank].to_f)
		end
	end

	def calc_average_point
		if (@total_count == 0)
			return 0
		else
			return @sum_point / (@total_count.to_f)
		end
	end

	def debug_display
		print("rank_count:")
		p @rank_count
		print("total_count:")
		p @total_count
		print("sum_point:")
		p @sum_point
		print("rank_point:")
		p @rank_point
	end
end

# -----start------ #

namecsvlist = Dir['temp/*.csv']
#p namecsvlist
#namelistcsv = "name.csv"
#namelist = CSV.open(namelistcsv, "r")

outputcsv = "out.csv"
writer = CSV.open(outputcsv, "w")
writer << ["–¼‘O","1ˆÊ","2ˆÊ","3ˆÊ","4ˆÊ","ƒQ[ƒ€”","•½‹Ï‡ˆÊ","1ˆÊ—¦","2ˆÊ—¦","3ˆÊ—¦","4ˆÊ—¦","‡Œv“_","•½‹Ï“_","1ˆÊ•½‹Ï‘f“_","2ˆÊ•½‹Ï‘f“_","3ˆÊ•½‹Ï‘f“_","4ˆÊ•½‹Ï‘f“_"]

namecsvlist.each { |filename|
	reader = CSV.open(filename, "r")

	count = 0
	data = [""]
	reader.each {|row|
		data[count] = row
		count += 1
	}

	senseki = Senseki.new(data)

	rankCount = [0, 0, 0, 0, 0]
	rankRetio = [0, 0, 0, 0, 0]
	averageRankPoint = [0, 0, 0, 0, 0]
    rankCount = senseki.get_rank_count
	for num in 1..4 do
		rankRetio[num] = senseki.calc_rank_retio(num)
		averageRankPoint[num] = senseki.calc_rank_average_point(num)
	end
    name = filename.gsub(/(temp\/)|(.csv)/, "")
	writer << [name,
	            rankCount[1],
	            rankCount[2],
	            rankCount[3],
	            rankCount[4],
				senseki.get_total_count,
				sprintf("%2.2f",senseki.calc_average_rank),
				sprintf("%2.1f",rankRetio[1])+"%",
				sprintf("%2.1f",rankRetio[2])+"%",
				sprintf("%2.1f",rankRetio[3])+"%",
				sprintf("%2.1f",rankRetio[4])+"%",
				senseki.get_sum_point, 
				sprintf("%2.1f", senseki.calc_average_point),
				sprintf("%2.1f", averageRankPoint[1]),
				sprintf("%2.1f", averageRankPoint[2]),
				sprintf("%2.1f", averageRankPoint[3]),
				sprintf("%2.1f", averageRankPoint[4]),]
}


