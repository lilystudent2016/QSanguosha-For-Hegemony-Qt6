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
--移动版专属

--杜预
sgs.ai_skill_invoke.wuku = true

local miewu_skill = {}
miewu_skill.name = "miewu"
table.insert(sgs.ai_skills, miewu_skill)
miewu_skill.getTurnUseCard = function(self)
	if self.player:getMark("#wuku") == 0 or self.player:hasFlag("MiewuUsed") or self.player:isNude() then
        return
    end
    local cards = sgs.QList2Table(self.player:getCards("he"))
    self:sortByUseValue(cards, true)
    local str = "@MiewuCard=" .. cards[1]:getEffectiveId() .. ":"
    local card_name

--[[{联军盛宴,火烧连营,桃园结义,南蛮入侵,万箭齐发,
	远交近攻,无中生有,决斗,顺手牵羊,过河拆桥,水淹七军,
	铁索连环,以逸待劳,五谷丰登,勠力同心,调虎离山,敕令,
	借刀杀人,知己知彼,火攻,挟天子以令诸侯}
]]--按锦囊价值排序
	local trickcards = {"alliance_feast","burning_camps","god_salvation","savage_assault","archery_attack",--群体锦囊
	"befriend_attacking","ex_nihilo","duel","snatch","dismantlement","drowning",--单体锦囊
	"iron_chain","await_exhausted","amazing_grace","fight_together","lure_tiger","imperial_order",--几乎不会用到的群体锦囊
	"collateral","known_both","fire_attack","threaten_emperor"}--几乎不会用到的单体锦囊
    local delaycards = {"indulgence","supply_shortage","lightning"}--延时锦囊：乐不思蜀，兵粮寸断，闪电
    local basiccards = {"slash","fire_slash","thunder_slash","peach","analeptic"}--基本牌：普杀，火杀，雷杀，桃，酒

    local can_use = {}
    for _, trick in ipairs(trickcards) do
        local clonecard = sgs.cloneCard(trick)
        if self:getUseValue(clonecard) >= self:getUseValue(cards[1]) then
            local dummyuse = { isDummy = true }
            self:useCardByClassName(clonecard, dummyuse)
            if dummyuse.card then
                table.insert(can_use, trick)
            end
        end
    end
    for _, dtrick in ipairs(delaycards) do
        local clonecard = sgs.cloneCard(dtrick)
        if self:getUseValue(clonecard) >= self:getUseValue(cards[1]) then
            local dummyuse = { isDummy = true }
            self:useCardByClassName(clonecard, dummyuse)
            if dummyuse.card then
                table.insert(can_use, dtrick)
            end
        end
    end
    for _, basic in ipairs(basiccards) do
        local clonecard = sgs.cloneCard(basic)
        if self:getUseValue(clonecard) >= self:getUseValue(cards[1]) then
            local dummyuse = { isDummy = true }
            self:useCardByClassName(clonecard, dummyuse)
            if dummyuse.card then
                table.insert(can_use, basic)
            end
        end
    end

    if #can_use > 0 then
        card_name = can_use[math.random(1, #can_use)]--随机一张牌当彩蛋
        sgs.ai_use_priority.MiewuCard = math.max(5, self:getDynamicUsePriority(sgs.cloneCard(card_name)))--5是否合适
        return sgs.Card_Parse(str .. card_name)
    end
end

sgs.ai_skill_use_func.MiewuCard = function(card, use, self)
	local userstring = card:toString()
	userstring = (userstring:split(":"))[3]
	local miwucard = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	self:useCardByClassName(miwucard, use)--确保能使用
	if use.card then
		Global_room:writeToConsole("灭吴卡使用")
		use.card = card
	end
end

function sgs.ai_cardsview.miewu(self, class_name, player, cards)
	if not player:hasShownSkill("miewu") then return end
	if player:getMark("#wuku") == 0 or player:hasFlag("MiewuUsed") or player:isNude() then
        return
    end
	if class_name == "Peach" or class_name == "Analeptic"
    or class_name == "Slash" or class_name == "Jink" or class_name == "Nullification" then
        if not cards then
			cards = {}
			for _, c in sgs.qlist(player:getCards("he")) do
				if sgs.cardIsVisible(c, player, self.player) and c:isKindOf(class_name) then
                else
                    table.insert(cards, c)
                end
			end
			for _, id in sgs.qlist(player:getHandPile()) do
				local c = sgs.Sanguosha:getCard(id)
				if sgs.cardIsVisible(c, player, self.player) and c:isKindOf(class_name) then
                else
                    table.insert(cards, c)
                end
			end
		end
        if #cards < 1 then return {} end
        sgs.ais[player:objectName()]:sortByKeepValue(cards)

        local className2objectName = { Peach = "peach", Analeptic = "analeptic",
                     Slash = "slash", jink = "jink", Nullification = "heg_nullification" }--优先国无懈
		local object_name = className2objectName[class_name]
        if class_name == "Slash" then
            local slash = {"slash","fire_slash","thunder_slash"}--随机属性杀
            object_name = slash[math.random(1, #slash)]
        end
        local clonecard = sgs.cloneCard(object_name)
        local value = sgs.ais[player:objectName()]:getKeepValue(clonecard)

        local function count_value(acard)
            if player:getPhase() <= sgs.Player_Play then
                return sgs.ais[player:objectName()]:getUseValue(acard)
            else
                return sgs.ais[player:objectName()]:getKeepValue(acard)
            end
        end

        for _, c in ipairs(cards) do--未考虑留桃留无懈等
            if count_value(c) < value then
                Global_room:writeToConsole("灭吴卡打出")
                return "@MiewuCard=" .. c:getEffectiveId() .. ":" .. object_name
            end
        end
	end
end