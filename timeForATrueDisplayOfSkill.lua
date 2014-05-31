if myHero.charName ~= "Ezreal" then return end

if VIP_USER then
	require "SOW"
	require "VPrediction"
end

-- Collision 1.1.1 by Klokje

uniqueId = 0
 
class 'Collision' -- {
    HERO_ALL = 1
    HERO_ENEMY = 2
    HERO_ALLY = 3
 
 
    function Collision:__init(sRange, projSpeed, sDelay, sWidth)
        uniqueId = uniqueId + 1
        self.uniqueId = uniqueId
 
        self.sRange = sRange
        self.projSpeed = projSpeed
        self.sDelay = sDelay
        self.sWidth = sWidth/2
 
        self.enemyMinions = minionManager(MINION_ENEMY, 2000, myHero, MINION_SORT_HEALTH_ASC)
        self.minionupdate = 0
    end
 
    function Collision:GetMinionCollision(pStart, pEnd)
        self.enemyMinions:update()
 
        local distance =  GetDistance(pStart, pEnd)
		local prediction
		
		if VIP_USER then
			prediction = TargetPredictionVIP(self.sRange, self.projSpeed, self.sDelay, self.sWidth)
		else
			prediction = TargetPrediction(self.sRange, self.projSpeed, self.sDelay, self.sWidth)
		end
        local mCollision = {}
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
       
        local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
         for index, minion in pairs(self.enemyMinions.objects) do
            if minion ~= nil and minion.valid and not minion.dead then
                if GetDistance(pStart, minion) < distance then
                    local pos, t, vec = prediction:GetPrediction(minion)
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toScreen, toPoint
                    if pos ~= nil then
                        toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    else
                        toScreen = WorldToScreen(D3DXVECTOR3(minion.x, minion.y, minion.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    end
 
 
                    if poly:contains(toPoint) then
                        table.insert(mCollision, minion)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        else
                            distance1 = Point(minion.x, minion.z):distance(lineSegmentLeft)
                            distance2 = Point(minion.x, minion.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getHitBoxRadius(minion)*2+10) or distance2 < (getHitBoxRadius(minion) *2+10)) then
                            table.insert(mCollision, minion)
                        end
                    end
                end
            end
        end
        if #mCollision > 0 then return true, mCollision else return false, mCollision end
    end
 
    function Collision:GetHeroCollision(pStart, pEnd, mode)
        if mode == nil then mode = HERO_ENEMY end
        local heros = {}
 
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if (mode == HERO_ENEMY or mode == HERO_ALL) and hero.team ~= myHero.team then
                table.insert(heros, hero)
            elseif (mode == HERO_ALLY or mode == HERO_ALL) and hero.team == myHero.team and not hero.isMe then
                table.insert(heros, hero)
            end
        end
 
        local distance =  GetDistance(pStart, pEnd)
        local prediction
		if VIP_USER then
			prediction = TargetPredictionVIP(self.sRange, self.projSpeed, self.sDelay, self.sWidth)
		else
			prediction = TargetPrediction(self.sRange, self.projSpeed, self.sDelay, self.sWidth)
		end
        local hCollision = {}
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
       
        local poly = Polygon(Point(startLeft.x, startLeft.y),  Point(endLeft.x, endLeft.y), Point(startRight.x, startRight.y),   Point(endRight.x, endRight.y))
 
        for index, hero in pairs(heros) do
            if hero ~= nil and hero.valid and not hero.dead then
                if GetDistance(pStart, hero) < distance then
                    local pos, t, vec = prediction:GetPrediction(hero)
                    local lineSegmentLeft = LineSegment(Point(startLeftX,startLeftZ), Point(endLeftX, endLeftZ))
                    local lineSegmentRight = LineSegment(Point(startRightX,startRightZ), Point(endRightX, endRightZ))
                    local toScreen, toPoint
                    if pos ~= nil then
                        toScreen = WorldToScreen(D3DXVECTOR3(pos.x, hero.y, pos.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    else
                        toScreen = WorldToScreen(D3DXVECTOR3(hero.x, hero.y, hero.z))
                        toPoint = Point(toScreen.x, toScreen.y)
                    end
 
 
                    if poly:contains(toPoint) then
                        table.insert(hCollision, hero)
                    else
                        if pos ~= nil then
                            distance1 = Point(pos.x, pos.z):distance(lineSegmentLeft)
                            distance2 = Point(pos.x, pos.z):distance(lineSegmentRight)
                        else
                            distance1 = Point(hero.x, hero.z):distance(lineSegmentLeft)
                            distance2 = Point(hero.x, hero.z):distance(lineSegmentRight)
                        end
                        if (distance1 < (getHitBoxRadius(hero)*2+10) or distance2 < (getHitBoxRadius(hero) *2+10)) then
                            table.insert(hCollision, hero)
                        end
                    end
                end
            end
        end
        if #hCollision > 0 then return true, hCollision else return false, hCollision end
    end
 
    function Collision:GetCollision(pStart, pEnd)
        local b , minions = self:GetMinionCollision(pStart, pEnd)
        local t , heros = self:GetHeroCollision(pStart, pEnd, HERO_ENEMY)
 
        if not b then return t, heros end
        if not t then return b, minions end
 
        local all = {}
 
        for index, hero in pairs(heros) do
            table.insert(all, hero)
        end
 
        for index, minion in pairs(minions) do
            table.insert(all, minion)
        end
 
        return true, all
    end
 
    function Collision:DrawCollision(pStart, pEnd)
       
        local distance =  GetDistance(pStart, pEnd)
 
        if distance > self.sRange then
            distance = self.sRange
        end
 
        local color = 4294967295
 
        local V = Vector(pEnd) - Vector(pStart)
        local k = V:normalized()
        local P = V:perpendicular2():normalized()
 
        local t,i,u = k:unpack()
        local x,y,z = P:unpack()
 
        local startLeftX = pStart.x + (x *self.sWidth)
        local startLeftY = pStart.y + (y *self.sWidth)
        local startLeftZ = pStart.z + (z *self.sWidth)
        local endLeftX = pStart.x + (x * self.sWidth) + (t * distance)
        local endLeftY = pStart.y + (y * self.sWidth) + (i * distance)
        local endLeftZ = pStart.z + (z * self.sWidth) + (u * distance)
       
        local startRightX = pStart.x - (x * self.sWidth)
        local startRightY = pStart.y - (y * self.sWidth)
        local startRightZ = pStart.z - (z * self.sWidth)
        local endRightX = pStart.x - (x * self.sWidth) + (t * distance)
        local endRightY = pStart.y - (y * self.sWidth) + (i * distance)
        local endRightZ = pStart.z - (z * self.sWidth)+ (u * distance)
 
        local startLeft = WorldToScreen(D3DXVECTOR3(startLeftX, startLeftY, startLeftZ))
        local endLeft = WorldToScreen(D3DXVECTOR3(endLeftX, endLeftY, endLeftZ))
        local startRight = WorldToScreen(D3DXVECTOR3(startRightX, startRightY, startRightZ))
        local endRight = WorldToScreen(D3DXVECTOR3(endRightX, endRightY, endRightZ))
 
        local colliton, objects = self:GetCollision(pStart, pEnd)
       
        if colliton then
            color = 4294901760
        end
 
        for i, object in pairs(objects) do
            --DrawCircle(object.x,object.y,object.z,getHitBoxRadius(object)*2+20,4294901760)
        end
 
        DrawLine(startLeft.x, startLeft.y, endLeft.x, endLeft.y, 1, color)
        DrawLine(startRight.x, startRight.y, endRight.x, endRight.y, 1, color)
 
    end
 
    function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)/2
    end

-- }


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
local ts = TargetSelector(TARGET_LOW_HP, qRange )
local CM = Collision(qRange, qSpeed, 0.01, qWidth)
local tp = TargetPrediction(qRange, qSpeed, 0.01, qWidth)
local up = TargetPrediction(2500, rSpeed, rDelay, 180)

local DCConfig

local foundRecall = false
local startedRecall = 0
local recallingUnit = nil
local recallTime = 8500

local SOWlol
local VP

if VIP_USER then
	VP = VPrediction()
end

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
	if not VIP_USER then
		DCConfig:addParam("autoCarryKey", "Infight Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
		DCConfig:addParam("lasthitKey", "Lasthit Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	end
	DCConfig:addParam("rangeCircle", "Render AA range", SCRIPT_PARAM_ONOFF, true, 32)
	DCConfig:addParam("renderQPred", "Render Q prediction", SCRIPT_PARAM_ONOFF, true, 32)
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
	
	if VIP_USER then
		SOWlol = SOW(VP)
		SOWlol:LoadToMenu(DCConfig.Orbwalk)
	end
end


function OnTick()
	ts.range = qRange
	ts:update()

	
	SheenSlot, TrinitySlot, LichBaneSlot, FrozenSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3025)
	
	local pPos
	if ValidTarget(ts.target) then
		if VIP_USER then
			pPos = VP:GetPredictedPos(ts.target, 0.01, qSpeed, myHero)
		else
			pPos = tp:GetPrediction(ts.target)
		end
	end
	
	if GetDistance(myHero, pPos) > qRange then
		pPos = nil
	end
	
	
	-- AUTO Q
	if ((DCConfig.autoCarryKey or DCConfig.autoQ) or SOWlol.Menu.Mode0 or SOWlol.Menu.Mode1) then
		if pPos ~= nil and not CM:GetMinionCollision(myHero.pos, pPos) then
			if DCConfig.autoQ and myHero.mana/myHero.maxMana > 0.25 then
				CastSpell(_Q, pPos.x, pPos.z)
			end
			if DCConfig.autoCarryKey or SOWlol.Menu.Mode0 or SOWlol.Menu.Mode1 then
				CastSpell(_Q, pPos.x, pPos.z)
			end
		end
		
		if (SheenSlot or TrinitySlot or LichBaneSlot or FrozenSlot) and (DCConfig.autoCarryKey or SOWlol.Menu.Mode0) and DCConfig.sheenRefresh then
			if pPos ~= nil and not hasProc and procLostTick+2000 < GetTickCount() and (myHero:CanUseSpell(_Q) == 4) then				
				CastSpell(_W, pPos.x, pPos.z)
			end
		end
	end
	
	
	-- W WHEN INFIGHT
	if pPos ~= nil and (DCConfig.autoW or DCConfig.autoCarryKey or SOWlol.Menu.Mode0) then
		if GetDistance(myHero, pPos) < wRange and not DCConfig.sheenRefresh then
			CastSpell(_W, pPos.x, pPos.z)
		end
	end
	
	
	if not VIP_USER then
		-- ORB WALKER AUTOHITTING
		if DCConfig.autoCarryKey and not (myHero.dead or myHeroisChanneling()) then
			MyTrueRange = myHero.range + HitBoxSize
			ts.range = MyTrueRange
			ts:update()
		
			if ts.target ~= nil and GetDistance(ts.target) - HitBoxSize < MyTrueRange then
				if timeToShoot() then
					myHero:Attack(ts.target)
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
				
				if VIP_USER then
					pPos = VP:GetPredictedPos(hero, rDelay, rSpeed, myHero)
				else
					pPos = up:GetPrediction(hero)
				end
				
				if pPos ~= nil and dist < 2500 then
					local hit, minions = CM:GetMinionCollision(myHero.pos, pPos)
					local count = #minions
					if count > 7 then count = 7 end
					for i=0, count, 1 do
						rDmg = rDmg - (rDmg*0.1)
					end
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
	ts:update()
	if ValidTarget(ts.target) and DCConfig.renderQPred then
		local pPos = tp:GetPrediction(ts.target)
		if pPos ~= nil then
			CM:DrawCollision(myHero.pos, pPos)
		end
	end
	if DCConfig.rangeCircle then
		DrawCircle(myHero.x, myHero.y, myHero.z, AArange, RGBA(200, 200, 100, 200))	
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





