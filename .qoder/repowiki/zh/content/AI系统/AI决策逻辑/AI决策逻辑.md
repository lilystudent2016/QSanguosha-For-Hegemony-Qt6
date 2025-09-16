# AI决策逻辑

<cite>
**本文档引用文件**   
- [smart-ai.lua](file://lua/ai/smart-ai.lua)
- [standard-shu-ai.lua](file://lua/ai/standard-shu-ai.lua)
- [standard_cards-ai.lua](file://lua/ai/standard_cards-ai.lua)
- [lua-wrapper.cpp](file://src/core/lua-wrapper.cpp)
</cite>

## 目录
1. [引言](#引言)
2. [项目结构](#项目结构)
3. [核心组件](#核心组件)
4. [架构概述](#架构概述)
5. [详细组件分析](#详细组件分析)
6. [依赖分析](#依赖分析)
7. [性能考量](#性能考量)
8. [故障排除指南](#故障排除指南)
9. [结论](#结论)

## 引言
本文档深入解析了《三国杀》游戏中AI决策逻辑的实现机制。以`smart-ai.lua`为核心，分析AI如何通过Lua脚本评估卡牌使用价值、技能优先级和目标选择。详细说明`standard-shu-ai.lua`等模式化AI脚本的结构设计，解释AI如何调用`getCardsNeed()`、`isCardEffect()`等辅助函数进行决策。结合具体场景（如AI使用【杀】或发动【观星】）展示从C++触发Lua接口到返回决策结果的完整调用链。文档提供决策树示例、卡牌价值评估算法说明，并对比不同武将AI的行为差异。同时说明Lua与C++通过`lua-wrapper`交互的数据序列化方式。

## 项目结构
项目结构清晰地分为多个模块，包括AI逻辑、扩展包、核心C++代码、Lua脚本、资源文件等。AI相关的Lua脚本主要位于`lua/ai/`目录下，而核心的C++与Lua交互代码位于`src/core/`目录。

```mermaid
graph TB
subgraph "AI逻辑"
A1[smart-ai.lua]
A2[standard-shu-ai.lua]
A3[standard_cards-ai.lua]
end
subgraph "C++核心"
B1[lua-wrapper.cpp]
end
subgraph "资源与配置"
C1[general-value.txt]
C2[pair-value.txt]
end
A1 --> B1
A2 --> A1
A3 --> A1
C1 --> A1
C2 --> A1
```

**图示来源**
- [smart-ai.lua](file://lua/ai/smart-ai.lua)
- [standard-shu-ai.lua](file://lua/ai/standard-shu-ai.lua)
- [standard_cards-ai.lua](file://lua/ai/standard_cards-ai.lua)
- [lua-wrapper.cpp](file://src/core/lua-wrapper.cpp)
- [general-value.txt](file://ai-selector/general-value.txt)
- [pair-value.txt](file://ai-selector/pair-value.txt)

## 核心组件
核心组件包括`SmartAI`类，它是所有特定AI的基类。`SmartAI`类负责初始化AI实例，管理玩家状态，评估卡牌价值，以及处理各种游戏事件。`CloneAI`函数是暴露给宿主程序的唯一接口，用于根据武将名称克隆AI实例。

**组件来源**
- [smart-ai.lua](file://lua/ai/smart-ai.lua)

## 架构概述
系统架构采用C++作为底层引擎，Lua作为上层AI逻辑脚本。C++通过`lua-wrapper`模块与Lua脚本进行交互，实现数据的序列化和反序列化。AI决策流程包括卡牌评估、技能调用、目标选择等步骤。

```mermaid
sequenceDiagram
participant C++ as C++引擎
participant LuaWrapper as Lua包装器
participant LuaAI as Lua AI脚本
C++->>LuaWrapper : 触发AI决策事件
LuaWrapper->>LuaAI : 调用Lua函数
LuaAI->>LuaAI : 评估卡牌价值
LuaAI->>LuaAI : 选择技能和目标
LuaAI-->>LuaWrapper : 返回决策结果
LuaWrapper-->>C++ : 执行游戏动作
```

**图示来源**
- [lua-wrapper.cpp](file://src/core/lua-wrapper.cpp)
- [smart-ai.lua](file://lua/ai/smart-ai.lua)

## 详细组件分析
### SmartAI类分析
`SmartAI`类是AI决策的核心，负责管理AI的状态和决策过程。

#### 类图
```mermaid
classDiagram
class SmartAI {
+player : ServerPlayer
+room : Room
+role : string
+lua_ai : LuaAI
+initialize(player)
+getTurnUse()
+activate(use)
+objectiveLevel(player)
+updatePlayers(update, resetAI)
+assignKeep(start)
+getUseValue(card)
+getUsePriority(card)
+getDynamicUsePriority(card)
+cardNeed(card)
+sortByKeepValue(cards, inverse, kept)
+sortByUseValue(cards, inverse)
+sortByUsePriority(cards)
+sortByDynamicUsePriority(cards)
+sortByCardNeed(cards, inverse)
+isFriend(other, another)
+isEnemy(other, another)
+getFriendsNoself(player)
+getFriends(player)
+getEnemies(player)
+sort(players, key, inverse)
+filterEvent(event, player, data)
+askForSuit(reason)
+askForSkillInvoke(skill_name, data)
+askForChoice(skill_name, choices, data)
+askForExchange(reason, pattern, max_num, min_num, expand_pile)
+askForDiscard(reason, discard_num, min_num, optional, include_equip)
+askForMoveCards(upcards, downcards, reason, pattern, min_num, max_num)
+askForTransferFieldCards(targets, reason, equipArea, judgingArea)
+askForNullification(trick, from, to, positive)
+getCardRandomly(who, flags, disable_list)
+askForCardChosen(who, flags, reason, method, disable_list)
+askForCardsChosen(who, flags, reason, min_num, max_num, method, disable_list)
+askForCard(pattern, prompt, data)
+askForUseCard(pattern, prompt, method)
+askForAG(card_ids, refusable, reason)
+askForCardShow(requestor, reason)
+getEnemyNumBySeat(from, to, target, include_neutral)
+getFriendNumBySeat(from, to)
+hasHeavySlashDamage(from, slash, to, getValue)
+needKongcheng(player, keep, hengzheng_invoker)
+SimpleGuixinInvoke(player)
+getLeastHandcardNum(player)
+hasLoseHandcardEffective(player)
+getCardNeedPlayer(cards, friends_table, skillname)
+askForYiji(card_ids, reason)
+askForPindian(requestor, reason)
}
```

**图示来源**
- [smart-ai.lua](file://lua/ai/smart-ai.lua)

### 卡牌价值评估算法
AI通过`getUseValue`、`getUsePriority`、`getDynamicUsePriority`等函数评估卡牌的使用价值。这些函数考虑了卡牌类型、玩家状态、敌人和友方情况等因素。

```mermaid
flowchart TD
Start([开始评估卡牌]) --> CheckCardType["检查卡牌类型"]
CheckCardType --> |基本牌| BasicCard["评估基本牌价值"]
CheckCardType --> |装备牌| EquipCard["评估装备牌价值"]
CheckCardType --> |锦囊牌| TrickCard["评估锦囊牌价值"]
CheckCardType --> |技能牌| SkillCard["评估技能牌价值"]
BasicCard --> CheckSlash["检查是否为【杀】"]
CheckSlash --> |是| SlashValue["计算【杀】的价值"]
CheckSlash --> |否| OtherBasic["计算其他基本牌价值"]
EquipCard --> CheckWeapon["检查是否为武器"]
CheckWeapon --> |是| WeaponValue["计算武器价值"]
CheckWeapon --> |否| OtherEquip["计算其他装备价值"]
TrickCard --> CheckAOE["检查是否为AOE"]
CheckAOE --> |是| AOEValue["计算AOE价值"]
CheckAOE --> |否| SingleTrick["计算单体锦囊价值"]
SkillCard --> SkillValue["计算技能牌价值"]
SlashValue --> AdjustValue["调整价值"]
OtherBasic --> AdjustValue
WeaponValue --> AdjustValue
OtherEquip --> AdjustValue
AOEValue --> AdjustValue
SingleTrick --> AdjustValue
SkillValue --> AdjustValue
AdjustValue --> Return["返回卡牌价值"]
```

**图示来源**
- [smart-ai.lua](file://lua/ai/smart-ai.lua)

### 武将AI行为差异
不同武将的AI行为通过`standard-shu-ai.lua`等文件中的特定函数实现。例如，刘备的`rende`技能、关羽的`wusheng`技能等。

#### 刘备仁德技能决策
```mermaid
flowchart TD
Start([刘备使用仁德]) --> CheckCrossbow["检查是否有【诸葛连弩】"]
CheckCrossbow --> |有| CheckSlash["检查是否有【杀】"]
CheckSlash --> |有| SortEnemies["对敌人按防御排序"]
SortEnemies --> CheckAttackRange["检查攻击范围"]
CheckAttackRange --> |在范围内| CheckGoodTarget["检查是否为好目标"]
CheckGoodTarget --> |是| CheckSlashCount["检查【杀】数量是否足够"]
CheckSlashCount --> |足够| ReturnFalse["不使用仁德"]
CheckSlashCount --> |不足| ReturnTrue["使用仁德"]
CheckAttackRange --> |不在范围内| ReturnTrue
CheckSlash --> |无| CheckEnemyCrossbow["检查敌人是否有【诸葛连弩】"]
CheckEnemyCrossbow --> |有| CheckEnemySlash["检查敌人【杀】数量"]
CheckEnemySlash --> |大于1| CheckOverflow["检查手牌溢出"]
CheckOverflow --> |溢出<=0| ReturnFalse
CheckOverflow --> |溢出>0| ReturnTrue
CheckEnemyCrossbow --> |无| CheckFriendSkills["检查友方技能"]
CheckFriendSkills --> |有好施或急救| ReturnTrue
CheckFriendSkills --> |无| CheckHandcardNum["检查手牌数"]
CheckHandcardNum --> |手牌少| ReturnTrue
CheckHandcardNum --> |手牌多| ReturnFalse
```

**图示来源**
- [standard-shu-ai.lua](file://lua/ai/standard-shu-ai.lua)

## 依赖分析
AI系统依赖于C++核心引擎提供的玩家、房间、卡牌等对象，以及Lua脚本提供的决策逻辑。`lua-wrapper`模块负责在C++和Lua之间传递数据。

```mermaid
graph TD
A[C++引擎] --> B[lua-wrapper]
B --> C[smart-ai.lua]
C --> D[standard-shu-ai.lua]
C --> E[standard_cards-ai.lua]
D --> F[general-value.txt]
D --> G[pair-value.txt]
```

**图示来源**
- [lua-wrapper.cpp](file://src/core/lua-wrapper.cpp)
- [smart-ai.lua](file://lua/ai/smart-ai.lua)
- [standard-shu-ai.lua](file://lua/ai/standard-shu-ai.lua)
- [general-value.txt](file://ai-selector/general-value.txt)
- [pair-value.txt](file://ai-selector/pair-value.txt)

## 性能考量
AI决策的性能主要受Lua脚本执行效率和C++与Lua交互开销的影响。优化建议包括减少不必要的函数调用、缓存常用计算结果、优化卡牌价值评估算法等。

## 故障排除指南
常见问题包括AI决策延迟、卡牌价值评估不准确、技能调用错误等。解决方法包括检查Lua脚本语法、验证C++与Lua接口、调试决策逻辑等。

**组件来源**
- [smart-ai.lua](file://lua/ai/smart-ai.lua)
- [standard-shu-ai.lua](file://lua/ai/standard-shu-ai.lua)
- [lua-wrapper.cpp](file://src/core/lua-wrapper.cpp)

## 结论
本文档详细解析了《三国杀》AI决策逻辑的实现机制，涵盖了从C++底层到Lua上层的完整技术栈。通过深入分析核心组件、架构设计、决策算法和行为差异，为开发者提供了全面的技术参考。未来工作可进一步优化AI决策效率，增强AI的智能水平。