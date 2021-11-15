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
--崔毛
sgs.ai_skill_use["@@zhengbi"] = function(self, prompt, method)
  if self.player:isKongcheng() then
    return "."
  end
  for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not self:isFriend(p) and not p:hasShownOneGeneral() then
			if self:getCardsNum("Slash") > 1 and (p:getHp() < 3 or self:getCardsNum("Halberd") > 0) then
        return "@ZhengbiCard=".. "->" .. p:objectName()
      end
		end
	end
  local handcards = self.player:getCards("h")
	handcards = sgs.QList2Table(handcards)
	self:sortByUseValue(handcards,true)
	local card
  local visibleflag--记录给出的手牌，盗书等技能需要
  for _, c in ipairs(handcards) do
    if c:getTypeId() == sgs.Card_TypeBasic then
      card = c
      break
    end
  end
  if not card then
    return "."
  end
  if card:isKindOf("Peach") then
    if self:getCardsNum("Peach") <= self.player:getLostHp()  then
      return "."
    end
    self:sort(self.friends_noself, "hp")
    for _, friend in ipairs(self.friends_noself) do
      if friend:getCardCount(true) > 1 and (friend:isWounded() or self:getOverflow() > 0) and friend:hasShownOneGeneral() then
        visibleflag = string.format("%s_%s_%s", "visible", self.player:objectName(), friend:objectName())
        if not card:hasFlag("visible") then card:setFlags(visibleflag) end
        return "@ZhengbiCard=" .. card:getEffectiveId() .. "->" .. friend:objectName()
      end
    end
    return "."
  end
	self:sort(self.enemies, "handcard")
  for _, target in ipairs(self.enemies) do
    if not target:isKongcheng() and (target:getHandcardNum() < 3 or self:isWeak(target)) and target:hasShownOneGeneral() then
      if not (card:isKindOf("Analeptic") and target:hasEquip() and self:isWeak(target)) then
        visibleflag = string.format("%s_%s_%s", "visible", self.player:objectName(), target:objectName())
        if not card:hasFlag("visible") then card:setFlags(visibleflag) end
        return "@ZhengbiCard=" .. card:getEffectiveId() .. "->" .. target:objectName()
      end
    end
  end
  return "."
end

sgs.ai_skill_cardask["@zhengbi-give"] = function(self, data, pattern, target, target2)
  if not target or target:isDead() then return "." end
--[[保留值的函数应该能覆盖以下情况
  if self:needToThrowArmor() then
		return "$" .. self.player:getArmor():getEffectiveId()
  end
  if self.player:hasSkills(sgs.lose_equip_skill) and self.player:hasEquip() then
    local equip = self.player:getCards("e")
    equip = sgs.QList2Table(equip)
    self:sortByUseValue(equip, true)
    return "$" .. equip[1]:getEffectiveId()
  end
]]
  local allcards = self.player:getCards("he")
	allcards = sgs.QList2Table(allcards)
	self:sortByKeepValue(allcards)
  local visibleflag = string.format("%s_%s_%s", "visible", self.player:objectName(), target:objectName())--标记可见
  if #allcards == 1 then
    if not allcards[1]:hasFlag("visible") then allcards[1]:setFlags(visibleflag) end
    return "$" .. allcards[1]:getEffectiveId()
  end
  if allcards[1]:getTypeId() ~= sgs.Card_TypeBasic then
    if not allcards[1]:hasFlag("visible") then allcards[1]:setFlags(visibleflag) end
    return "$" .. allcards[1]:getEffectiveId()
  elseif allcards[2]:getTypeId() ~= sgs.Card_TypeBasic then
    if not allcards[2]:hasFlag("visible") then allcards[2]:setFlags(visibleflag) end
    return "$" .. allcards[2]:getEffectiveId()
  else
    local give_cards = {}
    table.insert(give_cards, allcards[1]:getId())
    table.insert(give_cards, allcards[2]:getId())
    if not allcards[1]:hasFlag("visible") then allcards[1]:setFlags(visibleflag) end
    if not allcards[2]:hasFlag("visible") then allcards[2]:setFlags(visibleflag) end
    return "$" .. table.concat(give_cards, "+")
  end
end

local fengying_skill = {}
fengying_skill.name = "fengying"
table.insert(sgs.ai_skills, fengying_skill)
fengying_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@honor") < 1 or self.player:isKongcheng() then return end
  return sgs.Card_Parse("@FengyingCard=.&")
end

sgs.ai_skill_use_func.FengyingCard = function(card, use, self)
  if self:getCardsNum("ThreatenEmperor") > 0 then
    local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
		self:useCardThreatenEmperor(sgs.cloneCard("threaten_emperor"), dummyuse)
		if dummyuse.card then--如果有挟天子且可以使用
      return
    end
  end
  local draw_count = 0
  for _, p in ipairs(self.friends) do
    if self.player:isFriendWith(p) then
      draw_count = draw_count + p:getMaxHp() - p:getHandcardNum()
    end
  end
  if draw_count > 3 or self.player:getHp() == 1 then
    if self.player:getHandcardNum() == 1 then
      sgs.ai_use_priority.FengyingCard = 2
    end
    use.card = card--不弃牌使用挟天子更优的情况估计得在挟天子弃牌的ai里写，需要data判定card:getSkillName()才行
  end
end

sgs.ai_card_intention.FengyingCard = -80
sgs.ai_use_priority.FengyingCard = 0

--于禁
sgs.ai_skill_use["@@jieyue"] = function(self, prompt, method)
  if self.player:isKongcheng() or
  (self:willSkipDrawPhase() and not(self.player:hasSkill("qiaobian") and self.player:getHandcardNum() == 1)) then
    return "."
  end
	local handcards = self.player:getCards("h")
	handcards = sgs.QList2Table(handcards)
	self:sortByUseValue(handcards,true)
	local card = handcards[1]
  local visibleflag--记录给出的手牌，盗书等技能需要
  if card:isKindOf("Peach") and self:isWeak() then
    return "."
  end
  local targets = {}
  for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if p:getSeemingKingdom() ~= "wei" then
			table.insert(targets, p)
		end
	end
  if #targets == 0 then
    return "."
  end
  self:sort(targets, "handcard")
  for _, p in ipairs(targets) do
    if self:isFriend(p) then
      visibleflag = string.format("%s_%s_%s", "visible", self.player:objectName(), p:objectName())
      if not card:hasFlag("visible") then card:setFlags(visibleflag) end
        return "@JieyueCard=" .. card:getEffectiveId() .. "->" .. p:objectName()
    end
  end
  if card:isKindOf("Peach") then
    return "."
  end
	self:sort(targets, "defense", true)
  for _, p in ipairs(targets) do
    if not self:isFriend(p) then
      visibleflag = string.format("%s_%s_%s", "visible", self.player:objectName(), p:objectName())
      if not card:hasFlag("visible") then card:setFlags(visibleflag) end
      return "@JieyueCard=" .. card:getEffectiveId() .. "->" .. p:objectName()
    end
  end
  return "."
end

sgs.ai_skill_choice["startcommand_jieyue"] = function(self, choices)
  self.player:speak(choices)
  choices = choices:split("+")
  local commands = {"command1", "command2", "command4", "command3", "command6", "command5"}--索引大小代表优先级，注意不是原顺序
  local command_value1 = table.indexOf(commands,choices[1])
  local command_value2 = table.indexOf(commands,choices[2])
  local index = math.max(command_value1,command_value2)--需要一些额外的标记？
  --global_room:writeToConsole("choice:".. choices[index])
  return commands[index]
end

sgs.ai_skill_choice["docommand_jieyue"] = function(self, choices, data)
  --target->setFlags("JieyueTarget");有标记可使用
  --[[if index <= 4 then
    return "yes"
  end
  if index == 5 then
    if self.player:getCards("he"):length() < 4 then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getCards("he"):length() < 6 then
      return "yes"
    else
      return "no"
    end
  end
  if index == 6 then
    if not self.player:faceUp() then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getHandcardNum() < 3
    and math.random(1, 100) / 100 >= 50  then
      return "yes"
    else
      return "no"
    end
  end]]--
  return "no"
end


--王平
local jianglve_skill = {}
jianglve_skill.name = "jianglve"
table.insert(sgs.ai_skills, jianglve_skill)
jianglve_skill.getTurnUseCard = function(self, inclusive)
	if self.player:getMark("@strategy") < 1 then return end
  return sgs.Card_Parse("@JianglveCard=.&jianglve")
end

sgs.ai_skill_use_func.JianglveCard= function(card, use, self)
	use.card = card
end

sgs.ai_card_intention.JianglveCard = -120
sgs.ai_use_priority.JianglveCard = 9.15

--[[
  ["#command1"] = "军令一：对你指定的角色造成1点伤害",
	["#command2"] = "军令二：摸一张牌，然后交给你两张牌",
	["#command3"] = "军令三：失去1点体力",
	["#command4"] = "军令四：本回合不能使用或打出手牌且所有非锁定技失效",
	["#command5"] = "军令五：叠置，本回合不能回复体力",
	["#command6"] = "军令六：选择一张手牌和一张装备区里的牌，弃置其余的牌",
  ]]--

sgs.ai_skill_choice["startcommand_jianglve"] = function(self, choices)
  self.player:speak(choices)
  choices = choices:split("+")
  local commands = {"command1", "command2", "command4", "command3", "command6", "command5"}--索引大小代表优先级，注意不是原顺序
  local command_value1 = table.indexOf(commands,choices[1])
  local command_value2 = table.indexOf(commands,choices[2])
  local index = math.min(command_value1,command_value2)--需要一些额外的标记？
  --global_room:writeToConsole("choice:".. choices[index])
  return commands[index]
end

sgs.ai_skill_choice["docommand_jianglve"] = function(self, choices)
  return "yes"
end

sgs.ai_skill_playerchosen["command_jianglve"] = sgs.ai_skill_playerchosen.damage
--军令弃牌给牌需要每个军令分开写


sgs.ai_skill_choice["jianglve"] = function(self, choices, data)--ai势力召唤
  choices = choices:split("+")
  if table.contains(choices,"show_head_general") and self.player:inHeadSkills("rende")--君主替换
    and sgs.GetConfig("EnableLordConvertion", true) and self.player:getMark("Global_RoundCount") <= 1  then
    return "show_deputy_general"
  end
  if table.contains(choices,"show_both_generals") then
    local wuhu_show_head, wuhu_show_deputy = false,false
    local xuanhuo_priority = {"paoxiao", "tieqi", "kuanggu", "liegong", "wusheng", "longdan"}
    for _, skill in ipairs(xuanhuo_priority) do--有顺序优先度
      if self.player:hasSkill(skill) then
        if self.player:inHeadSkills(skill) then
          wuhu_show_deputy = true
          break
        else
          wuhu_show_head = true
          break
        end
      end
    end
    if wuhu_show_deputy then
      return "show_deputy_general"
    end
    if wuhu_show_head then
      return "show_head_general"
    end
    return "show_both_generals"
  end
  if table.contains(choices,"show_deputy_general") then
    return "show_deputy_general"
  end
  if table.contains(choices,"show_head_general") then
    return "show_head_general"
  end
  return choices[1]--不亮将的可以加上敌友标记？王平回合开始明置？
end

--法正
sgs.ai_skill_invoke.enyuan = function(self, data)
  return true
end

sgs.ai_skill_exchange["_enyuan"] = function(self,pattern,max_num,min_num,expand_pile)
  if self.player:isKongcheng() then
    return {}
  end
  if self.player:hasSkill("hongfa") and not self.player:getPile("heavenly_army"):isEmpty() then--君张角
    return {}
  end
  local cards = self.player:getHandcards() -- 获得所有手牌
  cards=sgs.QList2Table(cards) -- 将列表转换为表
  self:sortByUseValue(cards, true) -- 按使用价值从小到大排序
  if cards[1]:isKindOf("Peach") then
    local fazheng = sgs.findPlayerByShownSkillName("enyuan")
    if self:isFriend(fazheng) then
      return {cards[1]:getId()}
    end
    --[[local kingdom = self.player:getKingdom()
    if kingdom == "shu" then
      return {cards[1]:getId()}
    end]]--
    return {}
  end
  return {cards[1]:getId()}
end

--从sgs.ai_skill_use.slash里复制的杀目标选择，似乎可以直接用SmartAI:useCardSlash的结果
local function getSlashtarget(self)
  local max_range = 0
  local horse_range = 0
  local current_range = self.player:getAttackRange()
  for _,card in sgs.qlist(self.player:getCards("he")) do
    if card:isKindOf("Weapon") and max_range < sgs.weapon_range[card:getClassName()] then
      max_range = sgs.weapon_range[card:getClassName()]--或许应该考虑最合适的那把武器距离，先去掉防止丢失目标
    end
  end
  if self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse() then
    horse_range = 1
  end
  --注意正负，距离增大是负修正 math.min(current_range - max_range, 0) self.player:canSlash(enemy, slash, true, range_fix)
  local range_fix = -horse_range
  if self:getCardsNum("Slash") == 0 then--想选武圣龙胆怎么办？
    self.room:writeToConsole("getSlashtarget:无杀")
    return nil end
	local slashes = self:getCards("Slash")
	self:sortByUseValue(slashes)
	self:sort(self.enemies, "defenseSlash")
	for _, slash in ipairs(slashes) do
		for _, enemy in ipairs(self.enemies) do
			if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(slash, enemy)
				and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
				and not (self.player:hasFlag("slashTargetFix") and not enemy:hasFlag("SlashAssignee")) then
				return enemy
			end
		end
	end
  self.need_liegong_distance = false
  local liubei = self.room:getLord(self.player:getKingdom())
  if liubei and liubei:hasLordSkill("shouyue") then
    local can_chooseliegong  = true
    for _, p in sgs.qlist(self.room:getAlivePlayers()) do
      if p:hasSkill("liegong") then
        can_chooseliegong = false
      end
    end
    if can_chooseliegong then
      for _, slash in ipairs(slashes) do--距离再修正1寻找敌人 self.player:canSlash(enemy_1, slash, true, range_fix-1)
        for _, enemy_1 in ipairs(self.enemies) do
          if self.player:canSlash(enemy_1, slash, true, -1) and not self:slashProhibit(slash, enemy_1)
            and self:slashIsEffective(slash, enemy_1) and sgs.isGoodTarget(enemy_1, self.enemies, self)
            and not (self.player:hasFlag("slashTargetFix") and not enemy_1:hasFlag("SlashAssignee")) then
              self.need_liegong_distance = true
            return enemy_1
          end
        end
      end
    end
  end
  self.room:writeToConsole("getSlashtarget:无目标")
  return nil
end

--是否发动眩惑，顺带小判定。可能得判断技能选择，再判断是否发动才不会有bug
local function shouldUseXuanhuo(self)
  local xuanhuoskill = {"wusheng", "paoxiao", "longdan", "tieqi", "liegong", "kuanggu"}
  for _, p in sgs.qlist(self.room:getAlivePlayers()) do
    for _, skill in ipairs(xuanhuoskill) do
      if p:hasSkill(skill) then
        table.removeOne(xuanhuoskill,skill)
      end
    end
  end
  if #xuanhuoskill == 0 then--不太常见的没有技能可选
    return false
  end
  local xuanhuochoices = table.concat(xuanhuoskill,"+")
  local choice = sgs.ai_skill_choice.xuanhuo(self, xuanhuochoices)
  self.room:writeToConsole("---眩惑预选技能:"..sgs.Sanguosha:translate(choice).."---")

  --如何去除没有连弩或咆哮却选武圣，牌少又断杀等情况
  if choice ~= "paoxiao" and not self:slashIsAvailable() and self:getOverflow() < 1 then
    return false
  end

  if self:getCardsNum("Slash") == 0 then
    if (choice == "wusheng" or choice == "longdan") and self:getOverflow() > 1 then
      self.need_xuanhuo_slash = true
      return true
    else
      self.room:writeToConsole(self.player:objectName()..":眩惑无转换杀技能")
      return false
    end
  end

  if self:getCardsNum("Slash") == 1 and (choice == "wusheng" or choice == "longdan") then
    self.room:writeToConsole(self.player:objectName()..":眩惑无进攻技能")
    return false
  end

  self.need_kuanggu_AOE = false
  --[[
  if not self.player:hasSkill("kuanggu") and table.contains(xuanhuoskill,"kuanggu") and self:getCardsNum("Slash") < 2 and
  (self:getCardsNum("SavageAssault") + self:getCardsNum("ArcheryAttack") > 0) and
  (self.player:getOffensiveHorse() or self.player:hasShownSkills("mashu_machao|mashu_madai")
  or self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse()) then
    self.need_kuanggu_AOE = true
    self.player:speak("需要眩惑狂骨AOE")
    self.room:writeToConsole(self.player:objectName()..":眩惑狂骨AOE")
    return true
  end]]

  local target = getSlashtarget(self)
  if not self.player:hasSkill("liegong") and table.contains(xuanhuoskill,"liegong") and self.need_liegong_distance then
    local liubei = self.room:getLord(self.player:getKingdom())
    if liubei and liubei:hasLordSkill("shouyue") then
      self.player:speak("需要眩惑君刘备烈弓距离")
      self.room:writeToConsole(self.player:objectName()..":眩惑君刘备烈弓距离")
      return true
    else
      self.need_liegong_distance = false
    end
  end

  if not target then--无杀目标或无杀
    self.room:writeToConsole(self.player:objectName()..":眩惑无杀目标")
    return false
  end
  assert(target)

  if self.player:hasSkills("tieqi|liegong|qianxi")
  and (choice == "liegong" or (choice == "tieqi" and not target:hasShownSkill("tianxiang"))) then
    return false
  end

  if self.player:getMark("@strategy") >= 1 or self.player:getHandcardNum() > 4
   or (self.player:getHandcardNum() > 3 and self.player:getCards("e"):length() > 0) then--多余手牌需要弃置时？
    self.room:writeToConsole(self.player:objectName()..":眩惑符合条件")
    return true
  end
  return false
end

--真君主技眩惑
local xuanhuoattach_skill = {}
xuanhuoattach_skill.name = "xuanhuoattach"
table.insert(sgs.ai_skills, xuanhuoattach_skill)
xuanhuoattach_skill.getTurnUseCard = function(self, inclusive)
  if self.player:getHandcardNum() < 2 then return end--牌不足
  if not self.player:hasUsed("XuanhuoAttachCard") and shouldUseXuanhuo(self) then
    local cards = self.player:getHandcards()
	  cards = sgs.QList2Table(cards)
	  self:sortByUseValue(cards, true) -- 按使用价值从小到大排序
    --global_room:writeToConsole("眩惑技能卡:" ..self.player:objectName())
		return sgs.Card_Parse("@XuanhuoAttachCard=" .. cards[2]:getEffectiveId())--给牌弃牌可能把武器或杀给了，导致第二次丢失目标
	end
end

sgs.ai_skill_use_func.XuanhuoAttachCard= function(card, use, self)
  sgs.ai_use_priority.XuanhuoAttachCard = 5
  --self.room:writeToConsole("发动眩惑:"..self.player:objectName())
  --sgs.debugFunc(self.player, 2)
  self.player:speak("发动眩惑")
  if self.player:getMark("@strategy") >= 1 then--在王平限定技发动前
    sgs.ai_use_priority.XuanhuoAttachCard = sgs.ai_use_priority.JianglveCard + 0.1
  end
  if self.player:hasSkill("jizhi") then--使用锦囊后
    sgs.ai_use_priority.XuanhuoAttachCard = 2.8
  end
    if self.need_kuanggu_AOE then--使用AOE前
    sgs.ai_use_priority.XuanhuoAttachCard = 3.6
  end
  if self.player:hasSkill("jili") then--使用完武器后
    sgs.ai_use_priority.XuanhuoAttachCard = 6
  end
  for _, p in ipairs(self.friends) do
    if p:hasShownSkill("yongjue") and self.player:isFriendWith(p) then
      sgs.ai_use_priority.XuanhuoAttachCard = 9.6--勇决杀的优先调整到9.5
    end
  end
  if self.player:getActualGeneral1():getKingdom() == "careerist" then
    sgs.ai_use_priority.XuanhuoAttachCard = 20--野心家
  end
	use.card = card
end

sgs.ai_card_intention.XuanhuoAttachCard = -90

sgs.ai_skill_discard["xuanhuo_discard"] = function(self, discard_num, min_num, optional, include_equip)
	if self.player:getHandcardNum() < 2 then
		return {}
	else
    local cards = self.player:getCards("he")
	  cards = sgs.QList2Table(cards)
	  self:sortByUseValue(cards, true) -- 按使用价值从小到大排序
		return {cards[1]:getEffectiveId()}
	end
	return {}
end

sgs.ai_skill_choice.xuanhuo = function(self, choices)
  choices = choices:split("+")
  local xuanhuoskill = {"wusheng", "paoxiao", "longdan", "tieqi", "liegong", "kuanggu"}
  local has_wusheng = self.player:hasSkill("wusheng")
  local has_paoxiao = self.player:hasSkill("paoxiao")
  local has_longdan = self.player:hasSkill("longdan")
  local has_tieqi = self.player:hasSkill("tieqi")
  local has_liegong = self.player:hasSkill("liegong")
  local has_kuanggu = self.player:hasSkill("kuanggu")
  local has_qianxi = self.player:hasSkill("qianxi")
  local has_Crossbow = self:getCardsNum("Crossbow") > 0
  local has_baolie = self.player:hasSkill("baolie") and self.player:getHp() < 3--夏侯霸新技能豹烈

  local enough_pxslash = false
  if self:getCardsNum("Slash") > 0 then
    local yongjue_slash = 0
    for _, p in ipairs(self.friends) do
      if p:hasShownSkill("yongjue") and self.player:isFriendWith(p) and self.player:getSlashCount() == 0 then
        yongjue_slash = 1--考虑没出牌时？有一张杀
        break
      end
    end
    if yongjue_slash + self.player:getSlashCount() + self:getCardsNum("Slash") >= 2 then--getCardsNum包含转化的杀
      enough_pxslash = true
    end
  end

--集中判断保证自己没有相应的技能和选项里有技能，避免每次都重复判断
  local can_paoxiao = false
  local can_wusheng = false
  local need_tieqi = false
  local can_tieqi = false
  local can_liegong = false
  local can_kuanggu = false
  local lord_longdan = false
  local can_longdan = false

  if self.need_liegong_distance then--需要眩惑君刘备烈弓距离
    self.need_liegong_distance = nil
    return "liegong"
  end
  if self.need_kuanggu_AOE then--需要眩惑狂骨AOE
    self.need_kuanggu_AOE = nil
    return "kuanggu"
  end

  if not has_longdan and table.contains(choices,"longdan") and self:getCardsNum("Jink") >= 1 then--龙胆可以杀队友进行回复或伤害，不需要target，虽然ai目前不会
    self.room:writeToConsole(self.player:objectName()..":眩惑可龙胆")
    can_longdan = true
  end

  --Func(self.player, 2)
  local target = getSlashtarget(self)--中间给牌弃牌，可能失去武器或杀导致无返回目标。好像还有目标找错的情况？
  if not target then
    self.room:writeToConsole(self.player:objectName()..":！！眩惑选择无杀目标或无杀！！")
    --assert(target)
    goto Pass_target--暂时无杀目标或无杀跳转至目标判定后，需要优化眩惑触发判断和弃牌给牌
  end
  global_room:writeToConsole("眩惑杀目标:"..sgs.Sanguosha:translate(target:getGeneralName()).."/"..sgs.Sanguosha:translate(target:getGeneral2Name()))

  if not has_Crossbow and not has_paoxiao and not has_baolie and table.contains(choices,"paoxiao") and enough_pxslash then
    self.room:writeToConsole(self.player:objectName()..":眩惑可咆哮")
    can_paoxiao = true
  end
  if not has_wusheng and table.contains(choices,"wusheng") then
    self.room:writeToConsole(self.player:objectName()..":眩惑可武圣")
    can_wusheng = true
  end
  if not has_tieqi and table.contains(choices,"tieqi") then
    local skills_name = (sgs.masochism_skill .. "|" .. sgs.save_skill .. "|" .. sgs.defense_skill .. "|" .. sgs.wizard_skill):split("|")
	  for _, skill_name in ipairs(skills_name) do
		  local skill = sgs.Sanguosha:getSkill(skill_name)
		  if target:hasShownSkill(skill_name) and skill and skill:getFrequency() ~= sgs.Skill_Compulsory then
        self.room:writeToConsole(self.player:objectName()..":眩惑需要铁骑")
        need_tieqi = true--有需要铁骑的技能
        break
      end
	  end
  end
  if not has_tieqi and table.contains(choices,"tieqi") then
    self.room:writeToConsole(self.player:objectName()..":眩惑可铁骑")
    can_tieqi = true
  end
  if not has_liegong and table.contains(choices,"liegong") and (target:getHandcardNum() >= self.player:getHp() or target:getHandcardNum() <= self.player:getAttackRange()) then
    self.room:writeToConsole(self.player:objectName()..":眩惑可烈弓")
    can_liegong = true--符合烈弓发动条件
  end
  if not has_kuanggu and table.contains(choices,"kuanggu") and (self.player:hasShownSkills("mashu_machao|mashu_madai") or self.player:distanceTo(target) < 2
  or (self.player:distanceTo(target) == 2 and self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse())) then
    self.room:writeToConsole(self.player:objectName()..":眩惑可狂骨")
    can_kuanggu = true--有马术或-1马或距离为1
  end
  if not has_longdan and table.contains(choices,"longdan") and self:getCardsNum("Jink") >= 1 then
    local liubei = self.room:getLord(self.player:getKingdom())
    if liubei and liubei:hasLordSkill("shouyue") then
      self.room:writeToConsole(self.player:objectName()..":眩惑君龙胆")
      lord_longdan = true--有君刘备
    end
  end

  if self.need_xuanhuo_slash then--需要眩惑转化杀
    self.need_xuanhuo_slash = nil
    if lord_longdan or can_longdan then
      return "longdan"
    end
    if can_wusheng then
      return "wusheng"
    end
  end

  --已有双技能的情况
  if has_kuanggu and (has_tieqi or has_liegong or has_qianxi) then--魏延和马超兄弟/黄忠
    if has_Crossbow then
      if can_wusheng then
        return "wusheng"
      elseif can_longdan then
        return "longdan"
      end
    elseif can_paoxiao then
      return "paoxiao"
    end
  end
  if (has_wusheng or has_longdan) and (has_paoxiao or has_Crossbow or has_baolie) then--关张和赵张
    if can_kuanggu then
      return "kuanggu"
    elseif need_tieqi then
      return "tieqi"
    elseif can_liegong then
      return "liegong"
    end
  end
  if has_kuanggu and (has_paoxiao or has_baolie) then--魏延和张飞
    if can_wusheng then
      return "wusheng"
    elseif lord_longdan then
      return "longdan"
    elseif need_tieqi then
      return "tieqi"
    elseif can_liegong then
      return "liegong"
    end
  end
  if (has_paoxiao or has_Crossbow or has_baolie) and (has_tieqi or has_liegong or has_qianxi) then--张飞/夏侯霸和马超兄弟/黄忠
    if can_kuanggu then
      return "kuanggu"
    elseif can_wusheng then
      return "wusheng"
    elseif can_longdan then
      return "longdan"
    end
  end
  if (has_wusheng or has_longdan) and (has_tieqi or has_liegong or has_qianxi) then--关/赵和马超兄弟/黄忠
    if has_Crossbow and can_kuanggu then
      return "kuanggu"
    elseif can_paoxiao then
      return "paoxiao"
    elseif can_kuanggu then
      return "kuanggu"
    end
  end
  if (has_wusheng or has_longdan) and has_kuanggu then--关/赵和魏延
    if has_Crossbow and need_tieqi then
      return "tieqi"
    elseif has_Crossbow and can_liegong then
      return "liegong"
    elseif has_Crossbow and can_tieqi then
      return "tieqi"
    elseif can_paoxiao then
      return "paoxiao"
    elseif need_tieqi then
      return "tieqi"
    elseif can_liegong then
      return "liegong"
    end
  end

  --单技能的情况
  if (has_tieqi or has_liegong or has_qianxi) then--马超兄弟/黄忠
    if has_Crossbow and can_kuanggu then
      return "kuanggu"
    elseif can_kuanggu and self.player:getHp() <=2 then
      return "kuanggu"
    elseif can_paoxiao then--咆哮
        return "paoxiao"
    elseif target:hasShownSkill("tianxiang") and need_tieqi then
        return "tieqi"
    elseif can_kuanggu then
        return "kuanggu"
    end
  end
  if(has_paoxiao or has_Crossbow or has_baolie) then--张飞、夏侯霸
    if enough_pxslash then
      if can_kuanggu then
        return "kuanggu"
      elseif need_tieqi then
        return "tieqi"
      elseif can_liegong then
        return "liegong"
      elseif can_tieqi then--烈弓再找不到目标
        return "tieqi"
      end
    elseif can_wusheng then
      return "wusheng"
    elseif can_longdan then
      return "longdan"
    end
  end
  if (has_wusheng or has_longdan) then--关/赵
    if has_Crossbow and can_kuanggu then
      return "kuanggu"
    elseif can_paoxiao then
      return "paoxiao"
    end
  end
  if has_kuanggu then--魏延
    if has_Crossbow and (self.player:distanceTo(target) < 2
    or (self.player:distanceTo(target) == 2 and self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse())) then
      if can_wusheng then
        return "wusheng"
      elseif lord_longdan then
        return "longdan"
      end
    elseif can_paoxiao then--咆哮
      return "paoxiao"
    elseif self.player:getHp() <=2 then
      if need_tieqi then
        return "tieqi"
      elseif can_liegong then
        return "liegong"
      elseif can_tieqi then--烈弓再找不到目标
        return "tieqi"
      end
    end
  end

  --普通的技能选择顺序
  :: Pass_target ::
  if can_paoxiao and not (has_baolie or has_Crossbow) then--咆哮
    return "paoxiao"
  end
  if can_kuanggu and ((has_Crossbow and (yongjue_slash + self:getCardsNum("Slash") > 2))
    or (self.player:getHp() < 2 and target:isKongcheng())) then
    return "kuanggu"
  end
  if need_tieqi then
    return "tieqi"
  end
  if can_liegong then
    return "liegong"
  end
  if can_tieqi then--烈弓再找不到目标
    return "tieqi"
  end
  if lord_longdan then
    return "longdan"
  end
  if can_kuanggu then
    return "kuanggu"
  end
  if can_wusheng then
    return "wusheng"
  end
  if can_longdan then
    return "longdan"
  end
  global_room:writeToConsole(self.player:objectName()..":！！眩惑无可选技能！！")
  return choices[#choices]--一般是狂骨？没有目标选可以这个
end

--武圣
sgs.ai_view_as.wusheng_xh = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getHandPile():contains(card_id)) and (player:getLord() and player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:wusheng_xh[%s:%s]=%d&wusheng_xh"):format(suit, number, card_id)
	end
end

local wusheng_xh_skill = {}
wusheng_xh_skill.name = "wusheng_xh"
table.insert(sgs.ai_skills, wusheng_xh_skill)
wusheng_xh_skill.getTurnUseCard = function(self, inclusive)

	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end

	local disCrossbow = false
	if self:getCardsNum("Slash") < 2 or self.player:hasSkill("paoxiao|paoxiao_xh") or (self.player:hasSkill("baolie") and self.player:getHp() < 3) then disCrossbow = true end

	local hecards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getHandPile()) do
		hecards:prepend(sgs.Sanguosha:getCard(id))
	end
	local cards = {}
	for _, card in sgs.qlist(hecards) do
		if (self.player:getLord() and self.player:getLord():hasShownSkill("shouyue") or card:isRed())
      and (not card:isKindOf("Slash") or card:isKindOf("NatureSlash"))
			and ((not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player)) or useAll)
      and not isCard("BefriendAttacking", card, self.player) and not isCard("AllianceFeast", card, self.player)
			and (not isCard("Crossbow", card, self.player) or disCrossbow ) then
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:wusheng_xh[%s:%s]=%d&wusheng_xh"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				table.insert(cards, slash)
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end

sgs.ai_suit_priority.wusheng_xh = "club|spade|diamond|heart"

--咆哮
sgs.ai_skill_invoke.paoxiao_xh = true

--龙胆
local longdan_xh_skill = {}
longdan_xh_skill.name = "longdan_xh"
table.insert(sgs.ai_skills, longdan_xh_skill)
longdan_xh_skill.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getHandcards())
	for _, id in sgs.qlist(self.player:getHandPile()) do
		table.insert(cards, sgs.Sanguosha:getCard(id))
	end
	local jink_card

	self:sortByUseValue(cards,true)

	for _,card in ipairs(cards)  do
		if card:isKindOf("Jink") then
			jink_card = card
			break
		end
	end

	if not jink_card then return nil end
	local suit = jink_card:getSuitString()
	local number = jink_card:getNumberString()
	local card_id = jink_card:getEffectiveId()
	local card_str = ("slash:longdan_xh[%s:%s]=%d&longdan_xh"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)

	return slash
end

sgs.ai_view_as.longdan_xh = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand or player:getHandPile():contains(card_id) then
		if card:isKindOf("Jink") then
			return ("slash:longdan_xh[%s:%s]=%d&longdan_xh"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:longdan_xh[%s:%s]=%d&longdan_xh"):format(suit, number, card_id)
		end
	end
end

--铁骑
sgs.ai_skill_invoke.tieqi_xh = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then return false end
	return true
end

sgs.ai_skill_choice.tieqi_xh = function(self, choices, data)
	local target = data:toPlayer()
	if self:isFriend(target) then return "deputy_general" end

	if target:hasShownOneGeneral() then
		if (target:hasShownGeneral1()) and not (target:getGeneral2() and target:hasShownGeneral2()) then
			return "head_general"
		end
		if not (target:hasShownGeneral1()) and (target:getGeneral2() and target:hasShownGeneral2()) then
			return "deputy_general"
		end
		if (target:hasShownGeneral1()) and (target:getGeneral2() and target:hasShownGeneral2()) then
			if target:getMark("skill_invalidity_deputy") > 0 then
				return "head_general"
			end
			if target:getMark("skill_invalidity_head") > 0 then
				return "deputy_general"
			end
			local skills_name = (sgs.masochism_skill .. "|" .. sgs.save_skill .. "|" .. sgs.defense_skill .. "|"
					.. sgs.wizard_skill):split("|")
					--[[ .. "|" .. sgs.usefull_skill]]--更新技能名单
			for _, skill_name in ipairs(skills_name) do
				local skill = sgs.Sanguosha:getSkill(skill_name)
				if target:inHeadSkills(skill_name) and skill and skill:getFrequency() ~= sgs.Skill_Compulsory then
					return "head_general"
				end
			end
			return "deputy_general"
		end
	end
	return "deputy_general"
end

--烈弓
sgs.ai_skill_invoke.liegong_xh = function(self, data)
	local target = data:toPlayer()
	return not self:isFriend(target)
end

--狂骨
sgs.ai_skill_invoke.kuanggu_xh = function(self, data)
	return true
end

sgs.ai_skill_choice.kuanggu_xh = function(self, choices)
	if self.player:getHp() <= 2 or not self:slashIsAvailable() or self.player:getMark("GlobalBattleRoyalMode") > 0 then
		return "recover"
	end
	return "draw"
end

sgs.kuanggu_xh_keep_value = {
	Crossbow = 6,
  SixDragons = 6,
	OffensiveHorse = 6
}

--吴国太
local ganlu_skill = {}
ganlu_skill.name = "ganlu"
table.insert(sgs.ai_skills, ganlu_skill)
ganlu_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("GanluCard") then
		return sgs.Card_Parse("@GanluCard=.&ganlu")
	end
end

sgs.ai_skill_use_func.GanluCard = function(card, use, self)
	local lost_hp = self.player:getLostHp()
	local target, min_friend, max_enemy

	local compare_func = function(a, b)
		return a:getEquips():length() > b:getEquips():length()
	end
	table.sort(self.enemies, compare_func)
	table.sort(self.friends, compare_func)

	self.friends = sgs.reverse(self.friends)

	for _, friend in ipairs(self.friends) do
		for _, enemy in ipairs(self.enemies) do
			if not self:hasSkills(sgs.lose_equip_skill, enemy) then
				local ee = enemy:getEquips():length()
				local fe = friend:getEquips():length()
				local value = self:evaluateArmor(enemy:getArmor(),friend) - self:evaluateArmor(friend:getArmor(),enemy)
					- self:evaluateArmor(friend:getArmor(),friend) + self:evaluateArmor(enemy:getArmor(),enemy)
				if math.abs(ee - fe) <= lost_hp and ee > 0 and (ee > fe or ee == fe and value>0) then
					if self:hasSkills(sgs.lose_equip_skill, friend) then
						use.card = card
						if use.to then
							use.to:append(friend)
							use.to:append(enemy)
						end
						return
					elseif not min_friend and not max_enemy then
						min_friend = friend
						max_enemy = enemy
					end
				end
			end
		end
	end
	if min_friend and max_enemy then
		use.card = card
		if use.to then
			use.to:append(min_friend)
			use.to:append(max_enemy)
		end
		return
	end

	target = nil
	for _, friend in ipairs(self.friends) do
		if self:needToThrowArmor(friend) or (self:hasSkills(sgs.lose_equip_skill, friend)	and not friend:getEquips():isEmpty()) then
				target = friend
				break
		end
	end
	if not target then return end
	for _,friend in ipairs(self.friends) do
		if friend:objectName() ~= target:objectName() and math.abs(friend:getEquips():length() - target:getEquips():length()) <= lost_hp then
			use.card = card
			if use.to then
				use.to:append(friend)
				use.to:append(target)
			end
			return
		end
	end
end

sgs.ai_use_priority.GanluCard = sgs.ai_use_priority.Dismantlement + 0.1
sgs.dynamic_value.control_card.GanluCard = true

sgs.ai_card_intention.GanluCard = function(self,card, from, to)
	local compare_func = function(a, b)
		return a:getEquips():length() < b:getEquips():length()
	end
	table.sort(to, compare_func)
	for i = 1, 2, 1 do
		if to[i]:hasArmorEffect("silver_lion") then
			sgs.updateIntention(from, to[i], -20)
			break
		end
	end
	if to[1]:getEquips():length() < to[2]:getEquips():length() then
		sgs.updateIntention(from, to[1], -80)
	end
end

sgs.ai_skill_invoke.buyi = true

sgs.ai_skill_choice["startcommand_buyi"] = function(self, choices)--还是需要目标的data
  self.player:speak(choices)
  choices = choices:split("+")
  local commands = {"command1", "command2", "command4", "command3", "command6", "command5"}--索引大小代表优先级，注意不是原顺序
  local command_value1 = table.indexOf(commands,choices[1])
  local command_value2 = table.indexOf(commands,choices[2])
  local index = math.max(command_value1,command_value2)--需要一些额外的标记？
  --global_room:writeToConsole("choice:".. choices[index])
  return commands[index]
end

sgs.ai_skill_choice["docommand_buyi"] = function(self, choices, data)
  --[[if index <= 4 then
    return "yes"
  end
  if index == 5 then
    if self.player:getCards("he"):length() < 4 then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getCards("he"):length() < 6 then
      return "yes"
    else
      return "no"
    end
  end
  if index == 6 then
    if not self.player:faceUp() then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getHandcardNum() < 3
    and math.random(1, 100) / 100 >= 50  then
      return "yes"
    else
      return "no"
    end
  end]]--
  return "no"
end

--陆抗
sgs.ai_skill_invoke.keshou = function(self, data)
  local no_friend = true
  for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self.player:isFriendWith(p) then
      no_friend = false
      break
    end
	end
  if self.player:getHp() < 3 or self.player:getHandcardNum() > 3 or no_friend or self.player:getMark("GlobalBattleRoyalMode") > 0 then
    return true
  end
  return false
end

sgs.ai_skill_cardask["@keshou"] = function(self, data, pattern, target, target2)
	if self.player:getHandcardNum() < 2 then--缺手牌
    return "."
  end

  if self.player:hasSkill("tianxiang") then--配合小乔
    for _,card in sgs.qlist(self.player:getHandcards()) do
      if card:getSuit() == sgs.Card_Heart or (self.player:hasSkill("hongyan") and card:getSuit() == sgs.Card_Spade) then
        return "."
      end
    end
  end

  local function canKeshouDiscard(card)
    if (card:isKindOf("Peach") and self.player:getMark("GlobalBattleRoyalMode") == 0)
    or (card:isKindOf("Analeptic") and self.player:getHp() == 1) then
      return false
    end
    return true
  end

    local cards = self.player:getHandcards() -- 获得所有手牌
    cards=sgs.QList2Table(cards) -- 将列表转换为表
    local keshou_cards = {}
    if self.player:getHandcardNum() == 2  then--两张手牌的情况
      if cards[1]:sameColorWith(cards[2]) and canKeshouDiscard(cards[1]) and canKeshouDiscard(cards[2]) then
        table.insert(keshou_cards, cards[1]:getId())
        table.insert(keshou_cards, cards[2]:getId())
        return "$" .. table.concat(keshou_cards, "+")
      end
    else--三张及以上手牌
      self:sortByKeepValue(cards) -- 按保留值排序
      if cards[1]:sameColorWith(cards[2]) and canKeshouDiscard(cards[1]) and canKeshouDiscard(cards[2]) then
        table.insert(keshou_cards, cards[1]:getId())
        table.insert(keshou_cards, cards[2]:getId())
        return "$" .. table.concat(keshou_cards, "+")
      elseif cards[1]:sameColorWith(cards[3]) and canKeshouDiscard(cards[1])and canKeshouDiscard(cards[3]) then
        table.insert(keshou_cards, cards[1]:getId())
        table.insert(keshou_cards, cards[3]:getId())
        return "$" .. table.concat(keshou_cards, "+")
      elseif cards[2]:sameColorWith(cards[3]) and canKeshouDiscard(cards[2]) and canKeshouDiscard(cards[3]) then
        table.insert(keshou_cards, cards[2]:getId())
        table.insert(keshou_cards, cards[3]:getId())
        return "$" .. table.concat(keshou_cards, "+")
      end
    end
  return "."
end

sgs.ai_skill_invoke.zhuwei= function(self, data)
    if not self:willShowForDefence() then
		  return false
  	end
    return true
end

sgs.ai_skill_choice.zhuwei = function(self, choices, data)
  local target = self.room:getCurrent()
  if self:isFriend(target) then
    return "yes"
  else
    return "no"
  end
end

sgs.ai_slash_prohibit.zhuwei = sgs.ai_slash_prohibit.tiandu--考虑天香配合？

--张绣
sgs.ai_skill_playerchosen.fudi_damage = sgs.ai_skill_playerchosen.damage

sgs.ai_skill_exchange.fudi= function(self,pattern,max_num,min_num,expand_pile)
    if not self:willShowForMasochism() or self.player:isKongcheng() then
        return {}
    end

    local cards = self.player:getHandcards() -- 获得所有手牌
    cards=sgs.QList2Table(cards) -- 将列表转换为表
    self:sortByKeepValue(cards) -- 按保留值排序
    if cards[1]:isKindOf("Peach") then
        return {}
    end

	local from = self.player:getTag("FudiTarget"):toPlayer()

	local x = self.player:getHp()

	local targets = sgs.SPlayerList()

	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if not from:isFriendWith(p) or p:getHp() < x then
			continue
		end
		if p:getHp() > x and self:damageIsEffective(p, nil, self.player) then
			targets = sgs.SPlayerList()
		end
		x = p:getHp()
		targets:append(p)
	end

	if targets:isEmpty() then return {} end

	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) and self:damageIsEffective(target, nil, self.player) and not self:getDamagedEffects(target, self.player)
			and not self:needToLoseHp(target, self.player) then
			return cards[1]:getId()
		end
	end
	for _, target in sgs.qlist(targets) do
		if self:isFriend(target) and self:damageIsEffective(target, nil, self.player)
			and (self:getDamagedEffects(target, self.player) or self:needToLoseHp(target, self.player, nil, true)) then
			return cards[1]:getId()
		end
	end

  return {}
end

function sgs.ai_slash_prohibit.fudi(self, from, to)--杀禁止
	if self:isFriend(to, from) then return false end
	if to:isKongcheng() then return false end
  if from:getHp() >= 3 or (to:getHp() - from:getHp() > 1) then return false end
  if from:hasSkills("tieqi|tieqi_xh") then return false end
  self:sort(self.friends_noself,"hp", true)
  for _, friend in ipairs(self.friends_noself) do
    if friend:getHp() > from:getHp() and from:isFriendWith(friend) and friend:isAlive() then
      if friend:getHp() >=3 or (friend:getHandcardNum() + friend:getHp() > 4) then
        return false
      end
    end
  end
	return (from:getHandcardNum() + from:getHp()) - math.min(to:getHp(), to:getHandcardNum()) < 4
end

sgs.ai_need_damaged.fudi = function(self, attacker, player)--主动卖血
	if not attacker or self:isFriend(attacker) then return end
	if self:isEnemy(attacker) and attacker:getHp() >= (self.player:getHp() - 1) and self:isWeak(attacker) and self:damageIsEffective(attacker, nil, self.player)
		and not (attacker:hasShownSkill("buqu")) and sgs.isGoodTarget(attacker, self:getEnemies(attacker), self) then
		return true
	end
	return false
end

sgs.ai_skill_invoke.congjian = function(self, data)
  if self.player:getPhase() ~= sgs.Player_NotActive then
    return false
  end
  local target = data:toDamage().to
	return not self:isFriend(target)
end

--袁术
local weidi_skill = {}
weidi_skill.name = "weidi"
table.insert(sgs.ai_skills, weidi_skill)
weidi_skill.getTurnUseCard = function(self)
	if not self.player:hasUsed("WeidiCard") then
		return sgs.Card_Parse("@WeidiCard=.&weidi")
	end
	return nil
end

sgs.ai_skill_use_func["WeidiCard"] = function(card, use, self)
  local target
	local targets = {}
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:hasFlag("WeidiHadDrawCards") and p:objectName() ~= self.player:objectName() then
			table.insert(targets, p)
		end
	end
  self:sort(targets, "handcard", true)
  target = targets[1]
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end

sgs.ai_skill_choice["startcommand_weidi"] = function(self, choices)
  self.player:speak(choices)
  choices = choices:split("+")
  local commands = {"command1", "command2", "command4", "command3", "command6", "command5"}--索引大小代表优先级，注意不是原顺序
  local command_value1 = table.indexOf(commands,choices[1])
  local command_value2 = table.indexOf(commands,choices[2])
  local index = math.max(command_value1,command_value2)--需要一些额外的标记？
  --global_room:writeToConsole("choice:".. choices[index])
  return commands[index]
end

sgs.ai_skill_choice["docommand_weidi"] = function(self, choices, data)
  --target->setFlags("JieyueTarget");有标记可使用
  --[[if index <= 4 then
    return "yes"
  end
  if index == 5 then
    if self.player:getCards("he"):length() < 4 then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getCards("he"):length() < 6 then
      return "yes"
    else
      return "no"
    end
  end
  if index == 6 then
    if not self.player:faceUp() then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getHandcardNum() < 3
    and math.random(1, 100) / 100 >= 50  then
      return "yes"
    else
      return "no"
    end
  end]]--
  return "no"
end

sgs.ai_skill_exchange.weidi_give = function(self,pattern,max_num,min_num,expand_pile)--未考虑敌友
  local weidi_give = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
  for _, c in ipairs(cards) do
    table.insert(weidi_give, c:getEffectiveId())
    if #weidi_give == max_num then
      break
    end
  end
	return weidi_give
end

sgs.ai_skill_invoke.yongsi = false--明牌负面效果

--君曹操
local huibian_skill = {}
huibian_skill.name = "huibian"
table.insert(sgs.ai_skills, huibian_skill)
huibian_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("HuibianCard") then return end
	return sgs.Card_Parse("@HuibianCard=.&huibian")
end

sgs.ai_skill_use_func.HuibianCard = function(card, use, self)
	--global_room:writeToConsole("使用挥鞭")
  local can_huibian = false
  local maixueskills = {"yiji","fangzhu","wangxi","jieming","shicai","bushi","zhiyu"}--不同卖血技能详细配合?
  local drawcard_target, recover_target
  local targets = {}
  self:sort(self.friends, "hp")--从小到大排序
  for _, friend in ipairs(self.friends) do
    if friend:getSeemingKingdom() == "wei" then
      table.insert(targets,friend)
    end
    if friend:getSeemingKingdom() == "wei" and friend:isWounded() then
      can_huibian = true
    end
  end
  if #targets < 2 or not can_huibian then return end

  local need_jieming = false
  for _, p in ipairs(targets) do
    if math.min(p:getMaxHp(), 5) - p:getHandcardNum() > 1 then
      need_jieming = true
      break
    end
  end
  if not need_jieming then
    table.removeOne(maixueskills,"jieming")
    table.insert(maixueskills,"jieming")--放到最后
  end

  if self.player:getHp() == 1 and self:isWeak() then--保君主
    recover_target = self.player
    table.removeOne(targets, self.player)
  end
  for _, p in ipairs(targets) do
    if self:isWeak(p) and not recover_target and p:hasShownSkills(sgs.priority_skill) then--先回复重要队友
      recover_target = p
      table.removeOne(targets,p)
      break
    end
  end

  if not recover_target then
    for _, p in ipairs(targets) do
      if self:isWeak(p) and not recover_target then
        recover_target = p
        table.removeOne(targets,p)
        break
      end
    end
  end

  if not recover_target then
    for _, p in ipairs(targets) do
      if p:isWounded() and not recover_target then
        recover_target = p
        table.removeOne(targets,p)
        break
      end
    end
  end

  for _, skill in ipairs(maixueskills) do--还可以细化条件，如队友被乐等
    for _, p in ipairs(targets) do
      if p:hasShownSkill(skill) and not drawcard_target and not self:willSkipPlayPhase(p)
      and (p:getHp() > (targets[#targets]:getHp() > 3 and 2 or 1) or (self:getAllPeachNum() +  getKnownCard(p, self.player, "Analeptic", true, "he") > 1)) then
        drawcard_target = p
        table.removeOne(targets,p)
      end
    end
  end

  if not drawcard_target then
    if targets[#targets]:getHp() > 1 or (self:getAllPeachNum() +  getKnownCard(targets[#targets], self.player, "Analeptic", true, "he") > 1) then
      drawcard_target =  targets[#targets]
      table.removeOne(targets,targets[#targets])
    end
  end

  if drawcard_target and recover_target then
    --global_room:writeToConsole("抽卡目标:"..sgs.Sanguosha:translate(drawcard_target:getGeneralName()).."/"..sgs.Sanguosha:translate(drawcard_target:getGeneral2Name()))
    --global_room:writeToConsole("回血目标:"..sgs.Sanguosha:translate(recover_target:getGeneralName()).."/"..sgs.Sanguosha:translate(recover_target:getGeneral2Name()))
	  use.card = card
    if use.to then
      use.to:append(drawcard_target)
      use.to:append(recover_target)
    end
  end
end

sgs.ai_use_priority.HuibianCard = 5--优先度多少合适？

sgs.ai_skill_invoke.zongyu = true

--五子良将纛
sgs.ai_skill_cardask["@elitegeneralflag"] = function(self, data, pattern, target, target2)










	return "."
end

--军令
function SmartAI:askCommandto(command, to)
    --[[if index <= 4 then
    return "yes"
  end
  if index == 5 then
    if self.player:getCards("he"):length() < 4 then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getCards("he"):length() < 6 then
      return "yes"
    else
      return "no"
    end
  end
  if index == 6 then
    if not self.player:faceUp() then
      return "yes"
    elseif self.player:getHp() < 3 and self:getCardsNum("Peach") == 0 and self.player:getHandcardNum() < 3
    and math.random(1, 100) / 100 >= 50  then
      return "yes"
    else
      return "no"
    end
  end]]--
	return "yes"
end

function SmartAI:doCommandfrom(command, from)

	return "no"
end
