# UI脚本接口与事件绑定

<cite>
**本文档引用的文件**   
- [page.js](file://ui-script/page.js)
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp)
- [pixmapanimation.h](file://src/ui/pixmapanimation.h)
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp)
- [lightboxanimation.h](file://src/ui/lightboxanimation.h)
- [sprite.cpp](file://src/ui/sprite.cpp)
- [sprite.h](file://src/ui/sprite.h)
</cite>

## 目录
1. [项目结构分析](#项目结构分析)
2. [核心组件分析](#核心组件分析)
3. [动画系统架构](#动画系统架构)
4. [PixmapAnimation实现机制](#pixmapanimation实现机制)
5. [LightboxAnimation实现机制](#lightboxanimation实现机制)
6. [特效动画系统](#特效动画系统)
7. [JavaScript与C++交互流程](#javascript与c交互流程)
8. [事件绑定与动画触发](#事件绑定与动画触发)

## 项目结构分析

根据项目目录结构，UI动画相关的代码主要分布在`src/ui`目录下，而UI脚本位于`ui-script`目录。核心动画类包括`PixmapAnimation`和`LightboxAnimation`，它们通过Qt的图形视图框架实现动画效果。

**Section sources**
- [project_structure](file://project_structure)

## 核心组件分析

项目中的动画系统由多个核心组件构成，主要包括：
- `PixmapAnimation`: 基于精灵图的帧动画系统
- `LightboxAnimation`: 技能触发时的聚光灯效果动画
- `EffectAnimation`: 图形特效管理系统
- `AnimatedEffect`: 特效基类

这些组件共同构成了游戏的视觉反馈系统。

**Section sources**
- [pixmapanimation.h](file://src/ui/pixmapanimation.h#L0-L40)
- [lightboxanimation.h](file://src/ui/lightboxanimation.h#L0-L61)
- [sprite.h](file://src/ui/sprite.h#L38-L105)

## 动画系统架构

```mermaid
graph TB
subgraph "UI动画系统"
PA[PixmapAnimation]
LA[LightboxAnimation]
EA[EffectAnimation]
AE[AnimatedEffect]
end
subgraph "基础类"
QO[QGraphicsObject]
QI[QGraphicsItem]
QE[QGraphicsEffect]
end
PA --> QI
LA --> QO
EA --> QObject
AE --> QE
EA --> FadeEffect
EA --> EmphasizeEffect
EA --> SentbackEffect
AE --> FadeEffect
AE --> EmphasizeEffect
AE --> SentbackEffect
```

**Diagram sources**
- [pixmapanimation.h](file://src/ui/pixmapanimation.h#L0-L40)
- [lightboxanimation.h](file://src/ui/lightboxanimation.h#L0-L61)
- [sprite.h](file://src/ui/sprite.h#L38-L105)

**Section sources**
- [pixmapanimation.h](file://src/ui/pixmapanimation.h#L0-L40)
- [lightboxanimation.h](file://src/ui/lightboxanimation.h#L0-L61)
- [sprite.h](file://src/ui/sprite.h#L38-L105)

## PixmapAnimation实现机制

`PixmapAnimation`类实现了基于精灵图的帧动画系统，其主要功能包括：

```mermaid
classDiagram
class PixmapAnimation {
+QList<QPixmap> frames
+int current
+int _m_timerId
+bool m_fix_rect
+QSize m_size
+int m_timer
+bool hideonstop
+void setPath(string path, bool playback)
+void setSize(QSize size)
+void setHideonStop(bool hide)
+void setPlayTime(int msecs)
+void start(bool permanent, int interval)
+void stop()
+void reset()
+bool isFirstFrame()
+void preStart()
+void end()
+static PixmapAnimation* GetPixmapAnimation(QGraphicsItem* parent, string emotion, bool playback, int duration)
}
PixmapAnimation --> QObject : 继承
PixmapAnimation --> QGraphicsItem : 实现
```

**Diagram sources**
- [pixmapanimation.h](file://src/ui/pixmapanimation.h#L0-L40)
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp#L42-L92)

**Section sources**
- [pixmapanimation.h](file://src/ui/pixmapanimation.h#L0-L40)
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp#L42-L92)

### 帧动画加载流程

```mermaid
flowchart TD
Start([开始]) --> SetPath["setPath(path, playback)"]
SetPath --> ClearFrames["清空frames列表"]
ClearFrames --> InitCounter["i = 0"]
InitCounter --> BuildPath["构建图片路径"]
BuildPath --> CheckExist["检查文件是否存在"]
CheckExist --> |存在| LoadPixmap["加载图片到frames"]
LoadPixmap --> Increment["i++"]
Increment --> BuildPath
CheckExist --> |不存在| CheckPlayback["检查playback"]
CheckPlayback --> |true| CreatePlayback["创建回放序列"]
CreatePlayback --> End["动画准备就绪"]
CheckPlayback --> |false| End
```

**Diagram sources**
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp#L42-L92)

## LightboxAnimation实现机制

`LightboxAnimation`类实现了技能触发时的聚光灯效果动画，使用Qt的动画框架组合多个动画效果。

```mermaid
classDiagram
class LightboxAnimation {
+QRectF rect
+RectObject* background
+QSanSelectableItem* generalPixmap
+RectObject* flick
+QGraphicsTextItem* skillName
+string general_name
+string skill_name
+LightboxAnimation(string general_name, string skill_name, QRectF rect)
+QRectF boundingRect()
+void finished()
}
class RectObject {
+QRectF m_boundingRect
+QBrush m_brush
+RectObject(QRectF rect, QBrush brush, QGraphicsItem* parent)
+QRectF boundingRect()
+void paint(QPainter* painter, ...)
+void show()
+void hide()
}
LightboxAnimation --> QGraphicsObject : 继承
RectObject --> QGraphicsObject : 继承
LightboxAnimation --> RectObject : 包含
LightboxAnimation --> QSanSelectableItem : 包含
LightboxAnimation --> QGraphicsTextItem : 包含
```

**Diagram sources**
- [lightboxanimation.h](file://src/ui/lightboxanimation.h#L0-L61)
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp#L38-L87)

**Section sources**
- [lightboxanimation.h](file://src/ui/lightboxanimation.h#L0-L61)
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp#L38-L87)

### 聚光灯动画序列

```mermaid
sequenceDiagram
participant Animation as QSequentialAnimationGroup
participant Step1 as QParallelAnimationGroup
participant Step2 as QPauseAnimation
participant Step3 as QPauseAnimation
participant Step4 as QPauseAnimation
participant Step5 as QPropertyAnimation
participant Step6 as QParallelAnimationGroup
participant Step7 as QPauseAnimation
Animation->>Step1 : 添加动画
Step1->>Step1_1 : 淡入背景
Step1->>Step1_2 : 将武将移入
Step1->>flick : 连接完成信号
Animation->>Step2 : 添加暂停
Step2->>flick : 连接显示信号
Animation->>Step3 : 添加暂停
Step3->>flick : 连接隐藏信号
Animation->>Step4 : 添加暂停
Step4->>flick : 连接显示信号
Animation->>Step5 : 添加缩放动画
Animation->>Step6 : 添加并行动画
Step6->>Step6_1 : 技能名缩放
Step6->>Step6_2 : 技能名淡入
Animation->>Step7 : 添加暂停
Animation->>Animation : 连接完成信号
Animation->>Animation : start()
```

**Diagram sources**
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp#L115-L177)

## 特效动画系统

`EffectAnimation`类管理各种图形特效，包括淡入淡出、强调和回送效果。

```mermaid
classDiagram
class EffectAnimation {
+QMap<QGraphicsItem*, AnimatedEffect*> effects
+QMap<QGraphicsItem*, AnimatedEffect*> registered
+void fade(QGraphicsItem* map)
+void emphasize(QGraphicsItem* map, bool stay)
+void sendBack(QGraphicsItem* map)
+void effectOut(QGraphicsItem* map)
+void deleteEffect(AnimatedEffect* effect)
}
class AnimatedEffect {
+bool stay
+int index
+void setStay(bool stay)
+void reset()
+int getIndex()
+void setIndex(int ind)
+void loop_finished()
}
class FadeEffect {
+void draw(QPainter* painter)
}
class EmphasizeEffect {
+void draw(QPainter* painter)
+QRectF boundingRectFor(QRectF sourceRect)
}
class SentbackEffect {
+QImage* grayed
+void draw(QPainter* painter)
+QRectF boundingRectFor(QRectF sourceRect)
}
EffectAnimation --> QObject : 继承
AnimatedEffect --> QGraphicsEffect : 继承
AnimatedEffect --> FadeEffect : 继承
AnimatedEffect --> EmphasizeEffect : 继承
AnimatedEffect --> SentbackEffect : 继承
EffectAnimation --> FadeEffect : 创建
EffectAnimation --> EmphasizeEffect : 创建
EffectAnimation --> SentbackEffect : 创建
```

**Diagram sources**
- [sprite.h](file://src/ui/sprite.h#L38-L105)
- [sprite.cpp](file://src/ui/sprite.cpp#L38-L83)

**Section sources**
- [sprite.h](file://src/ui/sprite.h#L38-L105)
- [sprite.cpp](file://src/ui/sprite.cpp#L38-L83)

### 特效执行流程

```mermaid
flowchart TD
Start([开始]) --> CheckEffect["检查现有特效"]
CheckEffect --> |存在| EffectOut["执行effectOut"]
CheckEffect --> |不存在| ApplyEffect["应用新特效"]
EffectOut --> DeleteRegistered["删除注册的特效"]
EffectOut --> InsertNew["插入新特效到registered"]
ApplyEffect --> CreateEffect["创建特效对象"]
CreateEffect --> SetEffect["设置图形特效"]
SetEffect --> InsertEffects["插入到effects映射"]
InsertNew --> End["完成"]
InsertEffects --> End
```

**Diagram sources**
- [sprite.cpp](file://src/ui/sprite.cpp#L38-L83)

## JavaScript与C++交互流程

虽然`page.js`文件主要用于文档生成，但项目中的JavaScript与C++交互通过Qt的脚本引擎实现。动画类通过信号槽机制与脚本层通信。

```mermaid
sequenceDiagram
participant JS as JavaScript脚本
participant Engine as Qt脚本引擎
participant Cpp as C++动画类
participant Signal as 信号系统
JS->>Engine : 调用动画函数
Engine->>Cpp : 转发调用
Cpp->>Cpp : 执行动画逻辑
Cpp->>Signal : 发出finished信号
Signal->>Engine : 通知脚本引擎
Engine->>JS : 触发回调函数
JS->>JS : 处理动画完成事件
```

**Diagram sources**
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp#L134-L174)
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp#L146-L177)

**Section sources**
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp#L134-L174)
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp#L146-L177)

## 事件绑定与动画触发

### 动画控制方法

**PixmapAnimation控制方法：**
- `start(bool permanent, int interval)`: 启动动画
- `stop()`: 停止动画
- `reset()`: 重置动画到第一帧
- `preStart()`: 预启动，显示动画并开始计时器
- `end()`: 结束动画并发出finished信号

**LightboxAnimation控制方法：**
- 通过`QSequentialAnimationGroup`管理动画序列
- 使用`connect`连接动画完成信号到`finished`槽函数
- 动画自动在完成后删除

### 事件绑定示例

```javascript
// 示例：按钮点击触发动画
button.clicked.connect(function() {
    // 创建并启动帧动画
    var animation = PixmapAnimation.GetPixmapAnimation(parent, "success", false, 2000);
    animation.start();
    
    // 连接动画完成信号
    animation.finished.connect(function() {
        console.log("动画完成");
        // 清理资源
        animation.deleteLater();
    });
});

// 示例：触发技能特效
function playSkillAnimation(generalName, skillName) {
    var animation = new LightboxAnimation(generalName, skillName, QRectF(0, 0, 800, 600));
    animation.finished.connect(function() {
        console.log("技能动画完成");
        animation.deleteLater();
    });
    // 动画启动后会自动播放
}
```

**Section sources**
- [pixmapanimation.cpp](file://src/ui/pixmapanimation.cpp#L90-L142)
- [lightboxanimation.cpp](file://src/ui/lightboxanimation.cpp#L146-L177)