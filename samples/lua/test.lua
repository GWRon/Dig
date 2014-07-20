--test

function MyRun()
if os ~= nil then
	myprint "os access possible"
	--os.exit()
else
	myprint "os access not possible"
end


	myprint("test", "again")
--[[
	if MyObject ~= nil then
		MyObject.Test("changing MyObject.prop from ".. MyObject.prop .. " to 15")
		MyObject.prop = 15
		MyObject.prop = MyObject.arr[2]

--		print "trying to assign to an array"
--		MyObject.arr[2] = 30

		local mylist = MyObject.GetList()
		myprint (mylist.Count())
		MyObject.myList = nil
		MyObject.prop = nil
	else
	--	print "is null"
	end
]]--
	return 1
end