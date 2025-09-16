# 核心UI组件

<cite>
**本文档中引用的文件**   
- [carditem.cpp](file://src/ui/carditem.cpp)
- [carditem.h](file://src/ui/carditem.h)
- [photo.cpp](file://src/ui/photo.cpp)
- [photo.h](file://src/ui/photo.h)
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [dashboard.h](file://src/ui/dashboard.h)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)
- [chatwidget.h](file://src/ui/chatwidget.h)
</cite>

## 目录
1. [项目结构](#项目结构)
2. [核心组件](#核心组件)
3. [架构概述](#架构概述)
4. [详细组件分析](#详细组件分析)
5. [依赖分析](#依赖分析)
6. [性能考虑](#性能考虑)
7. [故障排除指南](#故障排除指南)
8. [结论](#结论)

## 项目结构

项目结构展示了核心UI组件位于`src/ui`目录下，主要包括卡牌项、玩家头像、状态面板和聊天控件等关键文件。

```mermaid
graph TD
A[src] --> B[ui]
B --> C[carditem.cpp]
B --> D[photo.cpp]
B --> E[dashboard.cpp]
B --> F[chatwidget.cpp]
```

**图示来源**
- [carditem.cpp](file://src/ui/carditem.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

**本节来源**
- [carditem.cpp](file://src/ui/carditem.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

## 核心组件

核心UI组件包括卡牌项（carditem）、玩家头像（photo）、状态面板（dashboard）和聊天控件（chatwidget），它们共同构成了游戏界面的主要交互元素。

**本节来源**
- [carditem.cpp](file://src/ui/carditem.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

## 架构概述

系统架构展示了各个UI组件之间的关系和交互方式，其中状态面板作为中心组件，集成了玩家信息和游戏状态。

```mermaid
graph TD
Dashboard[状态面板] --> Photo[玩家头像]
Dashboard --> CardItem[卡牌项]
Dashboard --> ChatWidget[聊天控件]
Photo --> CardItem
ChatWidget --> Dashboard
```

**图示来源**
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [carditem.cpp](file://src/ui/carditem.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

## 详细组件分析

### 卡牌项分析

卡牌项组件负责管理卡牌的视觉状态和交互逻辑，支持手牌、装备和弃牌堆等多种状态。

#### 类图
```mermaid
classDiagram
class CardItem {
+int m_cardId
+QPointF home_pos
+bool m_isSelected
+bool m_isChosen
+QString _m_frameType
+QString _m_avatarName
+QString _m_smallCardName
+bool outerGlowEffectEnabled
+QColor outerGlowColor
+TransferButton* _transferButton
+bool _transferable
+int _skinId
+bool m_isHovered
+void setCard(const Card* card)
+const Card* getCard() const
+void setHomePos(QPointF home_pos)
+QPointF homePos() const
+void goBack(bool playAnimation, bool doFade)
+QAbstractAnimation* getGoBackAnimation(bool doFade, bool smoothTransition, int duration)
+void showFrame(const QString& result)
+void hideFrame()
+void showAvatar(const General* general, const QString card_name)
+void hideAvatar()
+void showSmallCard(const QString& card_name)
+void hideSmallCard()
+void setAutoBack(bool auto_back)
+bool isEquipped() const
+void setFrozen(bool is_frozen, bool update_movable)
+static CardItem* FindItem(const QList<CardItem*>& items, int card_id)
+void setOuterGlowEffectEnabled(const bool& willPlay)
+bool isOuterGlowEffectEnabled() const
+void setOuterGlowColor(const QColor& color)
+QColor getOuterGlowColor() const
+void setTransferable(const bool transferable)
+TransferButton* getTransferButton() const
+void mousePressEvent(QGraphicsSceneMouseEvent* mouseEvent)
+void mouseReleaseEvent(QGraphicsSceneMouseEvent* mouseEvent)
+void mouseMoveEvent(QGraphicsSceneMouseEvent* mouseEvent)
+void mouseDoubleClickEvent(QGraphicsSceneMouseEvent* event)
+void hoverEnterEvent(QGraphicsSceneHoverEvent*)
+void hoverLeaveEvent(QGraphicsSceneHoverEvent*)
+void paint(QPainter* painter, const QStyleOptionGraphicsItem*, QWidget*)
+void setFootnote(const QString& desc)
}
class TransferButton {
+int _id
+CardItem* _cardItem
+TransferButton(CardItem* parent)
+int getCardId() const
+CardItem* getCardItem() const
+void onClicked()
}
CardItem --> TransferButton : "包含"
```

**图示来源**
- [carditem.cpp](file://src/ui/carditem.cpp#L1-L552)
- [carditem.h](file://src/ui/carditem.h)

**本节来源**
- [carditem.cpp](file://src/ui/carditem.cpp#L1-L552)
- [carditem.h](file://src/ui/carditem.h)

### 玩家头像分析

玩家头像组件实现了武将头像与血量显示机制，支持表情动画和技能名称显示等功能。

#### 类图
```mermaid
classDiagram
class Photo {
+QGraphicsPixmapItem* _m_mainFrame
+const ClientPlayer* m_player
+QGraphicsPixmapItem* _m_focusFrame
+QGraphicsPixmapItem* _m_onlineStatusItem
+QSanComponentLayout* _m_layout
+FrameType _m_frameType
+QLabel* _m_skillNameLabel
+QGraphicsProxyWidget* _m_skillNameRegion
+QParallelAnimationGroup* _m_skillNameAnim
+Sprite* emotion_item
+void refresh()
+QRectF boundingRect() const
+void repaintAll()
+void _adjustComponentZValues()
+void setEmotion(const QString& emotion, bool permanent, bool playback, int duration)
+void tremble()
+void showSkillName(const QString& skill_name)
+void hideSkillName()
+void hideEmotion()
+const ClientPlayer* getPlayer() const
+void speak(const QString&)
+void updateSmallAvatar()
+QList<CardItem*> removeCardItems(const QList<int>& card_ids, const CardsMoveStruct& moveInfo)
+bool _addCardItems(QList<CardItem*>& card_items, const CardsMoveStruct& moveInfo)
+void setFrame(FrameType type)
+void updatePhase()
+void paint(QPainter* painter, const QStyleOptionGraphicsItem*, QWidget*)
+QPropertyAnimation* initializeBlurEffect(GraphicsPixmapHoverItem* icon)
+void _initializeRemovedEffect()
+QGraphicsItem* getMouseClickReceiver()
+void _createBattleArrayAnimations()
+void playBattleArrayAnimations()
}
Photo --> Sprite : "使用"
Photo --> QGraphicsProxyWidget : "使用"
Photo --> QParallelAnimationGroup : "使用"
```

**图示来源**
- [photo.cpp](file://src/ui/photo.cpp#L1-L497)
- [photo.h](file://src/ui/photo.h)

**本节来源**
- [photo.cpp](file://src/ui/photo.cpp#L1-L497)
- [photo.h](file://src/ui/photo.h)

### 状态面板分析

状态面板组件集成了身份、体力、装备等信息的实时更新，是玩家主要的操作界面。

#### 类图
```mermaid
classDiagram
class Dashboard {
+int width
+QGraphicsPixmapItem* leftFrame
+QGraphicsPixmapItem* middleFrame
+QGraphicsPixmapItem* rightFrame
+QGraphicsPixmapItem* rightFrameBase
+QGraphicsPixmapItem* rightFrameBg
+QGraphicsPixmapItem* magatamasBase
+QGraphicsPixmapItem* headGeneralFrame
+QGraphicsPixmapItem* deputyGeneralFrame
+QGraphicsPixmapItem* buttonWidget
+CardItem* selected
+QSanComponentLayout* layout
+QGraphicsPixmapItem* leftHiddenMark
+QGraphicsPixmapItem* rightHiddenMark
+GraphicsPixmapHoverItem* headIcon
+GraphicsPixmapHoverItem* deputyIcon
+CardItem* pendingCard
+const ViewAsSkill* viewAsSkill
+CardFilter* filter
+QSanButton* m_changeHeadHeroSkinButton
+QSanButton* m_changeDeputyHeroSkinButton
+HeroSkinContainer* m_headHeroSkinContainer
+HeroSkinContainer* m_deputyHeroSkinContainer
+ProgressBarPosition m_progressBarPositon
+QList<int> _m_hand_pile
+QList<int> _m_pile_expanded
+QList<CardItem*> _m_guhuo_expanded
+QList<CardItem*> _m_general_expanded
+QSanInvokeSkillButton* _m_equipSkillBtns[S_EQUIP_AREA_LENGTH]
+bool _m_isEquipsAnimOn[S_EQUIP_AREA_LENGTH]
+QGraphicsRectItem* _m_shadow_layer1
+QGraphicsRectItem* _m_shadow_layer2
+QGraphicsSimpleTextItem* trusting_text
+QGraphicsRectItem* trusting_item
+QMenu* _m_sort_menu
+void refresh()
+void repaintAll()
+bool isAvatarUnderMouse()
+void hideControlButtons()
+void showControlButtons()
+void showProgressBar(QSanProtocol : : Countdown countdown)
+QGraphicsItem* getMouseClickReceiver()
+QGraphicsItem* getMouseClickReceiver2()
+void _createLeft()
+int getButtonWidgetWidth() const
+void _createMiddle()
+void _adjustComponentZValues()
+int getWidth()
+void updateSkillButton()
+void _createRight()
+void _updateFrames()
+void setTrust(bool trust)
+void killPlayer()
+void revivePlayer()
+void setDeathColor()
+bool _addCardItems(QList<CardItem*>& card_items, const CardsMoveStruct& moveInfo)
+void addHandCards(QList<CardItem*>& card_items)
+void _addHandCard(CardItem* card_item, bool isRealHandcard, const QString& footnote)
+void _updateHandCards()
+void _createRoleComboBox()
+void selectCard(const QString& pattern, bool forward, bool multiple)
+void selectEquip(int position)
+void selectOnlyCard(bool need_only)
+const Card* getSelectedCard() const
+const Card* getSelected() const
+void selectCard(CardItem* item, bool isSelected)
+void unselectAll(const CardItem* except, bool enableTargets)
+QRectF boundingRect() const
+void setWidth(int width)
+QSanSkillButton* addSkillButton(const QString& skillName, const bool& head)
+QSanSkillButton* removeSkillButton(const QString& skillName, bool head)
+void highlightEquip(QString skillName, bool highlight)
+void setPlayer(ClientPlayer* player)
+void _createExtraButtons()
+void showSeat()
+void clearPendings()
+QList<TransferButton*> getTransferButtons() const
}
Dashboard --> QSanInvokeSkillButton : "使用"
Dashboard --> HeroSkinContainer : "使用"
Dashboard --> QMenu : "使用"
```

**图示来源**
- [dashboard.cpp](file://src/ui/dashboard.cpp#L1-L799)
- [dashboard.h](file://src/ui/dashboard.h)

**本节来源**
- [dashboard.cpp](file://src/ui/dashboard.cpp#L1-L799)
- [dashboard.h](file://src/ui/dashboard.h)

### 聊天控件分析

聊天控件组件提供了便捷的聊天功能，支持表情和快捷短语的发送。

#### 类图
```mermaid
classDiagram
class MyPixmapItem {
+QPixmap pixmap
+QString itemName
+QList<QRect> faceboardPos
+QList<QRect> easytextPos
+int sizex
+int sizey
+QStringList easytext
+MyPixmapItem(const QPixmap& pixmap, QGraphicsItem* parentItem)
+~MyPixmapItem()
+void mousePressEvent(QGraphicsSceneMouseEvent* event)
+void hoverMoveEvent(QGraphicsSceneHoverEvent* event)
+void setSize(int x, int y)
+int mouseCanClick(int x, int y)
+int mouseOnIcon(int x, int y)
+int mouseOnText(int x, int y)
+QRectF boundingRect() const
+void paint(QPainter* painter, const QStyleOptionGraphicsItem*, QWidget*)
+void initFaceBoardPos()
+void initEasyTextPos()
}
class ChatWidget {
+QPixmap base_pixmap
+QGraphicsRectItem* base
+MyPixmapItem* chat_face_board
+MyPixmapItem* easy_text_board
+ChatWidget()
+~ChatWidget()
+void showEasyTextBoard()
+void showFaceBoard()
+void sendText()
+QRectF boundingRect() const
+void paint(QPainter* painter, const QStyleOptionGraphicsItem*, QWidget*)
+QPushButton* createButton(const QString& name)
+QPushButton* addButton(const QString& name, int x)
+QGraphicsProxyWidget* addWidget(QWidget* widget, int x)
}
ChatWidget --> MyPixmapItem : "使用"
```

**图示来源**
- [chatwidget.cpp](file://src/ui/chatwidget.cpp#L1-L252)
- [chatwidget.h](file://src/ui/chatwidget.h)

**本节来源**
- [chatwidget.cpp](file://src/ui/chatwidget.cpp#L1-L252)
- [chatwidget.h](file://src/ui/chatwidget.h)

## 依赖分析

各组件之间的依赖关系清晰，状态面板作为中心组件依赖于其他所有组件，而卡牌项、玩家头像和聊天控件则相对独立。

```mermaid
graph TD
Dashboard[状态面板] --> Photo[玩家头像]
Dashboard --> CardItem[卡牌项]
Dashboard --> ChatWidget[聊天控件]
Photo --> CardItem
ChatWidget --> Dashboard
```

**图示来源**
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [carditem.cpp](file://src/ui/carditem.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

**本节来源**
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [carditem.cpp](file://src/ui/carditem.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

## 性能考虑

各组件在设计时都考虑了性能优化，如使用缓存、减少重绘和合理管理动画等。

## 故障排除指南

常见问题包括组件不显示、交互无响应等，可通过检查组件初始化、信号连接和样式设置来解决。

**本节来源**
- [carditem.cpp](file://src/ui/carditem.cpp)
- [photo.cpp](file://src/ui/photo.cpp)
- [dashboard.cpp](file://src/ui/dashboard.cpp)
- [chatwidget.cpp](file://src/ui/chatwidget.cpp)

## 结论

核心UI组件设计合理，功能完整，为游戏提供了良好的用户体验。