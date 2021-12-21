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
--君临天下·EX

--孟达
sgs.ai_skill_invoke.qiuan = function(self, data)
	local damage = data:toDamage()
  if damage.card:isKindOf("AOE") then--优先于奸雄
    if self.get_AOE_subcard then
      self.get_AOE_subcard = nil
      return not self.player:hasSkill("jianxiong")
    end
    return true
  end
  if not self:willShowForDefence() then
    return false
  end
  if self.player:hasSkills(sgs.masochism_skill.."|fankui_simazhao") and self.player:getHp() > 1 and damage.damage < 2 then--详细判断，如节命、望归
    return false
  end
  if self.player:hasSkill("wangxi") and damage.from and self:isFriend(damage.from) and damage.damage < 2 then
    return false
  end
	return true
end

sgs.ai_skill_invoke.liangfan = true

sgs.ai_skill_choice.liangfan = function(self, choices, data)
  local damage = data:toDamage()
  if self.player:isFriendWith(damage.to) and damage.to:getHandcardNum() < 3 then
    return "no"
  end
	return "yes"
end

--[[
  用默认的
  askForCardChosen(player, target, "he", "liangfan", false, Card::MethodGet);
]]

--唐咨
sgs.ai_skill_invoke.xingzhao = function(self, data)
	if not self:willShowForAttack() then
    return false
  end
	return true
end

sgs.ai_skill_invoke.xunxun_tangzi = true

sgs.ai_skill_movecards.xunxun_tangzi = function(self, upcards, downcards, min_num, max_num)
	local upcards_copy = table.copyFrom(upcards)
	local down = {}
	local id1 = self:askForAG(upcards_copy,false,"xunxun_tangzi")
	down[1] = id1
	table.removeOne(upcards_copy,id1)
	local id2 = self:askForAG(upcards_copy,false,"xunxun_tangzi")
	down[2] = id2
	table.removeOne(upcards_copy,id2)
	return upcards_copy,down
end

--张鲁
sgs.ai_skill_invoke.bushi = function(self, data)
	if not self:willShowForMasochism() then
    return false
  end
  local damage = data:toDamage()
	return damage.to:objectName() == self.player:objectName()
end

sgs.ai_skill_playerchosen.bushi = function(self, targets)
  targets = sgs.QList2Table(targets)
  self:sort(targets, "handcard")
	return targets[1]
end

sgs.ai_skill_invoke.midao = function(self, data)
	if self:willShowForAttack() then
    return true
  end
	return false
end

sgs.ai_skill_suit.midao= function(self)
  local use = self.player:getTag("MidaoUseData"):toCardUse()
  local card = use.card
  local targets = sgs.QList2Table(use.to)
  local suit = math.random(0, 3)
  if card:isKindOf("Slash") then--杀激昂和仁王盾
    for _,p in ipairs(targets) do
      if p:hasShownSkills("jiang") then
        suit = math.random(0, 1)
      end
    end
    for _,p in ipairs(targets) do
      if p:hasArmorEffect("RenwangShield") then
        suit = math.random(2, 3)
      end
    end
  end
  if card:isKindOf("TrickCard") then--锦囊帷幕
    for _,p in ipairs(targets) do
      if p:hasShownSkills("weimu") and self:isFriend(p) then
        suit = math.random(0, 1)
      end
      if p:hasShownSkills("weimu") and not self:isFriend(p) then
        suit = math.random(2, 3)
      end
    end
  end
  if (card:isKindOf("Slash") or card:isNDTrick()) then--息兵
    for _,p in ipairs(targets) do
      if p:hasShownSkills("xibing") and (self:isFriend(p) or use.to:length() > 1) then
        suit = math.random(0, 1)
      end
      if p:hasShownSkills("xibing") and not self:isFriend(p) and use.to:length() == 1 then
        suit = math.random(2, 3)
      end
    end
  end
  if card:isKindOf("BasicCard") or card:isNDTrick() then--贞特
    for _,p in ipairs(targets) do
      if p:hasShownSkills("zhente") and not p:setFlags("ZhenteUsed") and self:isFriend(p) then
        suit = math.random(0, 1)
      end
      if p:hasShownSkills("zhente") and not p:setFlags("ZhenteUsed") and not self:isFriend(p) then
        suit = math.random(2, 3)
      end
    end
  end
  for _,p in ipairs(targets) do--玉碎
    if p:hasShownSkills("yusui") and not self:isFriend(p) then
      suit = math.random(2, 3)
    end
  end

	return suit
end

sgs.ai_skill_choice.midao = function(self, choices, data)
  local use = self.player:getTag("MidaoUseData"):toCardUse()
  local card = use.card
  local from = use.from
  local targets = sgs.QList2Table(use.to)
  local fire_value, thunder_value, normal_value = 0,0,0
  for _,p in ipairs(targets) do
    if self:damageIsEffective(p, sgs.DamageStruct_Normal, from) then
      normal_value = normal_value + (self:isFriend(p) and -1 or 1)-- exp and x or y 和 exp ? x : y 等价
    end
    if self:damageIsEffective(p, sgs.DamageStruct_Fire, from) then
      fire_value = fire_value + (self:isFriend(p) and -1 or 1)
    end
    if self:damageIsEffective(p, sgs.DamageStruct_Thunder, from) then
      thunder_value = thunder_value + (self:isFriend(p) and -1 or 1)
    end
    if p:hasArmorEffect("Vine") then
      fire_value = fire_value + (self:isFriend(p) and -2 or 2)
    end
    if p:hasArmorEffect("IronArmor") and card:isKindOf("Slash") then
      fire_value = fire_value + (self:isFriend(p) and 2 or -2)
    end
    if p:isChained() then
      fire_value = fire_value + (self:isFriend(p) and -0.5 or 0.5)--调小0.5，1会出现装太平和被锁时值相等的情况，多少合适？
      thunder_value = thunder_value + (self:isFriend(p) and -0.5 or 0.5)
    end
  end
  global_room:writeToConsole("米道火:"..fire_value.." 雷:"..thunder_value.." 普通:"..normal_value)
  if thunder_value >= fire_value and thunder_value >= normal_value then
    return "thunder"
  end
  if normal_value >= fire_value and normal_value >= thunder_value then
    return "normal"
  end
  if fire_value >= normal_value and fire_value >= thunder_value then--是否应该把普放第一？
    return "fire"
  end
  return "normal"
end

sgs.ai_skill_exchange["midao"] = function(self,pattern,max_num,min_num,expand_pile)
  if self:getOverflow() < 2 or self.player:isKongcheng() then
    return {}
  end
  local use = self.player:getTag("MidaoUseData"):toCardUse()
  local card = use.card
  local targets = sgs.QList2Table(use.to)--可以细化对目标效果不好时改属性？
  if card:isKindOf("Analeptic") and self:getCardsNum("Slash") > 0 and self:slashIsAvailable() then--酒有杀不给
    return {}
  end
  --[[桃使用优先级较低？一般不会再使用其他牌？
  if card:isKindOf("Peach") then
  end
  ]]
  local zhanglu = sgs.findPlayerByShownSkillName("midao")
  if self:isFriend(zhanglu) and self:isWeak(zhanglu) then
    if self.player:getHp() > 1 and self:getCardsNum("Analeptic") > 0 then
      return self:getCard("Analeptic"):getEffectiveId()
    end
    if not self:isWeak() and self:getCardsNum("Peach") > 1 then
      return self:getCard("Peach"):getEffectiveId()
    end
    if self:getCardsNum("Jink") > 1 then
      return self:getCard("Jink"):getEffectiveId()
    end
  end
  local cards = self.player:getCards("h")-- 获得所有手牌
  cards=sgs.QList2Table(cards) -- 将列表转换为表
  self:sortByUseValue(cards,true)
  return cards[1]:getEffectiveId()
end

--糜芳＆傅士仁
sgs.ai_skill_invoke.fengshix = function(self, data)
	if not self:willShowForAttack() then
    return false
  end
  local target = data:toPlayer()
  if not target or self:isFriend(target) then
    return false
  end
  local use = self.player:getTag("FengshixUsedata"):toCardUse()
  local card = use.card--更多的非伤害锦囊的情况？现在空城也可触发无需担心
  self.fengshix_discard = nil
  if card:isKindOf("FireAttack") and target:getCardCount(true) == 1 then
    return false
  end
  if card:isKindOf("Drowning") and target:getEquips():length() == 1 then
    self.fengshix_discard = target:getEquips():first():getEffectiveId()
    return true
  end
  if self.player:getHandcardNum() > 3 or self:isWeak(target) then
    return true
  end
	return false
end

sgs.ai_skill_choice.fengshix = function(self, choices, data)
  self.fengshix_discard = nil
  local use = data:toCardUse()
  if use.card:isKindOf("FireAttack") and use.to:length() == 1 and use.to:first():getCardCount(true) == 1 then
    return "no"
  end
  if use.to:length() == 1 and self:isEnemy(use.to:first()) and (self.player:getHandcardNum() > 3 or self:isWeak(use.to:first())) then
    return "yes"
  end
	return "no"
end

sgs.ai_skill_cardchosen.fengshix = function(self, who, flags, method)
  if self.fengshix_discard then--自己被水淹七军缺信息
    return self.fengshix_discard
  end
  return self:askForCardChosen(who, flags, "fengshix_dismantlement", method)
end

sgs.ai_cardneed.fengshix = function(to, card, self)
	return to:getHandcardNum() < 3
end

--刘琦
sgs.ai_skill_playerchosen.wenji = function(self, targets)
  local target
  targets = sgs.QList2Table(targets)
  self:sort(targets, "handcard")
  for _, p in ipairs(targets) do
    if sgs.isAnjiang(p) then
      target = p
    end
  end
  local weak_enemy = false
  for _, enemy in ipairs(self.enemies) do
    if self:isWeak(enemy) then
      weak_enemy = true
      break
    end
  end
  if not target and weak_enemy then
    self:sort(targets, "handcard", true)
    for _, p in ipairs(targets) do
      if self.player:isFriendWith(p) and (getKnownCard(p, self.player, "Slash")--进攻
         + getKnownCard(p, self.player, "AOE") + getKnownCard(p, self.player, "Duel") > 0) then
        target = p
      end
    end
    if not target then
      for _, p in ipairs(targets) do
        if self.player:isFriendWith(p) and p:getHandcardNum() > 2 then
          target = p
        end
      end
    end
  end
  if not target then
    for _, p in ipairs(targets) do
      if self:isFriend(p) and self:needToThrowArmor(p) then--拿队友防具，屯江无法主动触发所以暂无配合
        target = p
      end
    end
  end
  local give_peach = false
  if not self.player:isNude() then
    local cards = self.player:getCards("he")
    cards = sgs.QList2Table(cards)
    self:sortByUseValue(cards,true)
    if cards[1]:isKindOf("Peach") then
      give_peach = true
    end
  end
  self:sort(targets, "handcard")
  if not target and not give_peach then--敌人，不给桃
    for _, p in ipairs(targets) do
      if not self.player:isFriendWith(p) then
        target = p
      end
    end
  end
  if target then
    return target
  end
	return {}--没有合适目标不发动
end

sgs.ai_skill_exchange["wenji_give"] = function(self,pattern,max_num,min_num,expand_pile)
  local liuqi = sgs.findPlayerByShownSkillName("wenji")
  if self:isFriendWith(liuqi) then--队友：杀、duel、AOE
    if self:getCardsNum("AOE") > 0 then
      local card
      card = self:getCard("SavageAssault")
      if card and self:getAoeValue(card) > 0 then
        return card:getEffectiveId()
      end
      card = self:getCard("ArcheryAttack")
      if card and self:getAoeValue(card) > 0 then
        return card:getEffectiveId()
      end
    end
    if self:getCardsNum("Slash") > 0 then
      return self:getCard("Slash"):getEffectiveId()
    end
    if self:getCardsNum("Duel") > 0 then
      return self:getCard("Duel"):getEffectiveId()
    end
  end
  if self:needToThrowArmor() then
    return self.player:getArmor():getEffectiveId()
  end
  local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	return cards[1]:getEffectiveId()
end

sgs.ai_skill_exchange["wenji_giveback"] = function(self,pattern,max_num,min_num,expand_pile)
  local to
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if p:hasFlag("WenjiTarget") then
			to = p
			break
		end
	end
  if self:isFriend(to) and self:isWeak(to) then
    if self.player:getHp() > 1 and self:getCardsNum("Analeptic") > 0 then
      return self:getCard("Analeptic"):getEffectiveId()
    end
    if not self:isWeak() and self:getCardsNum("Peach") > 1 then
      return self:getCard("Peach"):getEffectiveId()
    end
    if self:getCardsNum("Jink") > 1 then
      return self:getCard("Jink"):getEffectiveId()
    end
  end
  local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	return cards[1]:getEffectiveId()
end

function SmartAI:hasWenjiBuff(card)
	if self.player:hasSkill("wenji") then
    local record_cards = self.player:property("wenji_record"):toString():split("+")
    if table.contains(record_cards,card) then
      return true
    end
    for _, id in sgs.qlist(card:getSubcards()) do
      local subcard = sgs.Sanguosha:getCard(id)
        if table.contains(record_cards,subcard) then
          return true
        end
    end
  end
	return false
end

sgs.ai_skill_invoke.tunjiang = true

--士燮
sgs.ai_skill_choice.lixia = function(self, choices, data)
  local shixie = sgs.findPlayerByShownSkillName("lixia")
  if not shixie then
    return "no"
  end
  if self.player:objectName() ~= shixie:objectName() and self:isFriend(shixie) then
    if self:needToThrowArmor(shixie) or ((shixie:hasSkills(sgs.lose_equip_skill) and self:isWeak(shixie)--弃装备技能且不丢防具、宝物，马呢？
      and (shixie:getEquips():length() - (shixie:getArmor() and 1 or 0) - (shixie:getTreasure() and 1 or 0)) > 0)) then
      return "yes"
    end
  end
  if self:isEnemy(shixie) then
    local canslash_shixie = false
    for _, p in ipairs(self.friends) do
      if p:canSlash(shixie, nil, true) then
        canslash_shixie = true
        break
      end
    end
    if self:getOverflow() > 2 or shixie:getEquips():length() > 2 or not canslash_shixie
    or (shixie:hasTreasure("WoodenOx") and shixie:getPile("wooden_ox"):length() > 1) then
      return "yes"
    end
  end
	return "no"
end

sgs.ai_skill_choice["lixia_effect"]= function(self, choices, data)
  choices = choices:split("+")
  local shixie = sgs.findPlayerByShownSkillName("lixia")
  local shixie_draw
  for _, choice in ipairs(choices) do
    if choice:match("draw") then
      shixie_draw = choice
      break
    end
  end
  if shixie and self:isFriend(shixie) then
    return shixie_draw
  end
  if self:needToLoseHp() then
    return "losehp"
  end
  if self:getOverflow() > 2 then--还可以优化条件？
    return "discard"
  end
	return shixie_draw
end


--董昭
local quanjin_skill = {}
quanjin_skill.name = "quanjin"
table.insert(sgs.ai_skills, quanjin_skill)
quanjin_skill.getTurnUseCard = function(self, inclusive)
  if self.player:getHandcardNum() == 0 then return end
  if not self.player:hasUsed("QuanjinCard") then
    local can_quanjin = false
    for _, p in sgs.qlist(self.room:getAlivePlayers()) do
      if p:getMark("Global_InjuredTimes_Phase") > 0 then
        can_quanjin = true
      end
    end
    if can_quanjin then
      return sgs.Card_Parse("@QuanjinCard=.&quanjin")
    end
  end
end

sgs.ai_skill_use_func.QuanjinCard= function(qjcard, use, self)
  sgs.ai_use_priority.QuanjinCard = 2.4
  if self.player:hasSkill("daoshu") then
    sgs.ai_use_priority.QuanjinCard = 2.95--盗书之前
  end
  local target
  local my_hnum = self.player:getHandcardNum()
  local maxcard_num,maxhurt_num= 0,0
  local maxcard_hurt
  for _, p in sgs.qlist(self.room:getAlivePlayers()) do
    local card_num = p:getHandcardNum()
    if card_num > maxcard_num then
      maxcard_num = card_num
    end
    if p:getMark("Global_InjuredTimes_Phase") > 0 then
      if card_num > maxhurt_num  then
        maxhurt_num = card_num
        maxcard_hurt = p
      end
    end
  end

  for _,c in sgs.qlist(self.player:getCards("h")) do
    local dummy_use = { isDummy = true }
    if c:isKindOf("BasicCard") then--参考怀异的，其他类型牌是否需要写？
        self:useBasicCard(c, dummy_use)
    end
  end
  local handcards = self.player:getCards("h")
	handcards = sgs.QList2Table(handcards)
	self:sortByKeepValue(handcards)
	local card = handcards[1]
  local card_str = "@QuanjinCard=" .. card:getEffectiveId() .."&quanjin"

  local weak_friend
  self:sort(self.friends_noself, "hp")
  for _, friend in ipairs(self.friends_noself) do
    if friend:getMark("Global_InjuredTimes_Phase") > 0 then
      weak_friend = friend
      break
    end
  end

  if card:isKindOf("Peach") or (maxcard_num >= maxhurt_num)--桃或者牌最多的不是受伤的
  or (my_hnum > 2 and my_hnum >= maxcard_num)--自己手牌最多发牌
  or (maxcard_num >= my_hnum + 2)--能摸3张
  or (weak_friend and weak_friend:getHandcardNum() + 1 >= maxhurt_num) then--队友的牌数比受伤的不少于1
    if weak_friend then
      target = weak_friend
    end
  end
  if not target and not card:isKindOf("Peach") and (my_hnum < maxcard_num or my_hnum == maxhurt_num) then
    target = maxcard_hurt
  end

  if target then
    use.card =  sgs.Card_Parse(card_str)
		if use.to then
			use.to:append(target)
      local visibleflag--记录给出的手牌，盗书等技能需要
      visibleflag = string.format("%s_%s_%s", "visible", self.player:objectName(), target:objectName())
      if not card:hasFlag("visible") then card:setFlags(visibleflag) end
			global_room:writeToConsole("使用劝进目标:"..target:objectName().." 其手牌数:"..target:getHandcardNum())
		end
	end
end

sgs.ai_skill_choice["startcommand_quanjin"] = sgs.ai_skill_choice.startcommand_to

sgs.ai_skill_choice["docommand_quanjin"] = function(self, choices, data)
  local source = data:toPlayer()
  local index = self.player:getMark("command_index")
  local is_enemy = self:isEnemy(source)
  local is_friend = self:isFriend(source)
  local source_hnum = source:getHandcardNum()
  local my_hnum = self.player:getHandcardNum()
  local draw_num = my_hnum - source_hnum
  if index == 1 then
    if not is_enemy and not is_friend then
      return "yes"
    end
    if is_friend then
      if draw_num <= 1 then
        return "yes"
      end
      if draw_num == 2 and not self:isWeak(source) then
        for _, p in ipairs(self.enemies) do
          if self:isWeak(p) and self:isEnemy(source, p) then
            return "yes"
          end
        end
      end
    end
    if is_enemy and draw_num > 3 then
      for _, p in ipairs(self.friends) do
        if self:isWeak(p) and self:isEnemy(source, p) then
          return "no"
        end
      end
      return "yes"
    end
  end
  if index == 2 then
    if is_friend and draw_num < 2 then
      return "yes"
    end
    if is_enemy and draw_num > 1 then
      return "yes"
    end
  end
  if index == 5 then
    if not self.player:faceUp() then
      return "yes"
    end
    if is_enemy and draw_num > 4 and math.random(1, 2) > 1 then
      return "yes"
    end
  end
  if is_enemy then
    if index == 3 and draw_num > 3 and not self:isWeak() then
      return "yes"
    end
    if index == 4 and draw_num > 1 and not source:canSlash(self.player, nil, true) then
      return "yes"
    end
    if index == 6 and self.player:getEquips():length() < 3 and my_hnum < 3 and draw_num > 1 then
      return "yes"
    end
  end
  return "no"
end

sgs.ai_skill_playerchosen["command_quanjin"] = sgs.ai_skill_playerchosen.damage

local zaoyun_skill = {}
zaoyun_skill.name = "zaoyun"
table.insert(sgs.ai_skills, zaoyun_skill)
zaoyun_skill.getTurnUseCard = function(self, inclusive)
  if self.player:getHandcardNum() == 0 then return end
  if not self.player:hasUsed("ZaoyunCard") and self.player:hasShownOneGeneral() then
    --self.player:speak("zaoyun技能卡:"..self.player:objectName())
    return sgs.Card_Parse("@ZaoyunCard=.&zaoyun")
  end
end

sgs.ai_skill_use_func.ZaoyunCard= function(card, use, self)
  sgs.ai_use_priority.ZaoyunCard = 2.65--杀之前，怎么配合一技能先后？
  if self.player:hasSkill("daoshu") then
    sgs.ai_use_priority.QuanjinCard = 2.97--盗书之前
  end

  for _,c in sgs.qlist(self.player:getCards("h")) do
    local dummy_use = {
        isDummy = true,
    }
    if c:isKindOf("Peach") then--先吃桃
       self:useBasicCard(c, dummy_use)
    end
  end
  local target
  self:sort(self.enemies, "hp")
  for _, p in ipairs(self.enemies) do
    if p:hasShownOneGeneral() and not self.player:isFriendWith(p) and self:damageIsEffective(p, nil, self.player)
    and not self:needDamagedEffects(p, self.player) and not self:needToLoseHp(p, self.player)
    and self.player:distanceTo(p) > 1 and self.player:getHandcardNum() + 1 >= self.player:distanceTo(p) then
      local nearest = 6
      if p:getHp() == 1 and self:isWeak(p) and self.player:getHandcardNum() > 3 then
        sgs.ai_use_priority.ZaoyunCard = 3.4--AOE后，手牌充裕
        target = p
        break
      end
      if not self:isFriend(p) and self:isWeak(p) and self.player:distanceTo(p) <= nearest then
        nearest = self.player:distanceTo(p)
        target = p--技能优先度较低，应该其他牌差不多已出完，攻击最近的虚弱玩家
      end
    end
  end
  if not target then
    for _, p in ipairs(self.enemies) do
      if p:hasShownOneGeneral() and not self.player:isFriendWith(p) and self:damageIsEffective(p, nil, self.player)
      and not self:needDamagedEffects(p, self.player) and not self:needToLoseHp(p, self.player)
      and self.player:distanceTo(p) == 2 and self.player:getHandcardNum() > 1 then
        target = p--没有血少的则攻击距离2的
      end
    end
  end
  if target then
  	local card_list = {}
    local need_num = self.player:distanceTo(target) - 1
    local handcards = self.player:getCards("h")
    handcards = sgs.QList2Table(handcards)
    self:sortByUseValue(handcards, true)
    for _,c in ipairs(handcards) do
      if not (c:isKindOf("Peach") and self.player:getMark("GlobalBattleRoyalMode") == 0) then
        table.insert(card_list, c:getEffectiveId())
      end
      if #card_list == need_num then
        break
      end
    end
    if #card_list == need_num then
      local card_str = ("@ZaoyunCard=" .. table.concat(card_list, "+") .."&zaoyun")
      use.card =  sgs.Card_Parse(card_str)
      assert(use.card)
		  if use.to then
			  use.to:append(target)
			  global_room:writeToConsole("使用凿运目标:"..target:objectName().." 其距离:"..self.player:distanceTo(target))
		  end
   end
	end
end

--徐庶
sgs.ai_skill_invoke.pozhen = function(self, data)
  local target = data:toPlayer()
  local has_attack_skill = target:hasSkills("luanji|shuangxiong")
  if not self:isFriend(target) and (self:getOverflow(target) > 1 or target:getHandcardNum() > 4) then
    local weak_count = 0
    for _, p in ipairs(self.friends) do
      if (target:canSlash(p, nil, true) or has_attack_skill) and self:isWeak(p) then
        weak_count = weak_count + 1
        if weak_count > 1 then
          return true
        end
      end
      if (target:canSlash(p, nil, true) or has_attack_skill) and p:getHp() == 1 then
        return true
      end
    end
  end
  if self:isEnemy(target) and self.player:getHp() == 1 then
      for _, p in ipairs(self.friends) do
        if (target:canSlash(p, nil, true) or has_attack_skill) and self:isWeak(p) then
          return true
        end
      end
  end
	return false
end

sgs.ai_skill_choice["pozhen-discard"] = function(self, choices, data)
  local target = self.room:getCurrent()
  local np = target:getNextAlive()
  local lp = target:getLastAlive()
  if self:isFriend(np) and self:isFriend(lp) then
    return "no"
  end
  return "yes"
end

sgs.ai_skill_invoke.jiancai = function(self, data)
  local prompt = data:toString():split(":")
  if prompt[1] == "transform" then
    --global_room:writeToConsole("荐才:变更时的备选武将数+2")
    return true
  end
  if prompt[1] == "damage" then--无法知道伤害大小信息，判断多点减伤和桃数量
    local target = prompt[2]
    for _, p in sgs.qlist(self.room:getAlivePlayers()) do
      if p:objectName() == target and self.player:isFriendWith(p) and p:getHp() == 1 then--处理野心家？
        return true
      end
    end
  end
	return false
end

--吴景
local diaogui_skill = {}
diaogui_skill.name = "diaogui"
table.insert(sgs.ai_skills, diaogui_skill)
diaogui_skill.getTurnUseCard = function(self)
  if self.player:hasUsed("DiaoguiCard") then return end
  if self:getCardsNum("EquipCard") == 0 then return end

  local equipcard
  if self:needToThrowArmor() then
		equipcard = self.player:getArmor()
  end
  if not equipcard and self.player:hasSkills(sgs.lose_equip_skill) and self.player:hasEquip()  then
    local equip = self.player:getCards("e")
    equip = sgs.QList2Table(equip)
    self:sortByUseValue(equip, true)
    equipcard = equip[1]
  end
  if not equipcard then
    local cards = self.player:getCards("he")
    for _, id in sgs.qlist(self.player:getHandPile()) do
      cards:prepend(sgs.Sanguosha:getCard(id))
    end
    cards = sgs.QList2Table(cards)
    self:sortByUseValue(cards, true)
    for _, c in ipairs(cards) do
      if c:isKindOf("EquipCard") then
        equipcard = c
        break
      end
    end
  end
  if equipcard then
    return sgs.Card_Parse("@DiaoguiCard=" .. equipcard:getEffectiveId())
  end
end

sgs.ai_skill_use_func.DiaoguiCard = function(card, use, self)
--[[
      foreach (ServerPlayer *p, to_count) {
        Player *p1 = p->getNextAlive();
        Player *p2 = p->getLastAlive();

        if (p1 && p2 && p1 != p2 && p1->getFormation().contains(p2)) {
            if (card_use.from->isFriendWith(p1))
                x = qMax(x, p1->getFormation().length());
        }
    }
    self.player:getNextAlive():getFormation()
    enemy:getFormation():contains(self.player)
]]--主动形成队列怎么判定？

	local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
  local clone_tiger = sgs.Sanguosha:cloneCard("lure_tiger", card:getSuit(), card:getNumber())
  self:useCardLureTiger(clone_tiger, dummyuse)
	if not dummyuse.to:isEmpty() then
    use.card = card
		if use.to then
			use.to =  dummyuse.to
    end
  end
end

sgs.ai_use_priority.DiaoguiCard = sgs.ai_use_priority.LureTiger - 0.05--先用普通的掉虎

sgs.ai_skill_invoke.fengyang = true

--严白虎
sgs.ai_skill_invoke.zhidao = function(self, data)
	if not self:willShowForDefence() or not self:willShowForAttack() then
    return false
  end
  if (self:getCardsNum("AmazingGrace") + self:getCardsNum("GodSalvation") +  self:getCardsNum("AwaitExhausted") +
  self:getCardsNum("SavageAssault") + self:getCardsNum("ArcheryAttack") > 0) then
    return false
  end
  --判断杀目标距离
  local max_range = 0
  local horse_range = 0
  local current_range = self.player:getAttackRange()
  for _,card in sgs.qlist(self.player:getCards("he")) do
    if card:isKindOf("Weapon") and max_range < sgs.weapon_range[card:getClassName()] then
      max_range = sgs.weapon_range[card:getClassName()]
    end
  end
  if self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse() then
    horse_range = 1
  end
  local range_fix = math.min(current_range - max_range, 0) - horse_range
  if self:getCardsNum("Slash") == 0 then return false end
	local slashes = self:getCards("Slash")
	self:sortByUseValue(slashes)
	self:sort(self.enemies, "defenseSlash")
	for _, slash in ipairs(slashes) do
		for _, enemy in ipairs(self.enemies) do
			if self:isWeak(enemy) and not self.player:canSlash(enemy, slash, true, range_fix) and not self:slashProhibit(slash, enemy)
				and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
				and not (self.player:hasFlag("slashTargetFix") and not enemy:hasFlag("SlashAssignee")) then
				return true
			end
		end
	end
	return false
end

sgs.ai_skill_playerchosen.zhidao = function(self, targets)
  if self:getCardsNum("AmazingGrace") > 0 or self:getCardsNum("GodSalvation") > 0  or self:getCardsNum("AwaitExhausted") > 0 then
    for _,p in sgs.qlist(targets) do
      if self:isFriendWith(p) then
        return p
      end
    end
    for _,p in sgs.qlist(targets) do
      if self:isFriend(p) then
        return p
      end
    end
  end
	return sgs.ai_skill_playerchosen.damage(self, targets)
end

sgs.ai_skill_invoke.jilix = function(self, data)
  local prompt = data:toString()
  if prompt == "damage" then
    return true
  else
    local prompt_list = prompt:split(":")
    if prompt_list[2] == self.player:objectName() or prompt_list[4]:match("Peach") or prompt_list[4]:match("BefriendAttacking") then
      return true
    end
  end
	return false
end

--钟会
sgs.ai_skill_invoke.quanji = function(self, data)
	if not self:willShowForMasochism() or not self:willShowForAttack() then
    return false
  end
	return true
end

sgs.ai_skill_exchange._quanji = function(self,pattern,max_num,min_num,expand_pile)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
  if self.player:getPhase() <= sgs.Player_Play then
		self:sortByUseValue(cards, true)
	else
		self:sortByKeepValue(cards)
	end
  for _, c in ipairs(cards) do--藏君主装备
    if c:isKindOf("LuminousPearl") then
      local lord = self.room:getLord("wu")
      if lord and self:isEnemy(lord) then
        return c:getEffectiveId()
      end
    elseif c:isKindOf("DragonPhoenix") then
      local lord = self.room:getLord("shu")
      if lord and self:isEnemy(lord) then
        return c:getEffectiveId()
      end
    elseif c:isKindOf("PeaceSpell") then
      local lord = self.room:getLord("qun")
      if lord and self:isEnemy(lord) then
        return c:getEffectiveId()
      end
    elseif c:isKindOf("SixDragons") then
      local lord = self.room:getLord("wei")
      if lord and self:isEnemy(lord) then
        return c:getEffectiveId()
      end
    end
  end
  if #cards > 1 and cards[1]:isKindOf("Crossbow")--别放连弩
  and not ((cards[2]:isKindOf("Peach") or cards[2]:isKindOf("Analeptic")) and self.player:getHp() == 1) then
    return cards[2]:getEffectiveId()
  end
	return cards[1]:getEffectiveId()
end

local paiyi_skill = {}
paiyi_skill.name = "paiyi"
table.insert(sgs.ai_skills, paiyi_skill)
paiyi_skill.getTurnUseCard = function(self)
	if (self.player:getPile("power_pile"):length() > 0 and not self.player:hasUsed("PaiyiCard")) then
		return sgs.Card_Parse("@PaiyiCard=" .. self.player:getPile("power_pile"):first())
	end
	return nil
end

sgs.ai_skill_use_func.PaiyiCard = function(card, use, self)
  sgs.ai_use_priority.PaiyiCard = 2.4
	local target
  if self.player:getPile("power_pile"):length() > 3 then
    self:sort(self.friends, "defense")
	  for _, friend in ipairs(self.friends) do
		  if friend:getHandcardNum() < 2 and not self:needKongcheng(friend, true) and self.player:isFriendWith(friend) then
			  target = friend
        break
		  end
	  end
	  if not target then
		  target = self.player
	  end
  else--4权以下，排异打伤害优先度多少合适？
 	  self:sort(self.enemies, "hp")
	  if not target then
		  for _, enemy in ipairs(self.enemies) do
			  if enemy:getHp() == 1 and self:isWeak(enemy)
				and not self:hasSkills(sgs.masochism_skill, enemy)
        and not enemy:hasSkill("jijiu")
				and self:damageIsEffective(enemy, nil, self.player)
				and not (self:needDamagedEffects(enemy, self.player) or self:needToLoseHp(enemy))
				and enemy:getHandcardNum() + self.player:getPile("power_pile"):length() - 1 > self.player:getHandcardNum() then
				  target = enemy
          break
			  end
	    end
    end
  end
  if self.player:getPile("power_pile"):length() > 7 then
    sgs.ai_use_priority.PaiyiCard = 10
  end
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_card_intention.PaiyiCard = function(self, card, from, tos)
	local to = tos[1]
	if to:objectName() == from:objectName() then return end
	if from:isFriendWith(to) then
    sgs.updateIntention(from, to, -60)
	else
		sgs.updateIntention(from, to, 60)
	end
end

sgs.paiyi_keep_value = {
	Crossbow = 6
}

function sgs.ai_cardneed.paiyi(to, card, self)
  return card:isKindOf("Crossbow")
end

--司马昭
sgs.ai_skill_invoke.suzhi = function(self, data)
	return self:willShowForAttack()
end

function sgs.ai_cardneed.suzhi(to, card, self)
	return card:isKindOf("Axe") or isCard("Duel",card, to)
end

sgs.ai_skill_invoke.fankui_simazhao = function(self, data)
	if not self:willShowForMasochism() then return false end
	local target = data:toDamage().from
	if not target then return end
	if sgs.ai_need_damaged.fankui(self, target, self.player) then return true end

	if self:isFriend(target) then
		if self:getOverflow(target) > 2 then return true end
		if self:doNotDiscard(target) then return true end
		return (target:hasShownSkills(sgs.lose_equip_skill) and not target:getEquips():isEmpty())
		  or (self:needToThrowArmor(target) and target:getArmor()) or self:doNotDiscard(target)
	end
	if self:isEnemy(target) then
		if self:doNotDiscard(target) then return false end
		return true
	end
	return true
end

sgs.ai_skill_invoke.zhaoxin = function(self, data)
  if not self:willShowForDefence() or not self:willShowForMasochism() then
    return false
  end
  local my_hnum = self.player:getHandcardNum()
  local targets = {}
  self.zhaoxin_target = nil
  for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
    if not p:isKongcheng() and p:getHandcardNum() <= my_hnum then
      table.insert(targets, p)
    end
  end
  if #targets == 0 then
    return false
  end
  self:sort(targets, "handcard", true)

  local my_value = 0
  for _, card in sgs.qlist(self.player:getHandcards()) do
    if self.player:getPhase() <= sgs.Player_Play then
      my_value = my_value + self:getUseValue(card)
    else
      my_value = my_value + self:getKeepValue(card)
    end
  end

  local same_card_target, one_less_target
  local same_card_value, one_less_value = 0, 0
  local mark_peach_num = self.player:getMark("@companion") + self.player:getMark("@careerist")--包含标记桃
  local need_peach = (self.player:getHp() > 1 and self:getCardsNum("Peach") < 1 + mark_peach_num)
        or (self.player:getHp() == 1 and self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < 1 + mark_peach_num)

  for _, p in ipairs(targets) do
    local known = 0
    local value = 0
    local p_hnum = p:getHandcardNum()
    for _, card in sgs.qlist(p:getHandcards()) do
      if sgs.cardIsVisible(card, p, self.player) then
        known = known + 1
        if self.player:getPhase() <= sgs.Player_Play then
          value = value + self:getUseValue(card)
        else
          value = value + self:getKeepValue(card)
        end
        if isCard("Peach", card, self.player) or isCard("Analeptic", card, self.player) then
          if need_peach and self:isWeak() then
            global_room:writeToConsole("昭心找桃")
            self.zhaoxin_target = p
            return true
          end
        end
      end
    end
    if value > my_value then
      global_room:writeToConsole("昭心换好牌")
      self.zhaoxin_target = p
      return true
    end
    if p_hnum == my_hnum and not (known == p_hnum and value < my_value) and value >= same_card_value then
      same_card_value = value
      same_card_target = p
    end
    if p_hnum + 1 == my_hnum and not (known == p_hnum and value < my_value) and value >= one_less_value then
      one_less_value = value
      one_less_target = p
    end
  end
  if need_peach and same_card_target then
    global_room:writeToConsole("昭心换等量牌")
    self.zhaoxin_target = same_card_target
    return true
  end
  if need_peach and self.player:isWounded() and one_less_target then
    global_room:writeToConsole("昭心换-1牌")
    self.zhaoxin_target = one_less_target
    return true
  end
	return false
end

sgs.ai_skill_playerchosen["zhaoxin_exchange"] = function(self, targets)
  targets = sgs.QList2Table(targets)
  if self.zhaoxin_target then-- and table.contains(targets ,self.zhaoxin_target)
    global_room:writeToConsole("昭心目标:"..sgs.Sanguosha:translate(self.zhaoxin_target:getGeneralName()).."/"..sgs.Sanguosha:translate(self.zhaoxin_target:getGeneral2Name()))
    return self.zhaoxin_target
  end
  self:sort(targets, "handcard", true)
	return targets[1]
end

--孙綝
sgs.ai_skill_invoke.shilu = true

sgs.ai_skill_cardask["@shilu"] = function(self, data, pattern, target, target2, arg, arg2)
  local num = tonumber(arg)
  local unpreferedCards = {}--制衡，配合xiongnve_attack换杀

  local function addcard(card)
    if #unpreferedCards < num and not card:canRecast() then
      table.insert(unpreferedCards, card:getId())
    end
  end

  local allcards = self.player:getCards("he")
	allcards = sgs.QList2Table(allcards)

  if self:needToThrowArmor() then
    addcard(self.player:getArmor())
  end

  if #unpreferedCards == 0 then
    return "."
  end
  return "$" .. table.concat(unpreferedCards, "+")
end

sgs.ai_skill_invoke.xiongnve = function(self, data)
  if data:toString() == "attack" then
    self.xiongnve_choice = nil
    local name = sgs.ai_skill_choice.xiongnve_attack(self, self.player:property("massacre_pile"):toString())
    if name and self.xiongnve_choice then
      global_room:writeToConsole("凶虐进攻选择:"..name.."|"..self.xiongnve_choice)
      return true
    end
  end
  if data:toString() == "defence"  then
    if self:isWeak() or self.player:getHp() < 2 then
      return true
    end
    if self.player:getLostHp() > 1 or self.player:getHp() < 3 then
      local useless_num = 0
      local generals = self.player:property("massacre_pile"):toString():split("+")
      local xiongnve_kingdom = {["wei"] = {}, ["shu"] = {}, ["wu"] = {}, ["qun"] = {}, ["careerist"] = {}, ["double"] = {}}
      for _, name in ipairs(generals) do
        local general = sgs.Sanguosha:getGeneral(name)
        if not general:isDoubleKingdoms() then
          table.insert(xiongnve_kingdom[general:getKingdom()],name)
        else
          table.insert(xiongnve_kingdom["double"],name)
        end
      end
      local kingdoms = {wei = 0, shu = 0, wu = 0, qun = 0, careerist = 0}--计算势力的人数，正是敌人，负是队友
      for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
        if p:hasShownOneGeneral() then--非暗将
          local p_kingdom = p:getKingdom()
          if p_kingdom == "god" then
            p_kingdom = "careerist"
          end
          kingdoms[p_kingdom] = kingdoms[p_kingdom] + (self:isFriend(p) and -1 or 1)
        end
      end
      for key, value in pairs(kingdoms) do
        if value == 0 and #xiongnve_kingdom[key] > 0 then
          useless_num = useless_num + #xiongnve_kingdom[key]
        end
        if value > 0 and #xiongnve_kingdom[key] > math.min(value*2, 5) then
          useless_num = useless_num + #xiongnve_kingdom[key] - value
        end
      end
      for _, name in ipairs(xiongnve_kingdom["double"]) do
        local general = sgs.Sanguosha:getGeneral(name)
			  local double_kingdoms = general:getKingdoms()
        if kingdoms[double_kingdoms[1]] == 0 and kingdoms[double_kingdoms[2]] == 0 then
          useless_num = useless_num + 1
        end
      end
      if useless_num > 1 then
        return true
      end
    end
  end
	return false
end

sgs.ai_skill_choice.xiongnve_attack = function(self, generals)
  generals = generals:split("+")
  local xiongnve_kingdom = {["wei"] = {}, ["shu"] = {}, ["wu"] = {}, ["qun"] = {}, ["careerist"] = {}, ["double"] = {}}
	for _, name in ipairs(generals) do
		local general = sgs.Sanguosha:getGeneral(name)
		if not general:isDoubleKingdoms() then
			table.insert(xiongnve_kingdom[general:getKingdom()],name)
		else
			table.insert(xiongnve_kingdom["double"],name)
		end
	end
  local kingdoms = {wei = 0, shu = 0, wu = 0, qun = 0, careerist = 0}--计算势力的人数，正是敌人，负是队友
  local kingdom_players = {wei = {}, shu = {}, wu = {}, qun = {}, careerist = {}}--各国家成员
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not p:isRemoved() and p:hasShownOneGeneral() then--非暗将和掉虎
			local p_kingdom = p:getKingdom()
			if p_kingdom == "god" then
				p_kingdom = "careerist"
			end
			kingdoms[p_kingdom] = kingdoms[p_kingdom] + (self:isFriend(p) and -1 or 1)
      table.insert(kingdom_players[p_kingdom], p)
		end
	end
  local function double_first(kingodm)
    for _, name in ipairs(xiongnve_kingdom["double"]) do
      local general = sgs.Sanguosha:getGeneral(name)
			local double_kingdoms = general:getKingdoms()
      if kingdoms[double_kingdoms[1]] >= 0 and kingdoms[double_kingdoms[2]] >= 0
      and (double_kingdoms[1] == kingodm or double_kingdoms[2] == kingodm) then
        return name
      end
    end
    if #xiongnve_kingdom[kingodm] > 0 then
      return xiongnve_kingdom[kingodm][1]
    end
    return nil
  end

  if self:getCardsNum("Slash") > 1 then
    local max_slash_kingdom
    local slash_enemy
    local e_num = 0
    local slash = sgs.cloneCard("slash")
    self:sort(self.enemies, "hp")
    for _, enemy in ipairs(self.enemies) do
      if self.player:canSlash(enemy) and not self:slashProhibit(slash ,enemy) and self:slashIsEffective(slash, enemy) then
        local enemy_kingdom = enemy:getKingdom()
        if enemy_kingdom == "god" then
          enemy_kingdom = "careerist"
        end
        if kingdoms[enemy_kingdom] > e_num and double_first(enemy_kingdom) then
          max_slash_kingdom = enemy_kingdom
          slash_enemy = enemy
          e_num = kingdoms[enemy_kingdom]
        end
      end
    end
    if max_slash_kingdom then
      if self:hasCrossbowEffect() or self:getCardsNum("Crossbow", 'he') > 0 then--self.player:hasSkills(sgs.force_slash_skill)
        self.xiongnve_choice = "adddamage"
      else
        self.xiongnve_choice = "nolimit"
      end
      return double_first(max_slash_kingdom)
    end
  end
	if self:getCardsNum("AOE") > 0 then
    local max_aoe_kingdom
    local e_num = 0
    local aoe = self:getCard("SavageAssault")
    if aoe and self:getAoeValue(aoe) > 0 then
      for _, enemy in ipairs(self.enemies) do
        if self:aoeIsEffective(aoe, enemy, self.player) then
          local enemy_kingdom = enemy:getKingdom()
          if enemy_kingdom == "god" then
            enemy_kingdom = "careerist"
          end
          if kingdoms[enemy_kingdom] > e_num and double_first(enemy_kingdom) then
            max_aoe_kingdom = enemy_kingdom
            e_num = kingdoms[enemy_kingdom]
          end
        end
      end
    end
    if max_aoe_kingdom then
      self.xiongnve_choice = "adddamage"
      return double_first(max_aoe_kingdom)
    end
    aoe = self:getCard("ArcheryAttack")
    if aoe and self:getAoeValue(aoe) > 0 then
      for _, enemy in ipairs(self.enemies) do
        if self:aoeIsEffective(aoe, enemy, self.player) then
          local enemy_kingdom = enemy:getKingdom()
          if enemy_kingdom == "god" then
            enemy_kingdom = "careerist"
          end
          if kingdoms[enemy_kingdom] > e_num and double_first(enemy_kingdom) then
            max_aoe_kingdom = enemy_kingdom
            e_num = kingdoms[enemy_kingdom]
          end
        end
      end
    end
    if max_aoe_kingdom then
      self.xiongnve_choice = "adddamage"
      return double_first(max_aoe_kingdom)
    end
  end
  local burningcamps = self:getCard("BurningCamps")
	if burningcamps and burningcamps:isAvailable(self.player) then
    local np = self.player:getNextAlive()
    if #xiongnve_kingdom[np:getKingdom()] > 0 then
      local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
			self:useCardBurningCamps(burningcamps, dummyuse)
			if dummyuse.card then
				self.xiongnve_choice = "adddamage"
				return xiongnve_kingdom[np:getKingdom()][1]
			end
    end
  end
  local duel = self:getCard("Duel")
  if duel and duel:isAvailable(self.player) then
		local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
		self:useCardDuel(duel, dummyuse)
		if not dummyuse.to:isEmpty() then
			local duel_t = dummyuse.to:first()
			if duel_t:getHp() == 1 and self:isWeak(duel_t) and #xiongnve_kingdom[duel_t:getKingdom()] > 0 then
				self.xiongnve_choice = "adddamage"
				return #xiongnve_kingdom[duel_t:getKingdom()][1]
			end
		end
	end
  return generals[math.random(1,#generals)]
end

sgs.ai_skill_choice.xiongnve = function(self, choices, data)
  choices = choices:split("+")
--"adddamage+extraction+nolimit"
  if self.xiongnve_choice then
    return self.xiongnve_choice
  end
  return choices[1]
end

sgs.ai_skill_choice.xiongnve_defence = function(self, generals)
  generals = generals:split("+")
  local xiongnve_kingdom = {["wei"] = {}, ["shu"] = {}, ["wu"] = {}, ["qun"] = {}, ["careerist"] = {}, ["double"] = {}}
	for _, name in ipairs(generals) do
		local general = sgs.Sanguosha:getGeneral(name)
		if not general:isDoubleKingdoms() then
			table.insert(xiongnve_kingdom[general:getKingdom()],name)
		else
			table.insert(xiongnve_kingdom["double"],name)
		end
	end
  local kingdoms = {wei = 0, shu = 0, wu = 0, qun = 0, careerist = 0}--计算势力的人数，正是敌人，负是队友
  for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
    if p:hasShownOneGeneral() then--非暗将
      local p_kingdom = p:getKingdom()
      if p_kingdom == "god" then
        p_kingdom = "careerist"
      end
      kingdoms[p_kingdom] = kingdoms[p_kingdom] + (self:isFriend(p) and -1 or 1)
    end
  end
  for key, value in pairs(kingdoms) do
    if value == 0 and #xiongnve_kingdom[key] > 0 then
      return xiongnve_kingdom[key][1]
    end
  end
  for key, value in pairs(kingdoms) do
    if value > 0 and #xiongnve_kingdom[key] > math.min(value*2, 5) then
      return xiongnve_kingdom[key][1]
    end
  end
  for key, value in pairs(kingdoms) do
    if value < 0 and #xiongnve_kingdom[key] > 0 then
      return xiongnve_kingdom[key][1]
    end
  end
  local kingdom
  local vtable_num = 10
  for key, value in pairs(kingdoms) do
    if #xiongnve_kingdom[key] > 0 and math.abs(value) < vtable_num then
      vtable_num = math.abs(value)
      kingdom = key
    end
  end
  if kingdom then
    --global_room:writeToConsole("凶虐减伤选择:"..key)
    return xiongnve_kingdom[kingdom][1]
  end
  if #xiongnve_kingdom["double"] > 0 then
    for _, name in ipairs(xiongnve_kingdom["double"]) do
      local general = sgs.Sanguosha:getGeneral(name)
      local double_kingdoms = general:getKingdoms()
      if kingdoms[double_kingdoms[1]] == 0 and kingdoms[double_kingdoms[2]] == 0 then
        return name
      end
    end
    for _, name in ipairs(xiongnve_kingdom["double"]) do
      local general = sgs.Sanguosha:getGeneral(name)
      local double_kingdoms = general:getKingdoms()
      if kingdoms[double_kingdoms[1]] <= 0 and kingdoms[double_kingdoms[2]] <= 0 then
        return name
      end
    end
    return xiongnve_kingdom["double"][1]
  end

	return generals[math.random(1,#generals)]
end

function sgs.ai_cardneed.xiongnve(to, card, self)
	return card:isKindOf("Halberd")
end

--公孙渊
local huaiyi_skill = {
  name = "huaiyi",
  getTurnUseCard = function(self, inclusive)
      if self.player:hasUsed("HuaiyiCard") or self.player:isKongcheng() then
        return nil
      end
      if self.player:getPile("disloyalty"):length() == self.player:getMaxHp() then
        return nil
      end
      if self.player:getPile("disloyalty"):length() + 1 == self.player:getMaxHp() and math.random(1, 5) > 1 then
        return nil
      end
      local handcards = self.player:getHandcards()
      local red, black = false, false
      for _,c in sgs.qlist(handcards) do
          if c:isRed() and not red then
              red = true
              if black then
                break
              end
          elseif c:isBlack() and not black then
              black = true
              if red then
                break
              end
          end
      end
      if red and black then
        return sgs.Card_Parse("@HuaiyiCard=.&huaiyi")
      end
  end,
}
table.insert(sgs.ai_skills, huaiyi_skill)

sgs.ai_skill_use_func["HuaiyiCard"] = function(card, use, self)
  self.huaiyi_choice = nil
  local handcards = self.player:getHandcards()
  local reds, blacks = {}, {}
  local red_value, black_value = 0, 0
  for _,c in sgs.qlist(handcards) do
      local dummy_use = { isDummy = true }
      if c:isKindOf("Peach") then
        self:useBasicCard(c, dummy_use)
      elseif c:isKindOf("Snatch") then
          self:useTrickCard(c, dummy_use)
  --[[
      elseif c:isKindOf("EquipCard") and not self:getSameEquip(c) then
          self:useEquipCard(c, dummy_use)
      ]]
      end
      if dummy_use.card then
        return --It seems that self.player should use this card first.
      end
      if c:isRed() then
        red_value = red_value + self:getUseValue(c)
        table.insert(reds, c)
      else
        black_value = black_value + self:getUseValue(c)
        table.insert(blacks, c)
      end
  end

  local targets = self:findPlayerToDiscard("he", false, sgs.Card_MethodGet, nil, true)
  local n_reds, n_blacks, n_targets = #reds, #blacks, #targets
  if n_targets == 0 then
    return
  end
  if n_reds > n_targets and n_blacks > n_targets then
    local min_num = math.min(n_reds, n_blacks)
    if self:getOverflow() - min_num + n_targets < 0 then
      return
    end
  end

  if n_reds > n_targets and n_blacks > n_targets then
    self.huaiyi_choice = n_reds < n_blacks and "red" or "black"
  elseif n_reds > n_targets and math.abs(n_blacks - n_targets) < 2 then
    self.huaiyi_choice = "black"
  elseif n_blacks > n_targets and math.abs(n_reds - n_targets) < 2 then
    self.huaiyi_choice = "red"
  elseif self.player:getLostHp() < 2 then
    self.huaiyi_choice = n_reds > n_blacks and "red" or "black"
  else
    self.huaiyi_choice = red_value < black_value and "red" or "black"
  end
  use.card = card
end

sgs.ai_use_priority.HuaiyiCard = 4.2

sgs.ai_skill_choice["huaiyi"] = function(self, choices, data)
  if self.huaiyi_choice then
    return self.huaiyi_choice
  end
  choices = choices:split("+")
  return choices[math.random(1, #choices)]
end

sgs.ai_skill_playerchosen["huaiyi_snatch"] = function(self, targets, max_num, min_num)
  --global_room:writeToConsole("怀异最大目标:"..max_num)
  local result = {}
  local targetlist = sgs.QList2Table(targets)
	self:sort(targetlist, "handcard")
  --global_room:writeToConsole("怀异可选目标数:"..#targetlist)
	for _, target in ipairs(targetlist) do
		if self:isEnemy(target) and #result < max_num then
      table.insert(result, target)
      table.removeOne(targetlist, target)--防止重复
    end
	end
  for _, target in ipairs(targetlist) do
		if not self.player:isFriendWith(target) and #result < max_num then
      table.insert(result, target)
      table.removeOne(targetlist, target)
    end
	end
  global_room:writeToConsole("怀异预定目标数:"..#result)
  return result
end

sgs.ai_skill_cardchosen.huaiyi = function(self, who, flags)
  local flag_str
  if self.player:getPile("disloyalty"):length() + 1 == self.player:getMaxHp() then
    flag_str = "h"
  elseif self.player:getPile("disloyalty"):length() + 2 == self.player:getMaxHp() and math.random(1, 5) > 2  then
    flag_str = "h"
  elseif math.random(1, 5) > 4 then
    flag_str = "h"
  else
    flag_str = "he"
  end
  if flag_str == "he" then--藏君主装备
    for _, equip in sgs.qlist(who:getEquips()) do
      if equip:isKindOf("LuminousPearl") then
        local lord = self.room:getLord("wu")
        if lord and self:isEnemy(lord) then
          return equip:getEffectiveId()
        end
      elseif equip:isKindOf("DragonPhoenix") then
        local lord = self.room:getLord("shu")
        if lord and self:isEnemy(lord) then
          return equip:getEffectiveId()
        end
      elseif equip:isKindOf("PeaceSpell") then
        local lord = self.room:getLord("qun")
        if lord and self:isEnemy(lord) then
          return equip:getEffectiveId()
        end
      elseif equip:isKindOf("SixDragons") then
        local lord = self.room:getLord("wei")
        if lord and self:isEnemy(lord) then
          return equip:getEffectiveId()
        end
      end
    end
  end
	return self:askForCardChosen(who, flag_str, "huaiyi_snatch", sgs.Card_MethodGet)
end

sgs.ai_skill_invoke.zisui = true

--许攸
sgs.ai_skill_invoke.shicai = function(self, data)
  local damage = data:toDamage()
	return damage.damage < 2
end

sgs.ai_skill_invoke.chenglve = true

sgs.ai_skill_playerchosen.chenglve_mark = function(self, targets)
  local target_list = sgs.QList2Table(targets)
  self:sort(target_list, "hp")
	for _,p in ipairs(target_list) do
		if self:getOverflow(p) > 1 then
				return p
		end
	end
  self:sort(target_list, "handcard", true)
	return target_list[1]
end

--夏侯霸
sgs.ai_skill_invoke.baolie = function(self, data)
	if not self:willShowForAttack() then
    return false
  end
  --非常粗糙的条件？
	return self:getCardsNum("Slash") > 2 or self:getCardsNum("Jink") > 1
end

function sgs.ai_cardneed.baolie(to, card, self)
  if to:getHp() <= 2 then
    return card:isKindOf("Slash") or card:isKindOf("Analeptic") or to:hasWeapon("Spear")
  end
	return card:isKindOf("Halberd")--方天画戟
end

--潘濬
sgs.ai_skill_invoke.congcha = true

sgs.ai_skill_playerchosen.congcha = sgs.ai_skill_playerchosen.damage

sgs.ai_skill_invoke.gongqing = function(self, data)
  local damage = data:toDamage()
  if not damage.from or damage.from:getAttackRange() > 3 then
    return false
  end
  if damage.from:getAttackRange() < 3 and damage.damage > 1 then
    return true
  end
	return false
end

--文钦
local jinfa_skill = {}
jinfa_skill.name = "jinfa"
table.insert(sgs.ai_skills, jinfa_skill)
jinfa_skill.getTurnUseCard = function(self)
  if self.player:hasUsed("JinfaCard") then return end
  if self.player:isNude() then return end

  local equipcard
  if self:needToThrowArmor() then
		equipcard = self.player:getArmor()
  end
  if not equipcard and self.player:hasSkills(sgs.lose_equip_skill) and self.player:hasEquip() then
    local equip = self.player:getCards("e")
    equip = sgs.QList2Table(equip)
    self:sortByUseValue(equip, true)
    equipcard = equip[1]
  end
  if equipcard then
    return sgs.Card_Parse("@JinfaCard=" .. equipcard:getEffectiveId() .."&jinfa")
  end

  local cards = self.player:getCards("he")
  cards = sgs.QList2Table(cards)
  self:sortByUseValue(cards, true)
  return sgs.Card_Parse("@JinfaCard=" .. cards[1]:getEffectiveId() .."&jinfa")
end

sgs.ai_skill_use_func.JinfaCard = function(card, use, self)
  local target
  for _, friend in ipairs(self.friends_noself) do
    if self:needToThrowArmor(friend) then
      target = friend
    end
  end
  if not target then
    for _, friend in ipairs(self.friends_noself) do
      if friend:hasSkills(sgs.lose_equip_skill) and (friend:getWeapon() or friend:getOffensiveHorse()) and self:isWeak(friend) then
        target = friend
      end
    end
  end
  if not target then
    local targets = self:findPlayerToDiscard("he", false, sgs.Card_MethodGet, nil, true)
    self:sort(targets, "hp")
    for _, p in ipairs(targets) do
      if not self:isFriend(p) then
        target = p
        break
      end
    end
  end
	if target then
    use.card = card
		if use.to then
			use.to:append(target)
    end
  end
end

sgs.ai_use_priority.JinfaCard = 4.2--顺之后

sgs.ai_card_intention.JinfaCard = function(self, card, from, tos)
	local to = tos[1]
	if to:objectName() == from:objectName() then return end
	if self:isFriend(to) then
    sgs.updateIntention(from, to, -60)
	else
		sgs.updateIntention(from, to, 60)
	end
end

sgs.ai_skill_exchange["_jinfa"] = function(self,pattern,max_num,min_num,expand_pile)
  if self:getCardsNum("EquipCard") == 0 then
    return {}
  end
  local wenqin = sgs.findPlayerByShownSkillName("jinfa")
  if self:isFriend(wenqin) then
    return {}
  end
  local equipcard
  if self:needToThrowArmor() then
		equipcard = self.player:getArmor()
  end
  if not equipcard and self.player:hasSkills(sgs.lose_equip_skill) and self.player:hasEquip() then
    local equip = self.player:getCards("e")
    equip = sgs.QList2Table(equip)
    self:sortByUseValue(equip, true)
    equipcard = equip[1]
  end
  if not equipcard then
    local cards = self.player:getCards("he")-- 获得所有牌
    cards=sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards)
    if not self:isFriend(wenqin) then
      for _, c in ipairs(cards) do
        if c:isKindOf("EquipCard") and c:getSuit() == sgs.Card_Spade then
          equipcard = c
          break
        end
      end
    end
    if not equipcard and cards[1]:isKindOf("EquipCard") then
      equipcard = cards[1]
    end
  end
  if equipcard then
    return equipcard:getEffectiveId()
  end
  return {}
end

--彭羕
sgs.ai_skill_cardask["@daming"] = function(self, data, pattern, target, target2)
  local friend = self.room:getCurrent()
	local cards = self.player:getCards("h")
  cards=sgs.QList2Table(cards)
  self:sortByKeepValue(cards)
	for _,card in ipairs(cards) do
		if card:getTypeId() == sgs.Card_TypeTrick and
    ((not card:isKindOf("BefriendAttacking") and not card:isKindOf("AllianceFeast"))
      or self:isWeak(friend) or self.player:hasSkill("lirang")) then
			  return card:toString()
		end
	end
	return "."
end

--ai铁索连环是defence筛选，是否考虑尽可能多摸牌？
sgs.ai_skill_playerchosen["daming_chain"] = function(self, targets)
  local target_list = sgs.QList2Table(targets)
  self:sort(target_list, "hp")
	for _,p in ipairs(target_list) do
		if not self:isFriend(p) then
				return p
		end
	end
  target_list = sgs.reverse(target_list)
	return target_list[1]
end

sgs.ai_skill_choice.daming = function(self, choices, data)
  choices = choices:split("+")
  local friend = self.room:getCurrent()
  if friend:getHp() > 2 and table.contains(choices, "slash") then
    if table.contains(choices, "peach") then
      local target = sgs.ai_skill_playerchosen["daming_slash"](self, self.room:getOtherPlayers(self.player))
      local tslash = sgs.cloneCard("thunder_slash")
      if self:isFriend(target) or self:slashProhibit(tslash ,target) then--检测用杀是否合适
        return "peach"
      end
    end
    return "slash"
  end
  if table.contains(choices, "peach") then
    return "peach"
  end
  return choices[1]
end

sgs.ai_skill_playerchosen["daming_slash"] = function(self, targets)--复制的zero_card_as_slash，改为雷杀
  local tslash = sgs.cloneCard("thunder_slash")
  local targetlist = sgs.QList2Table(targets)
	local arrBestHp, canAvoidSlash, forbidden = {}, {}, {}
	self:sort(targetlist, "defenseSlash")

	for _, target in ipairs(targetlist) do
		if self:isEnemy(target) and not self:slashProhibit(tslash ,target) and sgs.isGoodTarget(target, targetlist, self) then
			if self:slashIsEffective(tslash, target) then
				if self:needDamagedEffects(target, self.player, true) or self:needLeiji(target, self.player) then
					table.insert(forbidden, target)
				elseif self:needToLoseHp(target, self.player, true, true) then
					table.insert(arrBestHp, target)
				else
					return target
				end
			else
				table.insert(canAvoidSlash, target)
			end
		end
	end
	for i=#targetlist, 1, -1 do
		local target = targetlist[i]
		if not self:slashProhibit(tslash, target) then
			if self:slashIsEffective(tslash, target) then
				if self:isFriend(target) and (self:needToLoseHp(target, self.player, true, true)
					or self:needDamagedEffects(target, self.player, true) or self:needLeiji(target, self.player)) then
						return target
				end
			else
				table.insert(canAvoidSlash, target)
			end
		end
	end

	if #canAvoidSlash > 0 then return canAvoidSlash[1] end
	if #arrBestHp > 0 then return arrBestHp[1] end

	targetlist = sgs.reverse(targetlist)
	for _, target in ipairs(targetlist) do
		if target:objectName() ~= self.player:objectName() and not self:isFriend(target) and not table.contains(forbidden, target) then
			return target
		end
	end

	return targetlist[1]
end

function sgs.ai_cardneed.daming(to, card, self)
	return card:getTypeId() == sgs.Card_TypeTrick and self:getUseValue(card) < sgs.ai_use_value.Peach
end

sgs.ai_skill_invoke.xiaoni = function(self, data)
	if not self:willShowForAttack() then
    return false
  end
  local use = data:toCardUse()
	return use.from:objectName() == self.player:objectName()
end

--苏飞
sgs.ai_skill_playerchosen.lianpian = function(self, targets)
  targets = sgs.QList2Table(targets)
  self:sort(targets, "handcard")
	return targets[1]
end

sgs.ai_skill_choice.lianpian = function(self, choices, data)
  local sufei = sgs.findPlayerByShownSkillName("lianpian")
  if self:isFriend(sufei) then
    return "recover"
  else
    return "discard"
  end
	return "cancel"
end

--诸葛恪
--[[
function sgs.ai_cardsview.aocai(self, class_name, player)
	if player:hasFlag("Global_AocaiFailed") or player:getPhase() ~= sgs.Player_NotActive then return end
--
  if not (pattern == "slash" or pattern == "jink" or pattern == "peach" or pattern:match("analeptic")) then
    return
  end

  if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
  or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
    local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
    local card = "@AocaiCard=.&aocai:" .. pattern
    --global_room:writeToConsole("傲才需求响应:" .. card)
    if class_name == "Slash" then
      global_room:writeToConsole("傲才需求响应:" .. card)
      return "@AocaiCard=.&aocai:slash"
    end
    if class_name == "Jink" then
      global_room:writeToConsole("傲才需求响应:" .. card)
      return "@AocaiCard=.&aocai:jink"
    end
	elseif (class_name == "Peach" and player:getMark("Global_PreventPeach") == 0) or class_name == "Analeptic" then
		local dying = self.room:getCurrentDyingPlayer()
		if dying and dying:objectName() == player:objectName() then
			local user_string = "peach+analeptic"
			if player:getMark("Global_PreventPeach") > 0 then
        user_string = "analeptic"
      end
			return "@AocaiCard=.&aocai:" .. user_string
		else
			local user_string
			if class_name == "Analeptic" then
        user_string = "analeptic"
      else
        user_string = "peach"
      end
			return "@AocaiCard=.&aocai:" .. user_string
		end
	end
end

sgs.ai_skill_cardask["@aocai-view"] = function(self, data, pattern, target, target2)
  global_room:writeToConsole("进入傲才:" .. self.player:objectName())
  if self.player:hasFlag("Global_AocaiFailed") or self.player:getPhase() ~= sgs.Player_NotActive then
    return "."
  end
  local aocai_id = self.player:property("aocai"):toString():split("+")
  if #aocai_id == 0 then
    return "."
  end
  --if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
  or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
    for _, id in ipairs(aocai_id) do
      if sgs.Sanguosha:getCard(id):objectName() ==  sgs.Sanguosha:getCurrentCardUsePattern()
      or sgs.Sanguosha:getCurrentCardUsePattern():match(sgs.Sanguosha:getCard(id):objectName()) then
        return "$" .. id
      end
    end
  end
	return "."--
  return "$" .. aocai_id[1]
end
]]

function sgs.ai_cardsview_value.aocai(self, class_name, player)
  if self.player:objectName() ~= player:objectName() or not player:hasSkill("aocai") then return end
	if player:hasFlag("Global_AocaiFailed") or player:getPhase() ~= sgs.Player_NotActive then return end
  if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
  or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
    if class_name == "Slash" or class_name == "Jink" then
      local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
      if pattern and pattern == "slash" or pattern == "jink" then
        local card = "@AocaiCard=.&aocai:" .. pattern
        global_room:writeToConsole("傲才响应:" .. card)
        return card
      end
    end
  end
	if class_name == "Peach" or class_name == "Analeptic" then
		local dying = self.room:getCurrentDyingPlayer()
        if dying and dying:objectName() == player:objectName() then
            return "@AocaiCard=.&aocai:peach+analeptic"
        else
            local user_string
            if class_name == "Analeptic" then user_string = "analeptic" else user_string = "peach" end
            return "@AocaiCard=.&aocai:" .. user_string
        end
	end
end

sgs.ai_use_priority.AocaiCard = 20

sgs.ai_skill_cardask["@aocai-view"] = function(self, data, pattern, target, target2)
	--global_room:writeToConsole("进入傲才:" .. self.player:objectName())
	if self.player:property("aocai"):toString() == "" then
		global_room:writeToConsole("傲才结果:.")
		return "."
	end
	local aocai_list = self.player:property("aocai"):toString():split("+")
	for _, id in ipairs(aocai_list) do
    local num_id = tonumber(id)
		global_room:writeToConsole("傲才结果:" .. num_id)
    return "$" .. num_id
  end
end

local duwu_skill = {}
duwu_skill.name = "duwu"
table.insert(sgs.ai_skills, duwu_skill)
duwu_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@duwu") < 1 then return end
  return sgs.Card_Parse("@DuwuCard=.&duwu")
end

sgs.ai_skill_use_func.DuwuCard= function(card, use, self)
  local num_nofriednwith, num_enermy = 0 ,0
  for _, p in sgs.qlist(self.room:getAlivePlayers()) do
    if self.player:inMyAttackRange(p) and self:damageIsEffective(p, nil, self.player) then
      if not self.player:isFriendWith(p) then
        num_nofriednwith = num_nofriednwith + 1
      end
      if not self:isFriend(p) then
        num_enermy = num_enermy + 1
      end
    end
  end
  if ((self.player:getWeapon() and sgs.weapon_range[self.player:getWeapon():getClassName()] > 2) or num_enermy > 2)
  and (self.player:getMark("Global_TurnCount") > 1 or string.find(sgs.gameProcess(), ">>>")) then--防止开局就使用
    use.card = card
  end
	if self.player:getHp() == 1 and num_nofriednwith > 1 then
    use.card = card
  end
end

sgs.ai_card_intention.DuwuCard = 80
sgs.ai_use_priority.DuwuCard= 3.6

sgs.ai_skill_choice["startcommand_duwu"] = function(self, choices)
  global_room:writeToConsole(choices)
  choices = choices:split("+")
  local commands = {"command2", "command3", "command4", "command1", "command6", "command5"}--索引大小代表优先级，注意不是原顺序
  local command_value1 = table.indexOf(commands,choices[1])
  local command_value2 = table.indexOf(commands,choices[2])
  local index = math.max(command_value1,command_value2)
  --global_room:writeToConsole("choice:".. choices[index])
  return commands[index]
end

sgs.ai_skill_choice["docommand_duwu"] = function(self, choices, data)
  local source = data:toPlayer()
  local index = self.player:getMark("command_index")
  local is_enemy = self:isEnemy(source)
  local is_friend = self:isFriend(source)

  if index == 1 then
    if not is_enemy and not is_friend then
      return "yes"
    end
    if is_friend and not self:isWeak() then
      for _, p in ipairs(self.enemies) do
        if self:isWeak(p) and self:isEnemy(source, p) then
          return "yes"
        end
      end
    end
    if is_enemy then
      for _, p in ipairs(self.friends) do
        if self:isWeak(p) and self:isEnemy(source, p) then
          return "no"
        end
      end
      return "yes"
    end
  end
  if index == 2 then
    return "yes"
  end
  if index == 3 and is_enemy then
    return "yes"
  end
  if index == 4 then
    if not is_friend and self:slashIsAvailable(source) then
      local has_peach = false
      for _, c in sgs.qlist(self.player:getHandcards()) do
        if c:isKindOf("Peach") and self.player:getMark("GlobalBattleRoyalMode") == 0 then--有实体卡桃可回血
          has_peach = true
        end
      end
      if has_peach then
        for _, p in ipairs(self.friends) do
          if p:getHp() == 1 and self:isWeak(p) and source:canSlash(self.player, nil, true) then
            return "no"
          end
        end
      end
    end
    return "yes"
  end
  if index == 5 and not self.player:faceUp() then
    return "yes"
  end
  if index == 6 and is_enemy and self.player:getEquips():length() < 3 and self.player:getHandcardNum() < 3 then
    return "yes"
  end
  return "no"
end

sgs.ai_skill_playerchosen["command_duwu"] = sgs.ai_skill_playerchosen.damage

function sgs.ai_cardneed.duwu(to, card, self)
	return card:isKindOf("Weapon") and sgs.weapon_range[card:getClassName()] >=3
end

--黄祖
sgs.ai_skill_cardask["@xishe-slash"] = function(self, data, pattern, target, target2)
  if not self.player:hasEquip() or not target or target:isDead() then
    return "."
  end
  if not self:slashIsEffective(sgs.cloneCard("slash"), target, self.player) then
		return "."
	end
  if not self:isFriend(target) then
    if self.player:hasSkill("kuangfu") and self.player:getHp() > target:getHp() and target:hasEquip() then--配合潘凤
      local card_id
      if self.player:getWeapon() and target:getWeapon() then
        card_id = self.player:getWeapon():getId()
      elseif self.player:getOffensiveHorse() and target:getOffensiveHorse() then
        card_id = self.player:getOffensiveHorse():getId()
      elseif self.player:getArmor() and target:getArmor() then
        card_id = self.player:getArmor():getId()
      elseif self.player:getDefensiveHorse() and target:getDefensiveHorse() then
        card_id = self.player:getDefensiveHorse():getId()
      elseif self.player:getTreasure() and target:getTreasure() then
        card_id = self.player:getTreasure():getEffectiveId()
      end
      if card_id then return "$" .. card_id end
    end
    if (self.player:getHp() > target:getHp() or self:isWeak()) and self:needToThrowArmor() then
      return "$" .. self.player:getArmor():getEffectiveId()
    end
    local equipcards = self.player:getCards("e")
    equipcards = sgs.QList2Table(equipcards)
    if (target:getHp() == 1 and self:isWeak(target)) or (self.player:getHp() > target:getHp() and (target:getHp() < 3 or self:getCardsNum("EquipCard") > 2)) then
      if self:needToThrowArmor() then
        return "$" .. self.player:getArmor():getEffectiveId()
      end
      self:sortByKeepValue(equipcards)
      return "$" .. equipcards[1]:getEffectiveId()
    end
  end
	return "."
end

sgs.ai_skill_choice["transform_xishe"] = function(self, choices)
	global_room:writeToConsole("袭射变更选择")
	local importantsklii = {"congjian", "jijiu", "qianhuan", "yigui", "shicai", "jinghe"}--还有哪些？
	local skills = sgs.QList2Table(self.player:getDeputySkillList(true,true,false))
	for _, skill in ipairs(skills) do
		if table.contains(importantsklii, skill:objectName()) then--重要技能
			return "no"
		end
		if skill:getFrequency() == sgs.Skill_Limited and not (skill:getLimitMark() ~= "" and self.player:getMark(skill:getLimitMark()) == 0) then--限定技未发动
			return "no"
		end
	end
  --[[
	choices = choices:split("+")
	return choices[math.random(1,#choices)]
  ]]
  return "yes"
end

sgs.ai_cardneed.xishe = sgs.ai_cardneed.equip

--刘巴
sgs.ai_skill_invoke.tongdu = true

sgs.ai_skill_choice.tongdu = "yes"

local qingyin_skill = {}
qingyin_skill.name = "qingyin"
table.insert(sgs.ai_skills, qingyin_skill)
qingyin_skill.getTurnUseCard = function(self)
	if self.player:getMark("@qingyin") < 1 then return end
  --global_room:writeToConsole("进入刘巴技能:" .. self.player:objectName())
  local count = 0
	for _, friend in ipairs(self.friends) do
		if self.player:isFriendWith(friend) and (friend:getHp() <= 1 or (friend:getHp() <= 2 and friend:getHandcardNum() < 2) or friend:getLostHp() > 2) then
      count = count + 1
		end
	end
  --global_room:writeToConsole("计数:"..count)
  if count > 1 or (self.player:getHp() == 1 and self:isWeak() and self:getAllPeachNum() < 1) then
  	return sgs.Card_Parse("@QingyinCard=.&qingyin")
  end
end

sgs.ai_skill_use_func.QingyinCard = function(card, use, self)
  --global_room:writeToConsole("使用刘巴技能")
	use.card = card
end

sgs.ai_card_intention.QingyinCard = -80
sgs.ai_use_priority.QingyinCard = 1--桃之前

--朱灵
sgs.ai_skill_invoke.juejue = function(self, data)--暂不考虑紫砂
	if not self:willShowForAttack() then
    return false
  end
  local friend_weak = 0
  local enemy_weak = 0
  for _, p in sgs.qlist(self.room:getAlivePlayers()) do
    if self:isFriend(p) and self:isWeak(p) then
      friend_weak = friend_weak + 1
    end
    if not self:isFriend(p) and self:isWeak(p) then
      enemy_weak = enemy_weak + 1
    end
  end
  if self:getOverflow() > (self.player:getMark("@halfmaxhp") < 1 and 1 or 3) and self.player:getHp() > 1 then
    if enemy_weak > 2 or enemy_weak > friend_weak  then
      return true
    end
    if (self.player:getHp() > 2 or self.player:hasSkill("wangxi")) and self:getCardsNum("Peach") > 0 and (#self.enemies > 2 or #self.enemies > #self.friends) then
      return true
    end
  end
	return false
end

sgs.ai_skill_cardask["@juejue-discard"] = function(self, data, pattern, target, target2)
  local dis_num = self.player:getMark("juejue_discard_count")
	if self.player:getHandcardNum() < dis_num then--缺手牌
    return "."
  end
  local current = self.room:getCurrent()--万一绝决过程中朱灵死了，是否会空值？
  if not self:damageIsEffective(self.player, nil, current) or self:needDamagedEffects(self.player, current) or self:needToLoseHp(self.player, current) then
    return "."
  end
  if self.player:getHp() > 2 or self:getCardsNum("Peach") > 0
  or (self.player:getHp() == 1 and self:getCardsNum("Analeptic") > 0)
  or (dis_num > 3 and not self:isWeak()) then
    return "."
  end
  local cards = self.player:getHandcards() -- 获得所有手牌
  cards=sgs.QList2Table(cards) -- 将列表转换为表
  local discards = {}
  self:sortByKeepValue(cards) -- 按保留值排序
  for _, c in ipairs(cards) do
    table.insert(discards, c:getId())
    if #discards == dis_num then
      return "$" .. table.concat(discards, "+")
    end
  end
  return "."
end

sgs.ai_skill_invoke.fangyuan = true

sgs.ai_skill_playerchosen["_fangyuan"] = function(self, targets)
  if self:isFriend(targets:first()) then
    return {}
  end
  return sgs.ai_skill_playerchosen.zero_card_as_slash(self, targets)
end