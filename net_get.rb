#! ruby -Ks

require 'net/http'
require 'uri'
require 'csv'

NODATA = 255

class MemberData
    def initialize(name)
        @name = name
        @dataCount = 0
        @writer = CSV.open("temp/" + @name + ".csv", "a")
    end
    def out_data(point, uma, rank)
        @writer << [point, uma, rank]
    end
    def calc_rank(point_recode=[0,0,0,0,0], point) #todo: 同点の場合
        rank = 4;
        1.upto(point_recode.length-1) do |x| #0番目のセルは計算から除外
            if (point_recode[x] == NODATA) then
                next
            end
            if (point_recode[x] < point) then
                rank -= 1
            end
        end
        return rank
    end
end

def get_name(nameline)
    sp = nameline.split(/<\/th><th>/)
    sp[sp.length-1] = sp[sp.length-1].chomp("<\/th><\/tr>")
    return sp[1..(sp.length-1)] 
end

def change_integer(string)
    m = [0,0]
    j = 0
    string.each { |x|
        if (x == ("<br>")) then
           m[j] = NODATA
           j += 1
        end 
        pattern = /-?[0-9]+/
        r = (x =~ pattern)
        if (r != nil) then
           m[j] = x.to_i
           j += 1
        end
    }
#    p m
    return m
end

def get_senreki(senrekiLine)
    matrix = [[0,0,0,0,0],[0,0,0,0,0]]
    i = 0
    line = senrekiLine.split("<tr align=\"center\">")
    line.each { |s|
        tmp = s.split(/<th>|<\/th>|<td>|<\/td>|<\/tr>/)
#        p tmp
        if (tmp.empty? == true) then
            next
        end
        matrix[i] = change_integer(tmp)
        i += 1
    }
    return matrix
end

def output_data(name, matrix)
#p __LINE__
    m = 1
    name.each { |memberName|
        d = MemberData.new(memberName)
        i = 0
        while i < matrix.length-1 do
            point = matrix[i][m]
            if (point == NODATA)
                i += 1
                if (matrix[i+1][0] != NODATA)
                    i += 1
                end
                next
            end
            recode = [0,0,0,0,0] #素点が同じ場合の暫定対策 ウマも合計して計算する
            0.upto(matrix[i].length-1) { |j|
                recode[j] = matrix[i][j]
            }
            uma = 0
            if (matrix[i+1][0] == NODATA) 
                uma = matrix[i+1][m]
                1.upto(recode.length-1) { |j|
                    if (matrix[i+1][j] == NODATA)
                        next
                    end
                    recode[j] += matrix[i+1][j]
                }
                i += 1
            end
#            p recode
            rank = d.calc_rank(recode, recode[m])
            d.out_data(point, uma, rank)
            i += 1
        end
        m += 1
    }    
end

def write_data(nameLine, senrekiLine)
    name = ["", "", "", ""]
    name = get_name(nameLine)
#    p name
    senrekiMatrix = [[0,0,0,0,0],[0,0,0,0,0]]
    senrekiMatrix = get_senreki(senrekiLine)
#    p senrekiMatrix
    output_data(name, senrekiMatrix)
	return
end


def get_data(senrekiUrl, count)
    0.upto(count-1) { |i|
#    3.upto(3) { |i|
        nameLine = ""
        senrekiLine = ""
    	data = Net::HTTP.get(URI.parse(senrekiUrl[i]))
    	string = data.split("\n") #lineごとに取得
    	string.each { |readline|
    	    if (readline.include?("table class=\"wikitable\"")) then
    	        nameLine = readline
    	    end
    	    if (readline.include?("tr align=\"center\"")) then
    	        senrekiLine = readline
    	    end
    	}
    	write_data(nameLine, senrekiLine)
    }
	return
end

# ---start---

if Dir.exist?("temp") == false
    Dir.mkdir("temp")
end
File.delete(*Dir["temp/*"])

data = Net::HTTP.get(URI.parse("http://mahjong.app-li.info/games/room/277"))
string = data.split("\n") #行ごとに取得
#file = File.open("./test.html", mode = "r", perm = 0666)
#string = IO.readlines("./test.html")

senrekiUrl = ["","",""]
count = 0;

string.each { |line|
	url = line.slice(/\/games\/view\/[0-9]+/)
	if (url != nil) 
		senrekiUrl[count] = "http://mahjong.app-li.info" + url
#		print(senrekiUrl[count], "\n")
		count += 1
	end
}

get_data(senrekiUrl, count)
# ---end---
