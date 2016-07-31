-- Packbits file encoder and decoder
-- written by freem/AJ
--[[
Resources used:
 - https://en.wikipedia.org/wiki/PackBits
 - https://github.com/psd-tools/packbits
--]]
--============================================================================--
MAX_SEQUENCE_LENGTH = 127   -- Maximum sequence length (0x7F)
EncodeStates = { Raw, RLE } -- possible states during encoding

ENCODE_STATE_RAW = 0
ENCODE_STATE_RLE = 1

--============================================================================--
-- Usage()
-- Prints program usage
local function Usage()
	print("Packbits file encoder/decoder, script by freem/AJ")
	print("usage: lua packbits.lua (mode) (infile) (outfile)")
end

--============================================================================--
-- PackBits_pack(inData)
-- Packs data using the PackBits method.
local function PackBits_pack(inData)
	local outData = {}
	local buffer = {}
	local i = 1 -- position
	local repeatCount = 0
	local curState = ENCODE_STATE_RAW

	-- helper routines
	local function FinishRaw()
		if #buffer > 0 then
			table.insert(outData,#buffer-1)
			for k,v in pairs(buffer) do
				table.insert(outData,v)
			end
			buffer = {} -- clear buffer
		end
	end

	local function FinishRLE()
		table.insert(outData,256-(repeatCount-1))
		table.insert(outData,inData[i])
	end

	-- main routine
	while i < #inData-1 do
		local curByte = inData[i]
		local nextByte = inData[i+1]
		if curByte == nextByte then
			if curState == ENCODE_STATE_RAW then
				FinishRaw()
				-- begin RLE run
				curState = ENCODE_STATE_RLE
				repeatCount = 1
			elseif curState == ENCODE_STATE_RLE then
				if repeatCount == MAX_SEQUENCE_LENGTH then
					FinishRLE()
					repeatCount = 0
				end
				repeatCount = repeatCount + 1
			end
		else
			if curState == ENCODE_STATE_RLE then
				repeatCount = repeatCount + 1
				FinishRLE()
				curState = ENCODE_STATE_RAW
				repeatCount = 0
			elseif curState == ENCODE_STATE_RAW then
				if #buffer == MAX_SEQUENCE_LENGTH then
					FinishRaw()
				end
				table.insert(buffer,curByte)
			end
		end
		i = i+1
	end

	-- finish up based on final state
	if curState == ENCODE_STATE_RAW then
		table.insert(buffer,inData[i])
		FinishRaw()
	else -- RLE
		repeatCount = repeatCount + 2
		FinishRLE()
	end

	return outData
end

--============================================================================--
-- PackBits_unpack(inData)
-- Unpacks data that has been packed with PackBits.
local function PackBits_unpack(inData)
	local outData = {}
	local i = 1

	while i < #inData do
		local value = inData[i]

		if value > 128 then -- repeat sequence
			local j = 0
			local repeatByte = inData[i+1]
			value = 256-value
			for j=0,value do
				table.insert(outData,repeatByte)
			end
			i = i+1
		elseif value < 128 then -- sequence length
			local j = 0
			local finalJ = 0
			for j=0,value do
				local newByte = inData[i+j+1]
				if newByte then
					table.insert(outData,newByte)
				end
				finalJ=j
			end
			i = i+finalJ+1
		else -- 0x80
			table.insert(outData,inData[i])
			i = i+1
		end
		i = i+1
	end

	return outData
end

--============================================================================--
args = {...}

if #args < 3 then
	Usage()
	return
end

local progMode    = string.lower(args[1])
local inFilename  = args[2]
local outFilename = args[3]

-- accept short form commands
if progMode == "-e" then progMode = "encode" end
if progMode == "-d" then progMode = "decode" end

-- look for proper program mode
if progMode ~= "encode" and progMode ~= "decode" then
	print(string.format("Unknown program mode '%s'!",progMode))
	return
end

local inFile,errorMsg = io.open(inFilename,"rb")
if not inFile then
	print("Error attempting to open input file "..errorMsg)
	return
end

local inText = inFile:read("*a")
inFile:close() -- don't need this anymore.

-- convert input string into bytes for PackBits algos
local inBuffer = {}
for i=1,#inText do
	local char = string.byte(string.sub(inText,i,i))
	table.insert(inBuffer,char)
end

-- prepare output file
local outFile,errorMsg = io.open(outFilename,"wb")
if not outFile then
	print("Error attempting to open output file "..errorMsg)
	return
end

-- based on what program mode we're in, we want to perform the right task.

local outData = nil
if progMode == "encode" then
	outData = PackBits_pack(inBuffer)
elseif progMode == "decode" then
	outData = PackBits_unpack(inBuffer)
end

-- yes this could probably be done faster but ehhhhhhhh, I'm not aware of how.
for k,v in pairs(outData) do
	outFile:write(string.char(v))
end

outFile:close()
