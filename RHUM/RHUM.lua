local libMsg = LibStub:GetLibrary("libMsg")

local RHUM = {}

-- Status
RHUM.isMember = false
RHUM.isLeader = false
RHUM.isUltiReady = false

RHUM.leaderName = ""

RHUM.isLogDebug = true -- Set at 'true' to show debug informations

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

-- -------------------------
-- Slash Commands handler
-- -------------------------

-- Activate RHUM as Leader
SLASH_COMMANDS["/" .. RHUM.slashCommand .. RHUM.leaderParam] = function (param)
	RHUM.debug("Activating RHUM as Leader")
	RHUM.isLeader = true
end

-- Activate RHUM as Member
SLASH_COMMANDS["/" .. RHUM.slashCommand .. RHUM.memberParam] = function (param)
	RHUM.debug("Activating RHUM as Member")
	RHUM.isMember = true
	RHUM.leaderName = param
end

-- Shutdown RHUM
SLASH_COMMANDS["/" .. RHUM.slashCommand] = function (param)
	RHUM.debug("Shutting RHUM down")
	RHUM.isMember = false
	RHUM.isLeader = false
	RHUM.isUltiReady = false
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
		RHUM.debug("sending message to " .. RHUM.leaderName)
		--libMsg.sendMsg(RHUM.uniqueId, RHUM.leaderName, RHUM.uniqueId)
	elseif (not ultiUp and RHUM.isUltiReady) then
		RHUM.debug("Ulti is no longer ready :(")
		RHUM.debug("sending message to " .. RHUM.leaderName)
		--libMsg.sendMsg(RHUM.uniqueId, RHUM.leaderName, RHUM.uniqueId)
	end
	
	RHUM.isUltiReady = ultiUp
end

-- Update as Leader
RHUM.updateLeader = function ()
	RHUM.checkMessages()
end

-- -------------------------
-- Other Functions
-- -------------------------

-- Check Messages
RHUM.checkMessages = function () 
    RHUM.debug("checking messages")
    local messages = libMsg.receiveAllMsg (RHUM.uniqueId)
	local numReq = #messages
    RHUM.debug(tostring(numReq) .. " message(s) pending")
	for key,value in pairs(messages) do 
		RHUM.debug(key .. " sent " .. value)
	end
end

-- Check Ultimate Status
RHUM.checkUltimate = function ()
	local current = GetUnitPower("player", POWERTYPE_ULTIMATE)
	local required = GetSlotAbilityCost(8)
	
	return current >= required
end

-- -------------------------
-- Debug writting
-- -------------------------
RHUM.debug = function (message)
	if(RHUM.isLogDebug) then
		d("[RHUM] debug -- " .. message)
	end
end



