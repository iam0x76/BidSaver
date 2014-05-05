

local bit = require"bit"
LOG_NAME = "bid_log.csv" -- csv log file name 
stopped = false 		 -- stop flag 
local g_Path			 -- script file path 
local hFile				 -- csv log file handle



-- Check bit by index 

function bit_set( flags, index )
        local n=1
        n=bit.lshift(1, index)
        if bit.band(flags, n) ~=0 then
                return true
        else
                return false
        end
end


-- Check if file already exists 
function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false
	end
end


-- Stop callback 

function OnStop(signal)
	stopped = true
end


-- Init callback

function OnInit(path)
	g_Path = path
	if file_exists( LOG_NAME ) then
		hFile = io.open( LOG_NAME , "a")
	else	
		hFile = io.open( LOG_NAME , "w")
		hFile:write("date, order num , name,operation,price, count , status\n")
	end
	
end



-- Get operation type by bit array ( SELL / BUY )

function GetOperationType( flags )
	if bit_set(flags, 2) then
		return "SELL"	
	else
		return "BUY"
	end
end


-- Get current operation status ( DONE / ACTIVE / REMOVED )
function GetOrderStatus( flags )
	
	if  not bit_set(flags, 0) and not  bit_set(flags, 1) then	
		return "DONE"
	end
	
	if bit_set(flags, 1) then	
		return "REMOVED"
	end
		
	if bit_set(flags, 0) then
		return "ACTIVE"
	end
end

-- Order change callblack 
function OnOrder( order )

	BidTime = ""..order.datetime.year..":"..order.datetime.month..":"..order.datetime.day..":"..order.datetime.hour..":"..order.datetime.min..":"..order.datetime.sec
    OrderNum = order.ordernum
	FirmName = order.sec_code
	OperationType = GetOperationType( order.flags  )
	Price = order.price
	Count = order.qty
	Status = GetOrderStatus( order.flags )
	line = ""..BidTime..","..OrderNum..","..FirmName..","..OperationType..","..Price..","..Count..","..Status.."\n"
	hFile:write(line)
	hFile:flush()

end

function main()
	message("BidSaver  plugin started" , 1 )
	
 	while not stopped do
		sleep(100)
	end
	hFile:close( )
	message("BidSaver  plugin  stopped" , 1)
end
