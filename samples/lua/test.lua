--test

function MyRun()
if os ~= nil then
	myprint "access of 'OS' possible"
	--os.exit()
else
	myprint "access of 'OS not possible"
end


	myprint("print argument 1", " and print argument 2")

	if MyObject ~= nil then
		MyObject.Test("changing MyObject.prop from ".. MyObject.prop .. " to " .. MyObject.arr[2])
		MyObject.prop = MyObject.arr[2]
		MyObject.Test("changing MyObject.prop from ".. MyObject.prop .. " to nil (results in 0)")
		MyObject.prop = nil
		-- does not work yet
		--MyObject.Test("changing MyObject.arr[2] from ".. MyObject.arr[2] .. " to 10")
		--MyObject.arr[2] = 30

		local mylist = MyObject.GetList()
		myprint ("List count: " .. mylist.Count() .. " = 3 ?")
		MyObject.myList = nil
	else
		print "MyObject is null"
	end

	return 1
end