-- create Fire Pro Wrestling 5bpp palette image

local filename = "outfile.ppm"

-- write "P3" with linebreak
-- write image size with linebreak (maximum color component value optional)
-- throw the RGB values into places

local outFile,errorMsg = io.open(filename,"w+")

if outFile == nil then
	print(errorMsg)
	return
end

local netpbmFormat = "P3"
local imageWidth = 32
local imageHeight = 193
local maxValue = 31

outFile:write(string.format("%s\n",netpbmFormat))
outFile:write(string.format("%d %d %d\n",imageWidth,imageHeight,maxValue))

-- first row: increment all values for the gray scale
for i=0,31 do
	outFile:write(string.format("%d %d %d ",i,i,i))
end
outFile:write("\n")

-- "part 1": red with green axis
for green=0,31 do
	for red=0,31 do
		outFile:write(string.format("%d %d %d ",red,green,0))
	end
	outFile:write("\n")
end
outFile:write("\n")

-- "part 2": red with blue axis
for blue=0,31 do
	for red=0,31 do
		outFile:write(string.format("%d %d %d ",red,0,blue))
	end
	outFile:write("\n")
end
outFile:write("\n")

-- "part 3": green with blue axis
for blue=0,31 do
	for green=0,31 do
		outFile:write(string.format("%d %d %d ",0,green,blue))
	end
	outFile:write("\n")
end
outFile:write("\n")

-- "part 4": red and green same, blue axis
for blue=0,31 do
	for rg=0,31 do
		outFile:write(string.format("%d %d %d ",rg,rg,blue))
	end
	outFile:write("\n")
end
outFile:write("\n")

-- "part 5": red and blue same, green axis
for green=0,31 do
	for rb=0,31 do
		outFile:write(string.format("%d %d %d ",rb,green,rb))
	end
	outFile:write("\n")
end
outFile:write("\n")

-- "part 6": green and blue same, red axis
for red=0,31 do
	for gb=0,31 do
		outFile:write(string.format("%d %d %d ",red,gb,gb))
	end
	outFile:write("\n")
end
outFile:write("\n")

outFile:flush()
outFile:close()
