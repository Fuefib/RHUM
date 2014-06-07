local MAJOR, MINOR = "libMsg", 1
local libMsg, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not libMsg then return end


libMsg.isLogDebug = false
libMsg.separator = "___"


libMsg.debug = function(s)
	if(libMsg.isLogDebug) then
		d("[libMsg] debug -- " .. s)
	end
end

-- from http://lua-users.org/wiki/StringTrim
function trim1(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Send message to the recipient for this code
libMsg.sendMsg = function (code, recipient, msg)
	-- Removing current message
	libMsg.clearRecipient(recipient)

	-- Sending message
	RequestFriend(recipient, code .. libMsg.separator .. msg)
end

-- Recieve all the message for this code
libMsg.receiveAllMsg = function (code)

	local msgs = {}

	local numReq = GetNumIncomingFriendRequests()

    libMsg.debug(tostring(numReq) .. " friend request(s) pending")
    
    -- Parsing all the requests
    for id=1,numReq
    do
        local name,timesent,message = GetIncomingFriendRequestInfo(id)

        -- Only take request containing the code
        if(message:find(code .. libMsg.separator)) then
        	--message = trim1(message)
        	libMsg.debug(name .. " sent " .. message)
        	msgs[name] = message
        end
    end

    -- Cleaning received messages
    libMsg.clearMsg(msgs)

    -- Returning the messages
    return msgs
end

-- Get the next message for this code
libMsg.receiveNextMsg = function (code)
	-- TODO
end

-- Clear all message for this code
libMsg.clearMsgForId = function (code)
	libMsg.clearMsg(libMsg.receiveAllMsg)
end

-- Clear all message
libMsg.clearMsg = function (msgs)
	for key,value in pairs(msgs) do 
		RejectFriendRequest(keys)
	end
end

-- Cancel active friend request for the recipient
libMsg.clearOutgoing = function (recipient)
	local numOut = GetNumOutgoingFriendRequests()
	local cancelId = -1
	
	for outId=1,numOut do
		local name = GetOutgoingFriendRequestInfo(outId)
		
		if(name == recipient) then
			cancelId = outId
		end
	end

	if(cancelId > -1) then
		CancelFriendRequest(cancelId)
	end
end

-- Remove all friend request (in or out) relative to the recipient
libMsg.clearRecipient = function (recipient)
	libMsg.clearOutgoing(recipient)
	RejectFriendRequest(recipient)
	RemoveFriend(recipient)
end