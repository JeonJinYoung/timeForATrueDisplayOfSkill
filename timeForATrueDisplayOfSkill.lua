if myHero.charName ~= "Ezreal" then return end

require "SOW"
require "VPrediction"
require "SourceLib"

-------------Updater-------------

local UPDATE_HOST      = "raw.github.com"
local UPDATE_PATH      = "/gnomgrol/timeForATrueDisplayOfSkill/master/timeForATrueDisplayOfSkill.lua"
local VERSION_PATH     = "/gnomgrol/timeForATrueDisplayOfSkill/master/timeForATrueDisplayOfSkill.version"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL       = "https://"..UPDATE_HOST..UPDATE_PATH
local SCRIPT_NAME      = "Time for a true display of skill"

local version = 0.2
local AUTOUPDATE = true

if AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, UPDATE_HOST, UPDATE_PATH, UPDATE_FILE_PATH, VERSION_PATH):CheckUpdate()
end



-- ORBWALKER FUNCTION
local AArange = 675 

local MyTrueRange
local HitBoxSize = 65
local lastAttack = GetTickCount()
local walkDistance = 300
local lastWindUpTime = 0
local lastAttackCD = 0
 
local lastAnimation = ""
local lastChanneling = 0


function OnProcessSpell(object, spell)
    if myHero.dead then return end
    local spellIsAA = (spell.name:lower():find("attack"))
    if object.isMe then
		if spellIsAA then
            lastAttack = GetTickCount() - GetLatency()/2
            lastWindUpTime = spell.windUpTime*1000
            lastAttackCD = spell.animationTime*1000
        end
    end
end

function heroCanMove()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end
function timeToShoot()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end
function OnAnimation(unit,animationName)
        if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end
function myHeroisChanneling()
    return (
		(GetTickCount() <= lastChanneling + GetLatency() + 50)
            or (myHero.charName == "Katarina" and lastAnimation == "Spell4")
            or (myHero.charName == "Nunu" and (lastAnimation == "Spell4" or lastAnimation == "Spell4_Loop"))
    )
end
function moveToCursor()
    if GetDistance(mousePos) > 50 or lastAnimation == "Idle1" then
        local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*walkDistance
        myHero:MoveTo(moveToPos.x, moveToPos.z)
    end
end






qRange = 1150
qSpeed = 1200
qWidth = 80
wRange = 1000
rSpeed = 2000
rDelay = 1.0

local baseX, baseZ


local DCConfig

local foundRecall = false
local startedRecall = 0
local recallingUnit = nil
local recallTime = 8500

local SOWlol
local VP
VP = VPrediction()


local procLostTick = GetTickCount()
local hasProc = false


local barrierSlot, healSlot  = nil, nil
if player:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") then barrierSlot = SUMMONER_1 end
if player:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") then barrierSlot = SUMMONER_2 end
if myHero:GetSpellData(SUMMONER_1).name:find("SummonerHeal") then healSlot = SUMMONER_1 end
if myHero:GetSpellData(SUMMONER_2).name:find("SummonerHeal") then healSlot = SUMMONER_2 end


function OnLoad()
	print("Future Script - Time for a true display of skill!")
	DCConfig = scriptConfig("Time for a true display of skill", "TFATDOS")

	DCConfig:addParam("rangeCircle", "Render AA range", SCRIPT_PARAM_ONOFF, true, 32)
	DCConfig:addParam("autoQ", "Auto Harass with Q", SCRIPT_PARAM_ONOFF, true, 32)
	DCConfig:addParam("autoW", "Auto Harass with W", SCRIPT_PARAM_ONOFF, false, 32)
	DCConfig:addParam("sheenRefresh", "Only use W to refresh sheen", SCRIPT_PARAM_ONOFF, true, 32)
	
	DCConfig:addParam("baseSnipe", "Snipe people after they recalled", SCRIPT_PARAM_ONOFF, true, 32)
	DCConfig:addParam("closebySnipe", "Finish closeby enemys with ult", SCRIPT_PARAM_ONOFF, true, 32)
	

	
	if myHero.team ~=100  then
        baseX = 47.70
        baseZ = 290.3
	else
        baseX = 13922
        baseZ = 14188
	end
	

	SOWlol = SOW(VP)
	SOWlol:LoadToMenu(DCConfig.Orbwalk)
	
	TargetSelector = TargetSelector(TARGET_LESS_CAST, qRange, DAMAGE_MAGIC)
	TargetSelector.name = "Ezreal"
	DCConfig:addTS(TargetSelector)
	
end


function OnTick()
	TargetSelector:update()
	Target = TargetSelector.target
	
	
	SheenSlot, TrinitySlot, LichBaneSlot, FrozenSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3025)
	
	
	local pPos, HitChance
	if Target and myHero:GetDistance(Target) < qRange then
		pPos,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.01, qWidth, qRange, qSpeed, myHero, true)
	end
	
	if GetDistance(myHero, pPos) > qRange then
		pPos = nil
	end
	
	
	-- AUTO Q
	if (DCConfig.autoQ or SOWlol.Menu.Mode0 or SOWlol.Menu.Mode1) then
		if pPos ~= nilthen and HitChance > 1 then
			if DCConfig.autoQ and myHero.mana/myHero.maxMana > 0.25 then
				CastSpell(_Q, pPos.x, pPos.z)
			end
			if SOWlol.Menu.Mode0 or SOWlol.Menu.Mode1 then
				CastSpell(_Q, pPos.x, pPos.z)
			end
		end
		
		-- SHEEN RESET W
		if (SheenSlot or TrinitySlot or LichBaneSlot or FrozenSlot) and (SOWlol.Menu.Mode0) and DCConfig.sheenRefresh then
			if pPos ~= nil and not hasProc and procLostTick+2000 < GetTickCount() and (myHero:CanUseSpell(_Q) == 4) and HitChance > 1 then				
				CastSpell(_W, pPos.x, pPos.z)
			end
		end
	end
	
	
	-- W WHEN INFIGHT
	if pPos ~= nil and (DCConfig.autoW or SOWlol.Menu.Mode0) and HitChance > 1 then
		if GetDistance(myHero, pPos) < wRange and not DCConfig.sheenRefresh then
			CastSpell(_W, pPos.x, pPos.z)
		end
	end
	
	--[[
	if not VIP_FLAG then
		-- ORB WALKER AUTOHITTING
		if DCConfig.autoCarryKey and not (myHero.dead or myHeroisChanneling()) then
			MyTrueRange = myHero.range + HitBoxSize
		
			if Target ~= nil and myHero:GetDistance(Target) - HitBoxSize < MyTrueRange then
				if timeToShoot() then
					myHero:Attack(Target)
				elseif heroCanMove() then
					moveToCursor()
				end	
			elseif heroCanMove() then
				moveToCursor()
			end
		end
		
		
		-- lasthitting
		if DCConfig.lasthitKey and not (myHero.dead or myHeroisChanneling()) then
			if timeToShoot() then
				Lasthitting()
			elseif heroCanMove() then
				moveToCursor()
			end	
		end
	end
	]]
	
	-- ULTI SNIPERINO (BASE)
	if DCConfig.baseSnipe then
		local vector = {x = myHero.x-baseX, y = 0, z = myHero.z-baseZ}
		vector = Vector(vector)--:normalized()
		
		local xd = myHero.x-baseX
		local yd = myHero.z-baseZ
		local d = math.sqrt(xd*xd + yd*yd)
		
		local secs = d / rSpeed + 1;
		
		if recallingUnit ~= nil then
			local rDmg = getDmg("R",recallingUnit,myHero)
			if secs < (recallTime/1000) and foundRecall then
				if GetTickCount() > startedRecall+(recallTime-(secs*1000)) and rDmg > recallingUnit.health  then
					if foundRecall then
						CastSpell(_R, baseX, baseZ)
					end
					foundRecall = false
					recallingUnit = nil
				end	
			end
		end
	end
	
	

	
	local enemysClose = 0
	-- ULTI SNIPERINO (CLOSE)
	if DCConfig.closebySnipe then
		for i = 1, heroManager.iCount, 1 do
			local hero = heroManager:GetHero(i)
			local eDist = myHero:GetDistance(hero)
			if eDist < 1500 then
				enemysClose = enemysClose + 1
			end
			
			if hero.team ~= myHero.team and ValidTarget(hero) then
				local dist = myHero:GetDistance(hero)
				local rDmg = getDmg("R",hero,myHero)
				local pPos
				
				pPos,  HitChance,  Position = VP:GetLineCastPosition(hero, rDelay, 180, 2500, rSpeed, myHero, false)

				
				if pPos ~= nil and dist < 2500 and dist > 300 and HitChance > 1 then
					if rDmg > hero.health then
					
						local alliesClose = 0
						for i = 1, heroManager.iCount, 1 do
							local allie = heroManager:GetHero(i)
							if allie.team == myHero.team then
								local aDist = allie:GetDistance(hero)
								if aDist < 1500 then
									alliesClose = alliesClose + 1
								end
							end
						end
						if alliesClose < 3 then
							CastSpell(_R, pPos.x, pPos.z)
						end
						
						
					end
				end
			end
		end
	end
	
	
	-- AUTO SUMMONER
	if myHero.health/myHero.maxHealth < 0.2 and enemysClose > 0 then
		if healSlot then
			CastSpell(healSlot) 
		end
		if barrierSlot then
			CastSpell(barrierSlot) 
		end
	end
	
end

function OnGainBuff(unit, buff)
    if unit.isMe then
        if buff.name == "sheen" or buff.name == "lichbane" or buff.name == "itemfrozenfist" then
			hasProc = true
		end
    end
	
	if buff.name == "Recall"  and unit.team ~= myHero.team then
		foundRecall = true
		startedRecall = GetTickCount()
		recallingUnit = unit
	end
	
end

function OnLoseBuff(unit, buff)
    if unit.isMe then
        if buff.name == "sheen" or buff.name == "lichbane" or buff.name == "itemfrozenfist" then
			hasProc = false
			procLostTick = GetTickCount()
		end
    end
	
	if buff.name == "Recall" and unit.team ~= myHero.team then
		foundRecall = false
		recallingUnit = nil
	end	
	
end

function OnDraw()
	if DCConfig.rangeCircle then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, AArange, 1, RGBA(200, 200, 100, 200))	
	end
end



function Lasthitting()
	local enemyMinions = minionManager(MINION_ENEMY, 1500, player, MINION_SORT_HEALTH_ASC)
	local lowestMinion
	
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil then
			lowestMinion = minion
			break;
		end
	end
	
	if lowestMinion ~= nil then
		local onhit = getDmg("AD",lowestMinion,myHero)
		if onhit >= lowestMinion.health then
			if timeToShoot() then 

				if myHero:GetDistance(lowestMinion) <= myHero.range then
					myHero:Attack(lowestMinion)
				end
				
			end
		else
			if heroCanMove() then
				moveToCursor()
			end
		end
		
	else
		if heroCanMove() then
			moveToCursor()
		end
	end
end