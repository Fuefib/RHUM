local libMsg = LibStub:GetLibrary("libMsg")

local RHUM = {}

-- Constants
RHUM.ultiSlotNum = 8
RHUM.delimeter = "_"
RHUM.separator = " ;; "
RHUM.regexp = RHUM.delimeter .. "(.+)" .. RHUM.delimeter .. RHUM.separator .. RHUM.delimeter .. "(.+)" .. RHUM.delimeter

-- Status
RHUM.isMember = false
RHUM.isLeader = false
RHUM.isUltiReady = false

RHUM.leaderName = ""
RHUM.membersStatus = {}


-- Addon ids
RHUM.slashCommand = "rhum"
RHUM.uniqueId = "RHUM_for_the_win"

-- Params
RHUM.memberParam = "member"
RHUM.leaderParam = "leader"
RHUM.debugParam = "debug"

-- Time things
RHUM.deltaTime = 3
RHUM.previousTime = GetTimeStamp()

-- Debug
RHUM.isLogDebug = false -- Set at 'true' to show debug informations

-- -------------------------
-- Slash Commands handler
-- -------------------------

-- Activate RHUM as Leader
SLASH_COMMANDS["/" .. RHUM.slashCommand .. RHUM.leaderParam] = function (param)
	RHUM.info("Activating RHUM as Leader")
	RHUM.isLeader = true
end

-- Activate RHUM as Member
SLASH_COMMANDS["/" .. RHUM.slashCommand .. RHUM.memberParam] = function (param)
	RHUM.info("Activating RHUM as Member")
	RHUM.isMember = true
	RHUM.leaderName = param
end

-- Toggle RHUM debug
SLASH_COMMANDS["/" .. RHUM.slashCommand .. RHUM.debugParam] = function (param)
	if(RHUM.isLogDebug) then
		RHUM.info("Deactivating debug")
		RHUM.isLogDebug = false
	else 
		RHUM.info("Activating debug")
		RHUM.isLogDebug = true
	end
end

-- Shutdown RHUM
SLASH_COMMANDS["/" .. RHUM.slashCommand] = function (param)
	RHUM.info("Shutting RHUM down")
	RHUM.isMember = false
	RHUM.isLeader = false
	RHUM.isUltiReady = false
	
	RHUM.leaderName = ""
	RHUM.membersStatus = {}
end

-- -------------------------
-- Update functions
-- -------------------------

-- Main update
function RHUMUpdate()
	-- Doing something only every few seconds
	local currentTime = GetTimeStamp()
	if(GetDiffBetweenTimeStamps(currentTime, RHUM.previousTime) > RHUM.deltaTime ) then
		RHUM.previousTime = currentTime
		
		-- Checking status
		if(RHUM.isMember) then
			RHUM.updateMember()
		end
		if (RHUM.isLeader) then
			RHUM.updateLeader()
		end
	end
end

-- Update as Member
RHUM.updateMember = function ()
	local ultiUp = RHUM.checkUltimate ()
	
	if(ultiUp and not RHUM.isUltiReady) then
		RHUM.debug("Ulti is now READY !")
		RHUM.buildAndSendMessage(ultiUp)
	elseif (not ultiUp and RHUM.isUltiReady) then
		RHUM.debug("Ulti is no longer ready :(")
		RHUM.buildAndSendMessage(ultiUp)
	end
	
	RHUM.isUltiReady = ultiUp
end

-- Update as Leader
RHUM.updateLeader = function ()
	RHUM.checkMessages()
	RHUM.clearOffline()
	RHUM.updateFrame()
end

-- Update frame
RHUM.updateFrame = function ()

	local membersText = ""

	for name,ulti in pairs(RHUM.membersStatus) do 
		membersText = membersText .. "[" .. name .. "]" .. " - " .. ulti .. "\n"
	end
	
	RHUMMembers:SetText(membersText)
end

-- -------------------------
-- Other Functions
-- -------------------------

-- Clear Offline : remove entries for offline members
RHUM.clearOffline = function ()
	for name,_ in pairs(RHUM.membersStatus) do 
		if(not IsUnitOnline(name)) then
			RHUM.membersStatus[name] = nil
		end
	end
end

-- Check Messages
RHUM.checkMessages = function () 
    RHUM.debug("checking messages")
    local messages = libMsg.receiveAllMsg (RHUM.uniqueId)
	local numReq = #messages
    RHUM.debug(tostring(numReq) .. " message(s) pending")
	for name,message in pairs(messages) do 
		RHUM.debug(name .. " sent " .. message)
		RHUM.handleMessage(name, message)
	end
end

-- Message handler : update the status of members
RHUM.handleMessage = function (name, message)
	local ulti, status = string.match(message, RHUM.regexp)
	
	if(ulti and status) then
		if(status == "true") then
			RHUM.debug(name .. "'s ultimate [" .. ulti .. "] is UP ! (" .. status .. ")")
			RHUM.membersStatus[name] = ulti
		else
			RHUM.debug(name .. "'s ultimate [" .. ulti .. "] no longer up (" .. status .. ")")
			RHUM.membersStatus[name] = nil
		end
	end
end

-- Check Ultimate Status
RHUM.checkUltimate = function ()
	local current = GetUnitPower("player", POWERTYPE_ULTIMATE)
	local required = GetSlotAbilityCost(RHUM.ultiSlotNum)
	
	return current >= required
end


-- Creating and sending message
RHUM.buildAndSendMessage = function (ultiUp)
	local ultiName = GetSlotName(RHUM.ultiSlotNum)

	local message = RHUM.delimeter .. ultiName .. RHUM.delimeter 
	message = message .. RHUM.separator 
	message = message .. RHUM.delimeter .. tostring(ultiUp) .. RHUM.delimeter
	
	RHUM.debug("sending message >" .. message .. "< to " .. RHUM.leaderName)
	libMsg.sendMsg(RHUM.uniqueId, RHUM.leaderName, message)	
end


-- -------------------------
-- Logging
-- -------------------------
RHUM.info = function (message)
	d("[RHUM] " .. message)
end

RHUM.debug = function (message)
	if(RHUM.isLogDebug) then
		d("[RHUM] debug -- " .. message)
	end
end



