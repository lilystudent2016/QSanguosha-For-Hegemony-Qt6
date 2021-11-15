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
--纵横捭阖

--华歆
sgs.ai_skill_invoke.wanggui = true

sgs.ai_skill_playerchosen.wanggui = sgs.ai_skill_playerchosen.damage

sgs.ai_skill_invoke.xibing =  function(self, data)
  if not self:willShowForDefence() then
    return false
  end
  local target = data:toPlayer()
  if not target then
    return false
  end
  local draw_count = target:getHp() - target:getHandcardNum()
  if self:isFriend(target) and (draw_count > 1) then
    return true
  end
  if self:isEnemy(target) and ((draw_count > 0 and draw_count < 2 + (self:slashIsAvailable(target) and 1 or 0))
    or target:hasShownSkills(sgs.priority_skill) and target:hasShownAllGenerals() and self.player:hasShownAllGenerals()) then
    return true
  end
  if draw_count <= 0 then
    return true
  end
	return false
end

sgs.ai_skill_choice.xibing = function(self, choices, data)
  choices = choices:split("+")
  local current = self.room:getCurrent()
  if self:isFriend(current) and table.contains(choices,"cancel") then
    return "cancel"
  end
  if self:isEnemy(current) and current:hasShownSkills(sgs.priority_skill) then
    if table.contains(choices,"cancel") then
      if #choices == 1 then
        return "cancel"
      end
      if current:canSlash(self.player, nil, true) and self.player:hasSkills(sgs.masochism_skill) and table.contains(choices,"head") then
        local skills = (sgs.masochism_skill):split("|")
        table.removeOne(skills,"wanggui")
        table.insert(skills,"qingguo")
        for _, skill in ipairs(skills) do
          if self.player:inHeadSkills(skill) then
            return "head"
          end
        end
        return "deputy"
      end
      if self.player:inDeputySkills("xibing") and table.contains(choices,"head") then
        return "head"
      else
        return "deputy"
      end
    else
      if table.contains(choices,"head") then
        local skills = (sgs.priority_skill):split("|")--需要判定君主技能等，更详细的技能判断
        table.removeOne(skills,"jianan")
        table.removeOne(skills,"shouyue")
        table.removeOne(skills,"jiahe")
        table.removeOne(skills,"hongfa")
        table.removeOne(skills,"buqu")
        for _, skill in ipairs(skills) do
          if current:inHeadSkills(skill) then
            return "head"
          end
        end
        return "deputy"
      end
      return "deputy"
    end
  end
	return choices[#choices]
end

--陆郁生
sgs.ai_skill_invoke.zhente = function(self, data)
  if not self:willShowForDefence() then
    return false
  end
  local target = data:toPlayer()
  local use = self.player:getTag("ZhenteUsedata"):toCardUse()
  local card = use.card
  if target and self:isFriend(target) then
    if (card:isKindOf("IronChain") or card:isKindOf("FightTogether") or card:isKindOf("FireAttack") or card:isKindOf("NatureSlash"))
      and not self.player:isChained() then
        return true
    elseif card:isKindOf("Slash") or card:isKindOf("Duel") or card:isKindOf("Drowning")
      or card:isKindOf("BurningCamps") or card:isKindOf("SavageAssault") or card:isKindOf("ArcheryAttack") then
        return true
    else
      return false
    end
  end
  return true
end

sgs.ai_skill_choice.zhente = function(self, choices, data)
  local use = data:toCardUse()
  local luyusheng = sgs.findPlayerByShownSkillName("zhente")
  if luyusheng and use.to:contains(luyusheng) and self:isEnemy(luyusheng) then
    if getKnownCard(self.player, self.player, "black", true, "h") == 0 then
      return "cardlimited"
    end
    local black_count = 0
    for _ ,c in sgs.qlist(self.player:getHandcards()) do
      if c:isAvailable(self.player) and c:isBlack() then
        black_count = black_count + 1
      end
    end
    if black_count > 1 and self:getOverflow() > 0 then
      return "nullified"
    else
      return "cardlimited"
    end
  end
  --[[
  if luyusheng and use.to:contains(luyusheng) and self:isFriend(luyusheng) then
    return "nullified"
  end]]
	return "nullified"
end

sgs.ai_skill_playerchosen.zhiwei = function(self, targets)
  local current = self.room:getCurrent()
  if current:objectName() ~= self.player:objectName() and current:hasShownSkills("luanji|yigui") and current:getHandcardNum() > 2 then
    return current
  end
  targets = sgs.QList2Table(targets)
  self:sort(targets, "hp", true)
  for _, p in ipairs(targets) do
    if self.player:isFriendWith(p) and p:hasShownSkills(sgs.priority_skill) then
      return p
    end
  end
  for _, p in ipairs(targets) do
    if self:isFriend(p) and p:hasShownSkills(sgs.priority_skill) then
      return p
    end
  end
  for _, p in ipairs(targets) do
    if self:isFriend(p) then
      return p
    end
  end
  return targets[1]
end

--宗预
sgs.ai_skill_invoke.qiao =  function(self, data)
  if not self:willShowForDefence() then
    return false
  end
  local target = data:toPlayer()
  if not target or self:isFriend(target) or target:isNude() then
    return false
  end
  local use = self.player:getTag("QiaoUsedata"):toCardUse()
  local card = use.card
  if self.player:getHandcardNum() ==1 then
    if (card:isKindOf("Slash") and (self:hasHeavySlashDamage(use.from, card, self.player) or self:isWeak())
      or card:isKindOf("ArcheryAttack")) and self:getCardsNum("Jink","h") == 1 then
      return false
    end
    if (card:isKindOf("SavageAssault") or card:isKindOf("Duel")) and self:isWeak() and self:getCardsNum("Slash","h") == 1 then
      return false
    end
  end
  if (self.player:getHandcardNum() <= 2 and (self:needKongcheng() or self:getLeastHandcardNum() > 0) and self:getCardsNum("Peach","h") == 0)
  or self.player:isNude() or self:getOverflow() > 0 or self:getDangerousCard(target) then
    return true
  end
	return false
end

sgs.ai_skill_invoke.chengshang = true

--祢衡
sgs.ai_skill_invoke.kuangcai = false

sgs.ai_skill_invoke.shejian =  function(self, data)
  if not self:willShowForDefence() then
    return false
  end
  local target = data:toPlayer()
  if not target or self:isFriend(target) then
    return false
  end
  local use = self.player:getTag("ShejianUsedata"):toCardUse()
  local card = use.card
  if card:isKindOf("Slash") and self:hasHeavySlashDamage(use.from, card, self.player) and self:getCardsNum("Jink","h") > 0 then
    return false
  end
  if (self.player:getHandcardNum() < 3 and self:getCardsNum("Peach","h") == 0)
  and target:getHp() <= (self.player:hasSkill("congjian") and 2 or 1) and self:isWeak(target) then
    return true
  end
	return false
end

--冯熙
sgs.ai_skill_invoke.yusui =  function(self, data)
  if not self:willShowForDefence() then
    return false
  end
  self.yusui_target = data:toPlayer()
  if not self.yusui_target or not self:isEnemy(self.yusui_target)--暂不考虑自杀，参考SmartAI:SuicidebyKurou()
  or (self.player:getHp() == 1 and self:getCardsNum("Peach") + self:getCardsNum("Analeptic") == 0) then
    return false
  end
  if (self.yusui_target:getHp() - math.max(self.player:getHp()-1, 1) > 1)
  or (self.yusui_target:getHandcardNum() >= self.yusui_target:getMaxHp() and self.yusui_target:getHandcardNum() <= self.yusui_target:getMaxHp() + 2) then
    return true
  end
	return false
end

sgs.ai_skill_choice.yusui = function(self, choices, data)--没有来源的data，暂时用self
  choices = choices:split("+")
  if (self.yusui_target:getHp() - self.player:getHp() > 1) then
    self.yusui_target = nil
    return "losehp"
  end
  if (self.yusui_target:getHandcardNum() >= self.yusui_target:getMaxHp()) then
    self.yusui_target = nil
    return "discard"
  end
  if (self.yusui_target:getHp() - self.player:getHp() == 1) then--自己会掉1血
    self.yusui_target = nil
    return "losehp"
  end
  return choices[math.random(1,#choices)]
end

local boyan_skill = {}
boyan_skill.name = "boyan"
table.insert(sgs.ai_skills, boyan_skill)
boyan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("BoyanCard") then return end
	return sgs.Card_Parse("@BoyanCard=.&boyan")
end

sgs.ai_skill_use_func.BoyanCard = function(card, use, self)
  local target
  self:sort(self.friends_noself, "handcard")
  for _, f in ipairs(self.friends_noself) do
    if (f:getMaxHp() - f:getHandcardNum()) >= (3 - (self:isWeak(f) and 1 or 0)) then
      target = f--给队友补牌优先度调低？
      break
    end
  end
  if not target then
    self:sort(self.enemies, "hp")
    for _, p in ipairs(self.enemies) do
      if p:getMaxHp() - p:getHandcardNum() < 2 and self:isWeak(p) and self.player:canSlash(p, nil, true) then
        target = p
        break
      end
    end
  end
  if not target then
    self:sort(self.enemies, "handcard", true)
    if #self.enemies > 0 and (self.enemies[1]:getMaxHp() - self.enemies[1]:getHandcardNum() < 2) then
      target = self.enemies[1]
    end
  end
  if target then
    global_room:writeToConsole("驳言目标:"..sgs.Sanguosha:translate(target:getGeneralName()).."/"..sgs.Sanguosha:translate(target:getGeneral2Name()))
	  use.card = card
    if use.to then
      use.to:append(target)
    end
  end
end

sgs.ai_use_priority.BoyanCard = 5--优先度多少合适？

sgs.ai_skill_choice.boyan = function(self, choices, data)
  local target = data:toPlayer()
  if self:isFriend(target) then
    return "yes"
  end
  return "no"
end

local boyanzongheng_skill = {}
boyanzongheng_skill.name = "boyanzongheng"
table.insert(sgs.ai_skills, boyanzongheng_skill)
boyanzongheng_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("BoyanZonghengCard") then return end
	return sgs.Card_Parse("@BoyanZonghengCard=.&boyanzongheng")
end

sgs.ai_skill_use_func.BoyanZonghengCard = function(card, use, self)
  local target
  self:sort(self.enemies, "hp")
  for _, p in ipairs(self.enemies) do
    if self:isWeak(p) and self.player:canSlash(p, nil, true) and not p:isKongcheng() then
      target = p
      break
    end
  end
  if not target and #self.enemies > 0 then
    self:sort(self.enemies, "handcard" , true)
    target = self.enemies[1]
  end
  if target then
    global_room:writeToConsole("驳言纵横目标:"..sgs.Sanguosha:translate(target:getGeneralName()).."/"..sgs.Sanguosha:translate(target:getGeneral2Name()))
	  use.card = card
    if use.to then
      use.to:append(target)
    end
  end
end

sgs.ai_use_priority.BoyanZonghengCard = 5

--邓芝
sgs.ai_skill_invoke.jianliang = true

local weimeng_skill = {}
weimeng_skill.name = "weimeng"
table.insert(sgs.ai_skills, weimeng_skill)
weimeng_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("WeimengCard") then return end
	return sgs.Card_Parse("@WeimengCard=.&weimeng")
end

sgs.ai_skill_use_func.WeimengCard = function(card, use, self)
  local target
  local _, friend = self:getCardNeedPlayer(sgs.QList2Table(self.player:getCards("h")))
  if friend and friend:getHandcardNum() > 1 then
    target = friend
  end
  if not target then
    self:sort(self.friends_noself, "handcard", true)
    for _, f in ipairs(self.friends_noself) do
      if f:getHandcardNum() > 2 or (self:isWeak(f) and not f:isKongcheng()) then
        target = f
        break
      end
    end
  end
  if not target then
    self:sort(self.enemies, "handcard", true)
    for _, p in ipairs(self.enemies) do
      if not p:isKongcheng() then
        target = p
        break
      end
    end
  end
  if target then
    global_room:writeToConsole("危盟目标:"..sgs.Sanguosha:translate(target:getGeneralName()).."/"..sgs.Sanguosha:translate(target:getGeneral2Name()))
	  use.card = card
    if use.to then
      use.to:append(target)
    end
  end
end

sgs.ai_use_priority.WeimengCard = 5

sgs.ai_skill_choice.weimeng_num = function(self, choices, data)--简单考虑只取最大值
  choices = choices:split("+")
  return choices[#choices]
end

sgs.ai_skill_exchange["weimeng_giveback"] = function(self,pattern,max_num,min_num,expand_pile)
  local weimeng_give = {}
  local to
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if p:hasFlag("WeimengTarget") then
			to = p
			break
		end
	end
  if self:isFriend(to) then--怎样才不会重复
    if self.player:getHp() > 1 and self:isWeak(to) and self:getCardsNum("Analeptic") > 0 and #weimeng_give < max_num then
      table.insert(weimeng_give, self:getCard("Analeptic"):getEffectiveId())
    end
    if not self:isWeak() and self:isWeak(to) and self:getCardsNum("Peach") > 1 and #weimeng_give < max_num then
      table.insert(weimeng_give, self:getCard("Peach"):getEffectiveId())
    end
    if self:getCardsNum("Jink") > 1 and #weimeng_give < max_num then
      table.insert(weimeng_give, self:getCard("Jink"):getEffectiveId())
    end
    --[[会重复
    local c, friend = self:getCardNeedPlayer(sgs.QList2Table(self.player:getCards("he")),to)
    if friend and friend:objectName() == to:objectName() and #weimeng_give < max_num then
      table.insert(weimeng_give, c:getEffectiveId())
    end
    if self:getCardsNum("Jink") > 1 and self:isWeak(to) and #weimeng_give < max_num then
      table.insert(weimeng_give, self:getCard("Jink"):getEffectiveId())
    end]]
    if self:getCardsNum("Slash") > 1 and not self:hasCrossbowEffect() and #weimeng_give < max_num then
      table.insert(weimeng_give, self:getCard("Slash"):getEffectiveId())
    end
  end
  local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
  for _, c in ipairs(cards) do
    if #weimeng_give < max_num then
      table.insert(weimeng_give, c:getEffectiveId())
    end
  end
	return weimeng_give
end

sgs.ai_skill_choice.weimeng = function(self, choices, data)
  local target = data:toPlayer()
  if self:isFriend(target) then
    return "yes"
  end
  return "no"
end

local weimengzongheng_skill = {}
weimengzongheng_skill.name = "weimengzongheng"
table.insert(sgs.ai_skills, weimengzongheng_skill)
weimengzongheng_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("WeimengZonghengCard") then return end
	return sgs.Card_Parse("@WeimengZonghengCard=.&weimengzongheng")
end

sgs.ai_skill_use_func.WeimengZonghengCard = function(card, use, self)
  local target
  local _, friend = self:getCardNeedPlayer(sgs.QList2Table(self.player:getCards("h")))
  if friend and not friend:isKongcheng() then
    target = friend
  end
  if not target then
    self:sort(self.friends_noself, "hp")
    for _, f in ipairs(self.friends_noself) do
      if self:isWeak(f) and not f:isKongcheng() then
        target = f
        break
      end
    end
  end
  if not target then
    self:sort(self.enemies, "hp")
    for _, p in ipairs(self.enemies) do
      if not p:isKongcheng() then
        target = p
        break
      end
    end
  end
  if target then
    global_room:writeToConsole("危盟纵横目标:"..sgs.Sanguosha:translate(target:getGeneralName()).."/"..sgs.Sanguosha:translate(target:getGeneral2Name()))
	  use.card = card
    if use.to then
      use.to:append(target)
    end
  end
end

sgs.ai_use_priority.WeimengZonghengCard = 5

--荀谌
local fenglve_skill = {}
fenglve_skill.name = "fenglve"
table.insert(sgs.ai_skills, fenglve_skill)
fenglve_skill.getTurnUseCard = function(self)
	if self:willShowForAttack() and not self.player:hasUsed("FenglveCard") and not self.player:isKongcheng() then return sgs.Card_Parse("@FenglveCard=.&fenglve") end
end

sgs.ai_skill_use_func.FenglveCard = function(FLCard, use, self)
	if #self.enemies == 0 then return end
  sgs.ai_use_priority.FenglveCard = 0.5
	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()
	if self.player:hasShownSkill("yingyang") then max_point = math.min(max_point + 3, 13) end

  local notlose = self:getOverflow() > 1
  if self.player:getCardCount(true) < (self:needToThrowArmor() and 2 or 1) and not self:isValuableCard(max_card) then
    notlose = true
  end
	self:sort(self.enemies, "handcard")
	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and enemy:getCardCount(true) > 2 then
			local enemy_max_card = self:getMaxCard(enemy)
			local enemy_number = enemy_max_card and enemy_max_card:getNumber() or 0
			if enemy_max_card and enemy:hasShownSkill("yingyang") then enemy_number = math.min(enemy_number + 3, 13) end
			local allknown = false
			if self:getKnownNum(enemy) == enemy:getHandcardNum() then
				allknown = true
			end
			if (not enemy_max_card and (max_point > 11)) or notlose
				or (enemy_max_card and max_point > enemy_number and not allknown and max_point > 10)
				or (enemy_max_card and max_point > enemy_number and allknown) then
          if notlose or (enemy_max_card and max_point > enemy_number and allknown) then
            sgs.ai_use_priority.FenglveCard = 5
          end
					self.fenglve_card = max_card:getEffectiveId()
					use.card = FLCard
					if use.to then
            use.to:append(enemy)
            return
          end
			end
		end
	end
end

function sgs.ai_skill_pindian.fenglve(minusecard, self, requestor)
  local max_card = self:getMaxCard()
  if not self:isFriend(requestor) and self.player:getCardCount(true) < 5 then
    local max_point = max_card:getNumber()
    for _, card in sgs.qlist(self.player:getHandcards()) do
			local point = card:getNumber()
			if point > max_point then
				max_point = point
				max_card = card
			end
		end
  end
	return max_card
end

sgs.ai_cardneed.fenglve = sgs.ai_cardneed.bignumber

sgs.ai_skill_invoke.anchao =  function(self, data)
  if not self:willShowForAttack() then
    return false
  end
  local target = data:toPlayer()
  if not target or (self:isFriend(target) and not target:isChained()) then
    return false
  end
  local damageStruct = self.player:getTag("AnchaoDamagedata"):toDamage()
  if not self:damageIsEffective_(damageStruct) then
    return false
  end
  local card = damageStruct.card
  local original_num = damageStruct.damage

  local function damageCount(tp,num)
    local n = num
    if tp:hasShownSkill("mingshi") and not self.player:hasShownAllGenerals() then
      n = n - 1
    end
    if tp:getMark("#xiongnve_avoid") > 0 then
      n = n - 1
    end
    if damageStruct.nature == sgs.DamageStruct_Fire
    and (tp:hasArmorEffect("Vine") or self.player:hasSkill("xinghuo")) then
      n = n + 1
    end
    local gongqing_avoid = false
    if tp:hasShownSkill("gongqing") then
      if self.player:getAttackRange() < 3 then
        gongqing_avoid = true
      end
      if self.player:getAttackRange() > 3 then
        n = n + 1
      end
    end
    if (tp:hasArmorEffect("SilverLion") and (not card or not card:isKindOf("Slash") or not IgnoreArmor(self.player, tp)))
    or gongqing_avoid then
      n = 1
    else
      n = n * 2
    end
    return n
  end

  local allshown_invoke = target:hasShownAllGenerals() and (self.player:getHp() > 1 or (self:getCardsNum("Peach") + self:getCardsNum("Analeptic")) > 0)
  local oneshown_invoke = target:hasShownOneGeneral() and (self.player:getHandcardNum() <= 2 or self:getOverflow() > 1 or self.player:hasSkill("lirang"))
  local chained_invoke = false

  if target:isChained() and damageStruct.nature ~= sgs.DamageStruct_Normal then
    local tDamageNum = damageCount(target ,original_num)
    local enemy_dnum = self:isEnemy(target) and tDamageNum or 0
    local friend_dnum = self:isFriend(target) and tDamageNum or 0
    local neutrality_dum = (not self:isFriend(target) and not self:isEnemy(target)) and tDamageNum or 0

    for _, p in sgs.qlist(self.room:getOtherPlayers(target)) do
      if p:isChained() then
        damageStruct.to = p
        if self.player:hasSkill("xinghuo") and damageStruct.nature == sgs.DamageStruct_Fire then--xinghuo是预置加伤可连续传导
          tDamageNum = tDamageNum + 1
        end
        damageStruct.damage = tDamageNum
        if self:damageIsEffective_(damageStruct) then
          local damage_num = damageCount(p, tDamageNum)--考虑初次传导伤害
          if self:isEnemy(p) then
            enemy_dnum = enemy_dnum + damage_num
          elseif self:isFriend(p) then
            friend_dnum = friend_dnum + damage_num
          else
            neutrality_dum = neutrality_dum + damage_num
          end
        end
      end
    end
    if enemy_dnum > 3 and enemy_dnum + neutrality_dum > friend_dnum then
      chained_invoke = true
    end
  end

  if chained_invoke or (not self:isFriend(target) and not target:hasShownOneGeneral())
  or (self:isEnemy(target) and (self:isWeak(target) or oneshown_invoke or (damageCount(target ,original_num) > 2 and allshown_invoke))) then
    return true
  end
	return false
end