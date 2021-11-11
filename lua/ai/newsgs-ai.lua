--[[********************************************************************
	Copyright (c) 2013-2015 Mogara

  This file is part of QSanguosha-Hegemony.

  This game is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation; either version 3.0
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  See the LICENSE file for more details.

  Mogara
*********************************************************************]]
--新杀专属

--蒋干
sgs.ai_skill_invoke.weicheng = true

local daoshu_skill= {}
daoshu_skill.name = "daoshu"
table.insert(sgs.ai_skills, daoshu_skill)
daoshu_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasUsed("DaoshuCard") then return end
	if #self.enemies == 0 then return end
	return sgs.Card_Parse("@DaoshuCard=.&daoshu")
end

sgs.ai_skill_use_func.DaoshuCard = function(card, use, self)
	sgs.ai_use_priority.DaoshuCard = 2.9--合纵连横之后
	local rand = math.random(1, 7)
	if rand == 3 then
		self.daoshu_suit = 0
	elseif rand == 4 then
		self.daoshu_suit = 1
	elseif rand < 3 then
		self.daoshu_suit = 2
	else
		self.daoshu_suit = 3
	end
--保留牌中闪大概率是方块，桃大概率红心
--[[
	Card::Spade,
    Card::Club,
    Card::Heart,
    Card::Diamond
--	黑桃（sgs.Card_Spade）：0
--	草花（sgs.Card_Club）：1
--	红心（sgs.Card_Heart）：2
--	方块（sgs.Card_Diamond）：3
]]--教程有误看源码
	local known_suit = {0,0,0,0}
	self:sort(self.enemies, "handcard")
	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and not self:doNotDiscard(enemy, "h") and self:damageIsEffective(enemy, nil, self.player) then
			known_suit[1] = getKnownCard(enemy, self.player, "spade", true, "h")
			known_suit[2] = getKnownCard(enemy, self.player, "club", true, "h")
			known_suit[3] = getKnownCard(enemy, self.player, "heart", true, "h")
			known_suit[4] = getKnownCard(enemy, self.player, "diamond", true, "h")
			for _, suit in ipairs(known_suit) do
				if suit == enemy:getHandcardNum() then--如果已知花色等于手牌数
					sgs.ai_use_priority.DaoshuCard = 5.3
					self.daoshu_suit = table.indexOf(known_suit,suit) - 1
					--global_room:writeToConsole("已知花色:"..self.daoshu_suit)
					use.card = card
					if use.to then
						use.to:append(enemy)
					end
					return
				end
			end
		end
	end
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and not self:doNotDiscard(enemy, "h") and self:damageIsEffective(enemy, nil, self.player) then
			known_suit[1] = getKnownCard(enemy, self.player, "spade", true, "h")
			known_suit[2] = getKnownCard(enemy, self.player, "club", true, "h")
			known_suit[3] = getKnownCard(enemy, self.player, "heart", true, "h")
			known_suit[4] = getKnownCard(enemy, self.player, "diamond", true, "h")
			--sgs.debugFunc(self.player, 1)
			local max_suit = math.max(known_suit[1], known_suit[2], known_suit[3], known_suit[4])
			if 3*max_suit >= enemy:getHandcardNum() then--已知花色大于等于1/3
				self.daoshu_suit = table.indexOf(known_suit,max_suit) - 1
			end
			if enemy:hasSkill("hongyan") then--针对小乔
				self.daoshu_suit = 2
			end
			--global_room:writeToConsole("最多的花色数量:"..max_suit)
			use.card = card
			if use.to then
				use.to:append(enemy)
			end
			return
		end
	end
end

sgs.ai_skill_suit.daoshu= function(self)--有空可以增加配合合纵连横，估计需要改合纵连横的ai
	--global_room:writeToConsole("选择花色:"..self.daoshu_suit)
	return self.daoshu_suit
end

sgs.ai_skill_cardask["@daoshu-give"] = function(self, data, pattern, target, target2)
	--global_room:writeToConsole("盗书返还函数")
	if not target2 or target2:isDead() then return "." end
	local cards = {}
	--global_room:writeToConsole("pattern参数:"..pattern)
	local patternt = pattern:split("|")
	--global_room:writeToConsole("pattern花色:"..patternt[2])
	local suit = (patternt[2]):split(",")
	--global_room:writeToConsole("盗书返还函数花色:"..table.concat(suit,","))
	for _,c in sgs.qlist(self.player:getCards("h")) do
		if table.contains(suit, c:getSuitString()) then
			table.insert(cards, c)
		end
	end
	if #cards == 0 then return "." end
	self:sortByUseValue(cards, true)

	local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), target2:objectName())
	if not cards[1]:hasFlag("visible") then cards[1]:setFlags(flag) end--记录方便后续盗书

	return "$" .. cards[1]:getEffectiveId()
end

--周夷
sgs.ai_skill_invoke.zhukou = true

sgs.ai_skill_invoke.duannian = function(self, data)
	local has_peach = false
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if isCard("Peach", card, self.player) then
			has_peach = true
		end
	end
	if not has_peach then
		if self.player:getHandcardNum() <= self.player:getMaxHp() then
			return true
		end
		if self.player:getHandcardNum() > self.player:getMaxHp() and self:getOverflow() > 0 and self:getCardsNum("Jink") == 0 then
			return true
		end
	end
	return false
end

sgs.ai_skill_playerchosen.lianyou = function(self, targets)
	local targetlist = sgs.QList2Table(targets)
	self:sort(targetlist, "hp", true)
	for _, target in ipairs(targetlist) do
		if self:isFriendWith(target) then return target end
	end
	for _, target in ipairs(targetlist) do
		if self:isFriend(target) then return target end
	end
	return {}
end

--南华老仙