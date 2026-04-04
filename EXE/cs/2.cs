/// <summary>
/// 游戏中的存档
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct PalSave
{
public ushort SavedTimes; // 存盘次数
public Pos ViewportPos; // 视口位置
public ushort MovieId; // RNG 动画编号
public ushort MemberCount; // 队伍中队员数量
public ushort SceneId; // 场景编号
public bool IsNightPalette; // 正在使用夜间调色板
public Direction TeamDirection; // 队伍面朝方向
public ushort MusicId; // 场景音乐编号
public ushort BattleMusicId; // 战斗音乐编号
public ushort BattleFieldId; // 战场编号
public ushort ScreenWave; // 屏幕波浪进度（0～255）
readonly ushort _unknown24; // 未知数据（偏移 24）
public ushort GourdEnergy; // 灵葫能量
public ushort TeamLayerOffset; // 队伍图层偏移
public EnemyChase EnemyChase; // 敌人追逐参数
public ushort FollowerCount; // 随从人员数量（跟在队伍后面的 NPC，如扬州虾蟆山书生）
fixed ushort _unknown36[3]; // 未知数据组（偏移 36）
public ushort Gold; // 金钱
public AllMembersTrailInViewport MembersTrailInViewport; // 所有队员相对于视口的步伐信息
public AllMembersTrail MembersTrail; // 所有队员的步伐信息
public AllExpEntry ExpEntrys; // 全部队员的全部经历条目
public Hero Hero; // 全部队员的基础数据
//public AllMembersPoisonStatus MembersPoisonStatus; // 所有队员的中毒状态
public AllInventories Inventories; // 所有库存项目
public AllScenes Scenes; // 所有场景
public AllEntities Entities; // 所有实体

/// <summary>
/// 获取结构体实际大小
/// </summary>
public static int Size => sizeof(PalSave) + sizeof(PalEvent) * EventCount;

/// <summary>
/// 获取所有事件的指针
/// </summary>
public static PalEvent* GetEvents(PalSave* pSave) => (PalEvent*)(pSave + sizeof(PalSave));
}

/// <summary>
/// 点坐标
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct Pos
{
public ushort X; // 横坐标
public ushort Y; // 纵坐标
}

/// <summary>
/// 块坐标
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct BlockPos
{
public ushort X; // 横坐标
public ushort Y; // 纵坐标
public bool IsEvenRow; // 是否为偶数行
}

/// <summary>
/// 敌人追逐参数（场景中的）
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct EnemyChase
{
public ushort Range; // 追逐范围
public ushort RemainingFrames; // 范围生效剩余帧数（帧数耗尽后追逐范围恢复正常）
}

/// <summary>
/// 队员步伐信息
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct MemberTrail
{
public Pos Pos; // 坐标 X, Y
public Direction Direction; // 面朝方向（下左上右 0123）
}

/// <summary>
/// 全部队员的步伐信息
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct AllMembersTrail
{
fixed ushort _data[3 * MEMBER_MAX_COUNT];

/// <summary>
/// 获取指定队员的步伐信息
/// </summary>
/// <param name="memberId">队员编号</param>
/// <returns>队员的步伐信息</returns>
public MemberTrail* this[int memberId] => &((MemberTrail*)_data[0])[memberId];
}

/// <summary>
/// 队员相对于视口的步伐信息
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct MemberTrailInViewport
{
public ushort HeroId; // 形象编号
public Pos Pos; // 队员坐标（相对于视角）
public ushort CurrentFrameId; // 当前帧编号
public ushort FrameOffset; // 形象帧偏移（原地行走 012）
}

/// <summary>
/// 全部队员相对于视口的步伐信息
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct AllMembersTrailInViewport
{
fixed ushort _data[5 * MEMBER_MAX_COUNT];

/// <summary>
/// 获取指定队员相对于视口的步伐信息
/// </summary>
/// <param name="memberId">队员编号</param>
/// <returns>指定队员相对于视口的步伐信息</returns>
public MemberTrailInViewport* this[int memberId] => &((MemberTrailInViewport*)_data[0])[memberId];
}

/// <summary>
/// 经历数据
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct ExpData
{
public ushort Exp; // 经历
readonly ushort _reserved; // 无效数据
public ushort Level; // 修行
public ushort RequiredExp; // 修行晋所需经历
}

/// <summary>
/// 全部队员的经历条目
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct ExpEntry
{
fixed ushort _data[4 * HERO_MAX_COUNT];

/// <summary>
/// 获取指定主角的经历条目
/// </summary>
/// <param name="heroId">主角编号</param>
/// <returns>主角的经历条目</returns>
public ExpData* this[int heroId] => &((ExpData*)_data[0])[heroId];
}

/// <summary>
/// 全部队员的全部经历条目
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct AllExpEntry
{
public ExpEntry Master;
public ExpEntry HP;
public ExpEntry MP;
public ExpEntry AttackPower;
public ExpEntry MagicPower;
public ExpEntry Defense;
public ExpEntry Dexterity;
public ExpEntry Flee;
}

/// <summary>
/// 主角装备
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct HeroEquipment
{
fixed ushort _data[_lenght];

const ushort _lenLow = HERO_MAX_COUNT;
const ushort _lenHigh = HERO_MAX_EQUIPMENT_COUNT;
const ushort _lenght = _lenLow * _lenHigh;

public ushort this[int heroId, int equipmentId]
{
get
{
S.CheckoutArrayIndex2(_lenHigh, ref equipmentId, _lenLow, ref heroId);

return _data[equipmentId * _lenLow + heroId];
}
set
{
S.CheckoutArrayIndex2(_lenHigh, ref equipmentId, _lenLow, ref heroId);

_data[equipmentId * _lenLow + heroId] = value;
}
}
}

/// <summary>
/// 主角五维
/// </summary>

[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct HeroAttribute
{
public fixed short AttackStrength[HERO_MAX_COUNT]; // 武术
public fixed short MagicStrength[HERO_MAX_COUNT]; // 灵力
public fixed short Defense[HERO_MAX_COUNT]; // 防御
public fixed short Dexterity[HERO_MAX_COUNT]; // 身法
public fixed short FleeRate[HERO_MAX_COUNT]; // 吉运
}

/// <summary>
/// 主角五灵抗性
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct ElementalResistance
{
fixed short _data[_lenght];

const ushort _lenLow = HERO_MAX_COUNT;
const ushort _lenHigh = MAGIC_ELEMENTAL_COUNT;
const ushort _lenght = _lenLow * _lenHigh;

public short this[int heroId, int elementId]
{
get
{
S.CheckoutArrayIndex2(_lenHigh, ref elementId, _lenLow, ref heroId);

return _data[elementId * _lenLow + heroId];
}
set
{
S.CheckoutArrayIndex2(_lenHigh, ref elementId, _lenLow, ref heroId);

_data[elementId * _lenLow + heroId] = value;
}
}
}

/// <summary>
/// 主角仙术
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct HeroMagic
{
fixed short _data[_lenght];

const short _lenLow = HERO_MAX_COUNT;
const short _lenHigh = HERO_MAX_MAGIC_COUNT;
const short _lenght = _lenLow * _lenHigh;

public short this[int heroId, int magicId]
{
get
{
S.CheckoutArrayIndex2(_lenHigh, ref magicId, _lenLow, ref heroId);

return _data[magicId * _lenLow + heroId];
}
set
{
S.CheckoutArrayIndex2(_lenHigh, ref magicId, _lenLow, ref heroId);

_data[magicId * _lenLow + heroId] = value;
}
}
}

/// <summary>
/// 主角基础数据
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct Hero
{
public fixed ushort AvatarId[HERO_MAX_COUNT]; // 肖像（显示于状态页面和对话框）
public fixed ushort SpriteIdInBattle[HERO_MAX_COUNT]; // 战斗形象（在 F.MKF）
public fixed ushort SpriteId[HERO_MAX_COUNT]; // 行走形象（在 MGO.MKF）
public fixed ushort Name[HERO_MAX_COUNT]; // 实体名称（在 WORD.DAT）
public fixed ushort AttackAll[HERO_MAX_COUNT]; // 普攻可攻击敌方全体
fixed ushort _unknown1[HERO_MAX_COUNT]; // 未知数据 1
public fixed ushort Level[HERO_MAX_COUNT]; // 修行
public fixed ushort MaxHP[HERO_MAX_COUNT]; // 最大体力
public fixed ushort MaxMP[HERO_MAX_COUNT]; // 最大真气
public fixed ushort HP[HERO_MAX_COUNT]; // 当前体力
public fixed ushort MP[HERO_MAX_COUNT]; // 当前真气
public HeroEquipment Equipment; // 装备
public HeroAttribute Attribute; // 五维（武灵防速逃）
public fixed short PoisonResistance[HERO_MAX_COUNT]; // 毒抗
public ElementalResistance ElementalResistance; // 灵抗
fixed ushort _unknown2[HERO_MAX_COUNT]; // 未知数据 2
fixed ushort _unknown3[HERO_MAX_COUNT]; // 未知数据 3
fixed ushort _unknown4[HERO_MAX_COUNT]; // 未知数据 4
public fixed ushort CoveredBy[HERO_MAX_COUNT]; // 虚弱时受谁援护
public HeroMagic Magic; // 已领悟的仙术
public fixed ushort FramesPerDirection[HERO_MAX_COUNT]; // 行走形象每个方向的帧计数
public fixed short CooperativeMagic[HERO_MAX_COUNT]; // 合体法术
fixed ushort _unknown5[HERO_MAX_COUNT]; // 未知数据 5
fixed ushort _unknown6[HERO_MAX_COUNT]; // 未知数据 6
public fixed ushort DeathSound[HERO_MAX_COUNT]; // 阵亡音效
public fixed ushort AttackSound[HERO_MAX_COUNT]; // 普攻音效
public fixed ushort WeaponSound[HERO_MAX_COUNT]; // 武器挥砍音效
public fixed ushort CriticalSound[HERO_MAX_COUNT]; // 普攻暴击音效
public fixed ushort MagicSound[HERO_MAX_COUNT]; // 施法音效
public fixed ushort CoverSound[HERO_MAX_COUNT]; // 武器格挡音效
public fixed ushort DyingSound[HERO_MAX_COUNT]; // 濒死音效
}

/// <summary>
/// 库存
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct Inventory
{
public ushort IteamId; // 道具对象编号
public ushort CurrentCount; // 现有数量
public ushort CurrentRoundUseCount; // 本回合预计使用数量
}

/// <summary>
/// 全部库存
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct AllInventories
{
fixed ushort _data[3 * INVENTORY_MAX_COUNT];

/// <summary>
/// 获取指定仓库项目
/// </summary>
/// <param name="inventoryId">仓库项目编号</param>
/// <returns>指定仓库项目</returns>
public Inventory* this[int inventoryId] => &((Inventory*)_data[0])[inventoryId];
}

/// <summary>
/// 场景
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct PalScene
{
public ushort MapId; // 实际地图
public ScenesScript Script; // 脚本：进入场景
public ushort EventObjectIndex; // 事件起始索引，实际索引为（EventObjectIndex + 1）
}

/// <summary>
/// 场景脚本
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct ScenesScript
{
public ushort Enter; // 脚本：进入场景
public ushort Teleport; // 脚本：脱离场景（引路蜂、土灵珠）
}

/// <summary>
/// 全部场景
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct AllScenes
{
fixed ushort _data[4 * SCENE_MAX_COUNT];

/// <summary>
/// 获取指定场景
/// </summary>
/// <param name="sceneId">场景编号</param>
/// <returns>指定场景</returns>
public PalScene* this[int sceneId] => &((PalScene*)_data[0])[sceneId];
}

/// <summary>
/// 主角实体对象
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct CoreHero
{
fixed ushort _reserved[2]; // 无效数据
public ushort ScriptOnFriendDeath; // 友方阵亡脚本
public ushort ScriptOnDying; // 濒死脚本
}

/// <summary>
/// 道具实体对象
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct CoreItem
{
public ushort BitmapId; // 图像（在 BALL.MKF）
public ushort Price; // 售价（典当半价）
public ushort ScriptOnUse; // 使用脚本
public ushort ScriptOnEquip; // 装备脚本
public ushort ScriptOnThrow; // 投掷脚本
public ushort ScriptDesc; // 描述脚本
public ItemMask Flags; // 二进制掩码参数
}

/// <summary>
/// 仙术实体对象
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct CoreMagic
{
public ushort MagicDataId; // 仙术基础数据（在 DATA.MKF #3）
readonly ushort _reserved; // 无效数据
public ushort ScriptOnSuccess; // 后序脚本，前序脚本成功后执行
public ushort ScriptOnUse; // 前序脚本
readonly ushort _reserved2; // 无效数据
public ushort ScriptDesc; // 描述脚本
public MagicMask Flags; // 二进制掩码参数
}

/// <summary>
/// 敌人实体对象
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct CoreEnemy
{
public ushort EnemyDataId; // 敌方基础数据（在 DATA.MKF #1）
// 同时也代表敌方图像（在 ABC.MKF）
public short ResistanceToSorcery; // 巫抗（0～10）
public ushort ScriptOnTurnStart; // 回合开始脚本
public ushort ScriptOnBattleWon; // 战斗结算脚本
public ushort ScriptOnAction; // 回合行动脚本（出招脚本）
}

/// <summary>
/// 毒性实体对象
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct CorePoison
{
public ushort Level; // 级别/烈度
public ushort Color; // 肖像颜色
public ushort PlayerScript; // 我方中毒脚本（每次回合结束执行）
readonly ushort _reserved; // 无效数据
public ushort EnemyScript; // 敌方中毒脚本（每次回合结束执行）
}

/// <summary>
/// 实体对象
/// </summary>
[StructLayout(LayoutKind.Explicit, Pack = 1)]
public struct CoreEntity
{
[FieldOffset(0)]
fixed ushort _undefined[7];

[FieldOffset(0)]
public CoreHero Hero;

[FieldOffset(0)]
public CoreItem Item;

[FieldOffset(0)]
public CoreMagic Magic;

[FieldOffset(0)]
public CoreEnemy Enemy;

[FieldOffset(0)]
public CorePoison Poison;
}

/// <summary>
/// 全部实体对象
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct AllEntities
{
fixed ushort _data[4 * ENTITY_MAX_COUNT];

/// <summary>
/// 获取指定实体对象
/// </summary>
/// <param name="sceneId">实体对象编号</param>
/// <returns>指定实体对象</returns>
public CoreEntity* this[int sceneId] => &((CoreEntity*)_data[0])[sceneId];
}

/// <summary>
/// 事件
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct PalEvent
{
public short VanishTime; // 正数为剩余隐匿帧数，负数为逃跑后僵直帧数（一般为战斗事件）
public short X; // X 坐标
public short Y; // Y 坐标
public short Layer; // 图层
public ushort TriggerScript; // 触发脚本
public ushort AutoScript; // 自动脚本
public EventState State; // 触发状态
public EventTriggerMode TriggerMode; // 触发模式
public ushort SpriteId; // 形象
public ushort FramesPerDirection; // 形象每个方向的帧数
public Direction Direction; // 当前面朝方向
public ushort CurrentFrameId; // 当前帧数（当前方向上的）
public ushort TriggerIdleFrame; // 触发脚本累计被触发次数
readonly ushort _unknown; // 未知数据
readonly ushort _spriteFramesAuto; // 形象总帧数（自动计算，只在内存中有意义）
public ushort AutoIdleFrame; // 自动脚本累计被触发次数
}

[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct Script
{
public ushort Command;
public fixed ushort Args[3];
}

[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct ScriptArgs
{
readonly ushort Value;

public readonly short Short => (short)Value;
public readonly ushort UShort => Value;
public readonly bool Bool => UShort != 0;
//public readonly string Dialog => PalMessage.GetDialogue(UShort);
public readonly bool TriggerMode => UShort >= (ushort)EventTriggerMode.TouchNear;
public readonly ushort TriggerRange => (ushort)(TriggerMode ? (UShort - (ushort)EventTriggerMode.TouchNear + 1) : UShort);
public readonly (bool, ushort) EventTrigger => (TriggerMode, TriggerRange);
}

/// <summary>
/// 调色板（昼/夜）
/// </summary>
public class PalP
public const int
INVENTORY_MAX_COUNT = 256,
MEMBER_MAX_COUNT = 5,
HERO_MAX_COUNT = 6,
HERO_MAX_EQUIPMENT_COUNT = 6,
HERO_MAX_MAGIC_COUNT = 32,
MAGIC_ELEMENTAL_COUNT = 5,
ENTITY_MAX_COUNT = 600,
SCENE_MAX_COUNT = 300;

/// <summary>
/// 方向
/// </summary>
public enum Direction : short
{
Current = -1, // 当前方向
Southwest = 0, // 西南（左下）
Northwest = 1, // 西北（左上）
Northeast = 2, // 东北（右上）
Southeast = 3, // 东南（右下）
}

/// <summary>
/// 事件状态
/// </summary>
public enum EventState : short
{
Hidden = 0, // 隐藏
NonObstacle = 1, // 漂浮
Obstacle = 2, // 障碍（阻碍领队通过）
}

/// <summary>
/// 事件触发模式
/// </summary>
public enum EventTriggerMode : ushort
{
None = 0, // 无法触发
SearchNear = 1, // 手动触发，范围 1（须脸贴或重合，大部分道具的获取方式）
SearchNormal = 2, // 手动触发，范围 3
SearchFar = 3, // 手动触发，范围 5
TouchNear = 4, // 自动触发，范围 0（须重合，如将军冢石板机关）
TouchNormal = 5, // 自动触发，范围 1
TouchFar = 6, // 自动触发，范围 2
TouchFarther = 7, // 自动触发，范围 3
TouchFarthest = 8, // 自动触发，范围 4
}

/// <summary>
/// 道具掩码
/// </summary>
public enum ItemMask : ushort
{
Usable = (1 << 0), // 可使用
Equipable = (1 << 1), // 可装备
Throwable = (1 << 2), // 可投掷
Consuming = (1 << 3), // 使用后减少
SkipTargetSelection = (1 << 4), // 跳过目标选择（无需选择目标）
Sellable = (1 << 5), // 可典当
EquipableByHeroFirst = (1 << 6), // 李逍遥可装备（后面省略了剩下的 Hero）
}

/// <summary>
/// 仙术掩码
/// </summary>
public enum MagicMask : ushort
{
UsableOutsideBattle = (1 << 0), // 战外可用
UsableInBattle = (1 << 1), // 战斗可用
UsableToEnemy = (1 << 3), // 作用于敌方
SkipTargetSelection = (1 << 4), // 跳过目标选择（无需选择目标）
}

/// <summary>
/// 敌方战斗时的临时数据
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct REnemyBattleTempData
{
public short EnemyBaseDataId; // 基础数据编号（在 DATA.MKF#1）
public RPos Pos; // 当前在战场上的坐标 XY
public RPos OriginPos; // 初始坐标 XY（备份，行动后归位用）
public short CurrentFrameId; // 当前帧编号（实时渲染时用）
readonly short _unkown6; // ？？？
readonly short _unkown7; // ？？？（和帧编号相关）
readonly short _unkown8; // ？？？
public short HP; // 剩余 HP
public TasEnemys EnemyId; // 敌人实体编号
public Entity.REnemyScript Script; // 各种脚本
}

/// <summary>
/// 我方战斗时的临时数据
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct RMemberBattleTempData
{
public ushort SpriteId; // 战斗形象编号（在 F.MKF）
public RPos Pos; // 当前在战场上的坐标 XY
readonly short _unkown3; // ？？？
public RPos OriginPos; // 初始坐标 XY（备份，行动后归位用）
public short CurrentFrameId; // 当前帧编号（实时渲染时用）
public short BakupFrameId; // 帧编号备份（为 2 则清除刚阵亡的状态）
readonly short _unkown8; // ？？？
readonly short _unkown9; // ？？？
readonly short _unkown10; // ？？？
public TasMagics CooperativeMagicId; // 合体法术编号
}

/// <summary>
/// 我方当前回合的动作
/// </summary>
[StructLayout(LayoutKind.Explicit, Pack = 2)]
public struct RMemberRoundActionEntity
{
[FieldOffset(0)]
public short RawValue; // 原生数值
[FieldOffset(0)]
public TasItems ItemId; // 道具编号
[FieldOffset(0)]
public TasMagics MagicId; // 仙术编号
}

/// <summary>
/// 我方死亡状态
/// </summary>
public enum TasMemberStateOfDeath : short
{
刚死亡 = -1,
正常 = 0,
}

/// <summary>
/// 我方队员当前回合的动作
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 2)]
public struct RMemberRoundAction
{
public TasTargetOfAttack TargetOfAttack; // 作用目标编号
public TasMemberActions MemberAction; // 实际动作
public RMemberRoundActionEntity EntityId; // 使用的仙术/道具实体编号
public ushort MenuCursorId; // 使用的实体是仙术/道具菜单中的第几个
public TasMemberStateOfDeath StateOfDeath; // 是否刚刚阵亡（这会触发死亡对话）
}

/// <summary>
/// 回合动作快捷键（自定义的，内存里没有这个东西）
/// </summary>
public class RShortcutKeyRoundAction
{
public TasBattleFighter FighterId; // 从哪个队员开始按下
public TasActionShortcutKeys Key; // 按下行动快捷键
}


public const int
MAX_HERO_COUNT = 6,
MAX_MEMBER_COUNT = MAX_HERO_COUNT - 1,
MAX_MEMBER_IN_TEAM_COUNT = 3,
MAX_ENEMY_COUNT = 5,
MAX_INVENTORY = 256,
MAX_HERO_EQUIPMENT_COUNT = 6,
MAX_HERO_BATTLE_EQUIPMENT_COUNT = MAX_HERO_EQUIPMENT_COUNT + 1;

/// <summary>
/// 方向枚举
/// </summary>
public enum TasDirection : short
{
Current = -1, // 当前
Down = 0, // 下
Left = 1, // 左
Up = 2, // 上
Right = 3, // 右
}

/// <summary>
/// 装备部位
/// </summary>
public enum TasEquipType : ushort
{
头戴 = 0, // 头戴
披挂 = 1, // 披挂
身穿 = 2, // 身穿
手持 = 3, // 手持
脚穿 = 4, // 脚穿
佩带 = 5, // 佩带
临时 = 6, // 临时
}

/// <summary>
/// 装备效果部位
/// </summary>
public enum TasEquipEffectType : ushort
{
头戴 = 0x000B, // 头戴
披挂 = 0x000C, // 披挂
身穿 = 0x000D, // 身穿
手持 = 0x000E, // 手持
脚穿 = 0x000F, // 脚穿
佩带 = 0x0010, // 佩带
临时 = 0x0011, // 临时
}

/// <summary>
/// 英雄临时属性
/// </summary>
public enum TasHeroExtraAttribute : ushort
{
武术 = 0,
灵力 = 1,
防御 = 2,
身法 = 3,
吉运 = 4,
避毒率 = 5,
避风率 = 6,
避雷率 = 7,
避水率 = 8,
避火率 = 9,
避土率 = 10,
}

/// <summary>
/// 角色属性
/// </summary>
public enum TasHeroAttribute : ushort
{
肖像 = 0,
战斗形象 = 1,
行走形象 = 2,
名称编号 = 3,
普攻全体 = 4,
修行 = 6,
最大体力 = 7,
最大真气 = 8,
体力 = 9,
真气 = 10,
头戴 = 11,
披挂 = 12,
身穿 = 13,
手持 = 14,
脚穿 = 15,
佩带 = 16,
武术 = 17,
灵力 = 18,
防御 = 19,
身法 = 20,
吉运 = 21,
避毒率 = 22,
避风率 = 23,
避雷率 = 24,
避水率 = 25,
避火率 = 26,
避土率 = 27,
濒死时援助我者编号 = 31,
仙术1 = 32,
仙术2 = 33,
仙术3 = 34,
仙术4 = 35,
仙术5 = 36,
仙术6 = 37,
仙术7 = 38,
仙术8 = 39,
仙术9 = 40,
仙术10 = 41,
仙术11 = 42,
仙术12 = 43,
仙术13 = 44,
仙术14 = 45,
仙术15 = 46,
仙术16 = 47,
仙术17 = 48,
仙术18 = 49,
仙术19 = 50,
仙术20 = 51,
仙术21 = 52,
仙术22 = 53,
仙术23 = 54,
仙术24 = 55,
仙术25 = 56,
仙术26 = 57,
仙术27 = 58,
仙术28 = 59,
仙术29 = 60,
仙术30 = 61,
仙术31 = 62,
仙术32 = 63,
行走形象每方向帧数 = 64,
合体法术 = 65,
阵亡呻吟音效 = 66,
普攻呐喊音效 = 67,
武器挥砍音效 = 68,
暴击呐喊音效 = 69,
施法集气呐喊音效 = 70,
武器格挡音效 = 67,
濒死呻吟音效 = 68,
}

/// <summary>
/// 实际可用的正派角色
/// </summary>
public enum TasHero : ushort
{
李逍遥 = 0,
赵灵儿 = 1,
林月如 = 2,
巫后 = 3,
阿奴 = 4,
盖罗娇 = 5,
}

/// <summary>
/// 方向枚举
/// </summary>
public enum TasTargetOfAttack : short
{
All = -1, // 全体目标
_0 = 0, // 目标 0
_1 = 1, // 目标 1
_2 = 2, // 目标 2
_3 = 3, // 目标 3
_4 = 4, // 目标 4
First = _0, // 首名人员
Last = _4, // 最后一名人员
}

/// <summary>
/// 我方每回合可选的动作
/// </summary>
public enum TasMemberActions : short
{
NULL = -1, // 什么都不干（阵亡、定身、昏眠）
普攻 = 0, // 普攻
防守仙术 = 1, // 作用于我方的仙术
进攻仙术 = 2, // 作用于敌方的仙术
使用道具 = 3, // 使用道具
投掷道具 = 4, // 投掷道具
防御 = 5, // 防御
围攻 = 6, // 围攻
合体法术 = 7, // 合体法术（会被后者的替换掉，后者优先）
逃跑 = 8, // 逃跑
封魔普攻队友 = 9, // 封魔普攻队友
普攻敌方全体 = 10, // 普攻敌方全体
}

/// <summary>
/// 我方每回合可选的动作
/// </summary>
public enum TasActionShortcutKeys
{
NULL = 0, // NULL
围攻 = VK.VK_A, // 围攻 A
防御 = VK.VK_D, // 防御 D
逃跑 = VK.VK_Q, // 逃跑 Q
强攻 = VK.VK_F, // 强攻 F
重复 = VK.VK_R, // 重复 R
}

/// <summary>
/// 战斗中阵营人员的编号
/// </summary>
public enum TasBattleFighter : short
{
_0 = 0, // 人员 1
_1 = 1, // 人员 2
_2 = 2, // 人员 3
_3 = 3, // 人员 4
_4 = 4, // 人员 5
First = _0, // 首名人员
Last = _4, // 最后一名人员
NULL = short.MaxValue, // 无效人员
}

/// <summary>
/// 战斗中的阵营
/// </summary>
public enum TasBattleTeam : short
{
NULL = -2, // NULL
敌方 = -1, // 敌方阵营
我方 = 0, // 我方阵营
}

public enum TasSpecialStatus : ushort
{
封魔 = 0, // 敌我不分，但只普攻
定身 = 1, // 你就站在此地不要走动
昏眠 = 2, // 这年轻人，倒头就睡
锁脉 = 3, // 咒封，我方撤回了一发酒神
傀儡 = 4, // 死者短暂复活，但只普攻
力拔山河 = 5, // 天罡战气，必定触发 3 段暴击
坚如磐石 = 6, // 真元护体，必定触发 2 段防御
身轻如燕 = 7, // 仙风云体术，快速结印，必定触发 3 段速度
动若脱兔 = 8, // 醉仙望月步，普攻时连续攻击两次
}

/// <summary>
/// 道具（WORD.DAT 内容，实体对象的名称，连续结构，每 10 个字节为一项）
/// </summary>
public enum TasItems : short
{
NULL = -1,
观音符 = 0x003D,
圣灵符 = 0x003E,
金刚符 = 0x003F,
净衣符 = 0x0040,
灵心符 = 0x0041,
天师符 = 0x0042,
风灵符 = 0x0043,
雷灵符 = 0x0044,
水灵符 = 0x0045,
火灵符 = 0x0046,
土灵符 = 0x0047,
舍利子 = 0x0048,
玉菩提 = 0x0049,
银杏子 = 0x004A,
糯米 = 0x004B,
糯米糕 = 0x004C,
盐巴 = 0x004D,
茶叶蛋 = 0x004E,
鸡蛋 = 0x004F,
糖葫芦 = 0x0050,
蜡烛 = 0x0051,
符纸 = 0x0052,
檀香 = 0x0053,
大蒜 = 0x0054,
黑狗血 = 0x0055,
酒 = 0x0056,
雄黄 = 0x0057,
雄黄酒 = 0x0058,
九节菖蒲 = 0x0059,
驱魔香 = 0x005A,
十里香 = 0x005B,
水果 = 0x005C,
烧肉 = 0x005D,
腌肉 = 0x005E,
还魂香 = 0x005F,
赎魂灯 = 0x0060,
孟婆汤 = 0x0061,
天香续命露 = 0x0062,
止血草 = 0x0063,
行军丹 = 0x0064,
金创药 = 0x0065,
蟠果 = 0x0066,
紫菁玉蓉膏 = 0x0067,
鼠儿果 = 0x0068,
还神丹 = 0x0069,
龙涎草 = 0x006A,
灵山仙芝 = 0x006B,
雪莲子 = 0x006C,
天仙玉露 = 0x006D,
神仙茶 = 0x006E,
灵葫仙丹 = 0x006F,
试炼果 = 0x0070,
女娲石 = 0x0071,
八仙石 = 0x0072,
蜂巢 = 0x0073,
尸腐肉 = 0x0074,
毒蛇卵 = 0x0075,
毒蝎卵 = 0x0076,
毒蟾卵 = 0x0077,
蜘蛛卵 = 0x0078,
蜈蚣卵 = 0x0079,
鹤顶红 = 0x007A,
孔雀胆 = 0x007B,
血海棠 = 0x007C,
断肠草 = 0x007D,
醍醐香 = 0x007E,
忘魂花 = 0x007F,
紫罂粟 = 0x0080,
鬼枯藤 = 0x0081,
腹蛇涎 = 0x0082,
蜂王蜜 = 0x0083,
雪蛤蟆 = 0x0084,
赤蝎粉 = 0x0085,
化尸水 = 0x0086,
迷魂香 = 0x0087,
九阴散 = 0x0088,
无影毒 = 0x0089,
三尸蛊 = 0x008A,
金蚕蛊 = 0x008B,
幻蛊 = 0x008C,
隐蛊 = 0x008D,
冰蚕蛊 = 0x008E,
火蚕蛊 = 0x008F,
食妖虫 = 0x0090,
灵蛊 = 0x0091,
爆烈蛊 = 0x0092,
碧血蚕 = 0x0093,
蛊 = 0x0094,
赤血蚕 = 0x0095,
金蚕王 = 0x0096,
引路蜂 = 0x0097,
傀儡虫 = 0x0098,
梅花镖 = 0x0099,
袖里剑 = 0x009A,
透骨钉 = 0x009B,
雷火珠 = 0x009C,
毒龙砂 = 0x009D,
吸星锁 = 0x009E,
缠魂丝 = 0x009F,
捆仙绳 = 0x00A0,
无影神针 = 0x00A1,
血玲珑 = 0x00A2,
长鞭 = 0x00A3,
九截鞭 = 0x00A4,
金蛇鞭 = 0x00A5,
木剑 = 0x00A6,
短刀 = 0x00A7,
铁剑 = 0x00A8,
大刀 = 0x00A9,
仙女剑 = 0x00AA,
长剑 = 0x00AB,
红缨刀 = 0x00AC,
越女剑 = 0x00AD,
戒刀 = 0x00AE,
玄铁剑 = 0x00AF,
芙蓉刀 = 0x00B0,
柳月刀 = 0x00B1,
青锋剑 = 0x00B2,
苗刀 = 0x00B3,
凤鸣刀 = 0x00B4,
双龙剑 = 0x00B5,
玉女剑 = 0x00B6,
金童剑 = 0x00B7,
龙泉剑 = 0x00B8,
鬼牙刀 = 0x00B9,
七星剑 = 0x00BA,
玄冥宝刀 = 0x00BB,
巫月神刀 = 0x00BC,
磐龙剑 = 0x00BD,
太极剑 = 0x00BE,
无尘剑 = 0x00BF,
青蛇杖 = 0x00C0,
鬼头杖 = 0x00C1,
冥蛇杖 = 0x00C2,
天蛇杖 = 0x00C3,
头巾 = 0x00C4,
青丝巾 = 0x00C5,
发饰 = 0x00C6,
银钗 = 0x00C7,
翠玉金钗 = 0x00C8,
皮帽 = 0x00C9,
珍珠冠 = 0x00CA,
天师帽 = 0x00CB,
紫金冠 = 0x00CC,
天蚕丝带 = 0x00CD,
凤凰羽毛 = 0x00CE,
冲天冠 = 0x00CF,
布袍 = 0x00D0,
藤甲 = 0x00D1,
丝衣 = 0x00D2,
铁锁衣 = 0x00D3,
夜行衣 = 0x00D4,
青铜甲 = 0x00D5,
罗汉袍 = 0x00D6,
铁鳞甲 = 0x00D7,
天师道袍 = 0x00D8,
精铁战甲 = 0x00D9,
金缕衣 = 0x00DA,
鬼针胄 = 0x00DB,
天蚕宝衣 = 0x00DC,
青龙宝甲 = 0x00DD,
白虎之铠 = 0x00DE,
玄武战袍 = 0x00DF,
朱雀战衣 = 0x00E0,
披风 = 0x00E1,
护肩 = 0x00E2,
武士披风 = 0x00E3,
护心镜 = 0x00E4,
霓虹羽衣 = 0x00E5,
菩提袈裟 = 0x00E6,
虎纹披风 = 0x00E7,
凤纹披风 = 0x00E8,
龙纹披风 = 0x00E9,
圣灵披风 = 0x00EA,
草鞋 = 0x00EB,
木鞋 = 0x00EC,
布靴 = 0x00ED,
绣花鞋 = 0x00EE,
铁履 = 0x00EF,
武僧靴 = 0x00F0,
鹿皮靴 = 0x00F1,
疾风靴 = 0x00F2,
莲花靴 = 0x00F3,
虎皮靴 = 0x00F4,
龙鳞靴 = 0x00F5,
步云靴 = 0x00F6,
魅影神靴 = 0x00F7,
香袋 = 0x00F8,
护腕 = 0x00F9,
铁护腕 = 0x00FA,
竹笛 = 0x00FB,
珍珠 = 0x00FC,
玉镯 = 0x00FD,
念珠 = 0x00FE,
银针 = 0x00FF,
铜镜 = 0x0100,
八卦镜 = 0x0101,
乾坤镜 = 0x0102,
豹牙手环 = 0x0103,
圣灵珠 = 0x0104,
金罡珠 = 0x0105,
五毒珠 = 0x0106,
风灵珠 = 0x0107,
雷灵珠 = 0x0108,
水灵珠 = 0x0109,
火灵珠 = 0x010A,
土灵珠 = 0x010B,
炼蛊皿 = 0x010C,
寿葫芦 = 0x010D,
紫金葫芦 = 0x010E,
布包 = 0x010F,
桂花酒 = 0x0110,
紫金丹 = 0x0111,
玉佛珠 = 0x0112,
金凤凰蛋壳 = 0x0113,
火眼麒麟角 = 0x0114,
青龙碧血玉 = 0x0115,
毒龙胆 = 0x0116,
破天锤 = 0x0117,
包袱 = 0x0118,
银杏果 = 0x0119,
鲤鱼 = 0x011A,
鹿茸 = 0x011B,
钓竿 = 0x011C,
捕兽夹 = 0x011D,
六神丹 = 0x011E,
情书 = 0x011F,
玉佩 = 0x0120,
石钥匙 = 0x0121,
天书 = 0x0122,
香蕉 = 0x0123,
凤纹手绢 = 0x0124,
手卷 = 0x0125,
芦苇漂 = 0x0126,
}

/// <summary>
/// 法术（WORD.DAT 内容）
/// </summary>
public enum TasMagics : short
{
NULL = -1,
梦蛇 = 0x0127,
气疗术 = 0x0128,
观音咒 = 0x0129,
凝神归元 = 0x012A,
元灵归心术 = 0x012B,
五气朝元 = 0x012C,
还魂咒 = 0x012D,
赎魂 = 0x012E,
回梦 = 0x012F,
夺魂 = 0x0130,
鬼降 = 0x0131,
净衣咒 = 0x0132,
冰心诀 = 0x0133,
灵血咒 = 0x0134,
金刚咒 = 0x0135,
真元护体 = 0x0136,
天罡战气 = 0x0137,
风咒 = 0x0138,
旋风咒 = 0x0139,
风卷残云 = 0x013A,
风神 = 0x013B,
雷咒 = 0x013C,
五雷咒 = 0x013D,
天雷破 = 0x013E,
狂雷 = 0x013F,
雷神 = 0x0140,
冰咒 = 0x0141,
玄冰咒 = 0x0142,
风雪冰天 = 0x0143,
风雪冰天1 = 0x0144,
雪妖 = 0x0145,
火术 = 0x0146,
炎咒 = 0x0147,
三昧真火 = 0x0148,
炎杀咒 = 0x0149,
炼狱真火 = 0x014A,
火龙 = 0x014B,
土咒 = 0x014C,
飞岩术 = 0x014D,
地裂天崩 = 0x014E,
泰山压顶 = 0x014F,
山神 = 0x0150,
气剑指 = 0x0151,
弦月斩 = 0x0152,
弦月斩1 = 0x0153,
一阳指 = 0x0154,
七诀剑气 = 0x0155,
斩龙诀 = 0x0156,
暗器 = 0x0157,
铜钱镖 = 0x0158,
御剑术 = 0x0159,
万剑诀 = 0x015A,
心剑合一 = 0x015B,
天剑 = 0x015C,
天师符法 = 0x015D,
斩魔刀 = 0x015E,
武神 = 0x015F,
三尸咒 = 0x0160,
御蜂术 = 0x0161,
万蚁蚀象 = 0x0162,
天女散花 = 0x0163,
剑气 = 0x0164,
炼狱爪 = 0x0165,
血魔神功 = 0x0166,
狂风术 = 0x0167,
鞭击 = 0x0168,
御剑伏魔 = 0x0169,
御剑伏魔1 = 0x016A,
剑神 = 0x016B,
风灵符法 = 0x016C,
雷灵符法 = 0x016D,
水灵符法 = 0x016E,
火灵符法 = 0x016F,
土灵符法 = 0x0170,
气吞天下 = 0x0171,
酒神 = 0x0172,
瘴气 = 0x0173,
万蛊蚀天 = 0x0174,
毒吞天下 = 0x0175,
爆炸蛊 = 0x0176,
镇天鼎 = 0x0177,
咒蛇 = 0x0178,
飞龙探云手 = 0x0179,
火龙掌 = 0x017A,
灭绝一击 = 0x017B,
横扫千军 = 0x017C,
爆炸 = 0x017D,
魔掌天下 = 0x017E,
佛法无边 = 0x017F,
灵葫咒 = 0x0180,
气魔焰 = 0x0181,
合体气功 = 0x0182,
气功 = 0x0183,
剑气斩 = 0x0184,
火神 = 0x0185,
醉仙望月步 = 0x0186,
投掷 = 0x0187,
金蝉脱壳 = 0x0188,
仙风云体术 = 0x0189,
乾坤一掷 = 0x018A,
大咒蛇 = 0x018B,
腥风血雨 = 0x018C,
群魔乱舞 = 0x018D,
}

/// <summary>
/// 敌人（WORD.DAT 内容）
/// </summary>
public enum TasEnemys : ushort
{
史莱姆 = 0x018E,
灯笼 = 0x018F,
黑毛球 = 0x0190,
烂香菇 = 0x0191,
凤梨小妖 = 0x0192,
蜜蜂 = 0x0193,
蛹 = 0x0194,
小鱼 = 0x0195,
血口虫 = 0x0196,
开膛鬼 = 0x0197,
半截僵尸 = 0x0198,
菜刀婆婆 = 0x0199,
小土鬼 = 0x019A,
跳蚤 = 0x019B,
小蜘蛛 = 0x019C,
石鬼头 = 0x019D,
镰刀鼬 = 0x019E,
酒瓮 = 0x019F,
芒刺鬼 = 0x01A0,
猪头人 = 0x01A1,
小雷公 = 0x01A2,
僵尸 = 0x01A3,
跳跳蛙 = 0x01A4,
大手 = 0x01A5,
怪老子 = 0x01A6,
树根 = 0x01A7,
小独角 = 0x01A8,
青鬼 = 0x01A9,
蜥蜴 = 0x01AA,
红鬼 = 0x01AB,
公背婆 = 0x01AC,
傻仔龟 = 0x01AD,
短腿章鱼 = 0x01AE,
大蝌蚪 = 0x01AF,
蚌壳 = 0x01B0,
飞头 = 0x01B1,
肥肥 = 0x01B2,
六脚蜘蛛 = 0x01B3,
伏地罗汉 = 0x01B4,
海螺女 = 0x01B5,
魔兽武士 = 0x01B6,
连体妖 = 0x01B7,
刑天 = 0x01B8,
扫把 = 0x01B9,
黄衣刀僧 = 0x01BA,
罗汉腿 = 0x01BB,
醉罗汉 = 0x01BC,
血云雾 = 0x01BD,
哈将 = 0x01BE,
金锤武士 = 0x01BF,
巨斧武士 = 0x01C0,
角力士 = 0x01C1,
枪卒 = 0x01C2,
红衣喇嘛 = 0x01C3,
白无常 = 0x01C4,
灰衣喇嘛 = 0x01C5,
刀手 = 0x01C6,
铁叉牛头 = 0x01C7,
猩猩 = 0x01C8,
双节棍苗 = 0x01C9,
小苗女 = 0x01CA,
小巫师 = 0x01CB,
长鞭苗女 = 0x01CC,
蛟龙 = 0x01CD,
树妖 = 0x01CE,
麒麟 = 0x01CF,
凤凰 = 0x01D0,
金蟾 = 0x01D1,
牛鬼 = 0x01D2,
瘟神 = 0x01D3,
蝶精彩依 = 0x01D4,
狐狸精 = 0x01D5,
牡丹精 = 0x01D6,
玩蛇女 = 0x01D7,
僵尸王 = 0x01D8,
赤鬼王 = 0x01D9,
木灵道士 = 0x01DA,
剑护院 = 0x01DB,
锤护院 = 0x01DC,
小双钩 = 0x01DD,
女飞贼_81 = 0x01DE, // 原81号（第一处）
女飞贼_82 = 0x01DF, // 原81号（重复，改为82）
林月如一 = 0x01E0,
暗器手 = 0x01E1,
智杖和尚 = 0x01E2,
林月如二 = 0x01E3,
食人兽 = 0x01E4,
胖苗 = 0x01E5,
半人蛇 = 0x01E6,
赤色小蛇 = 0x01E7,
绿色小蛇 = 0x01E8,
老虎 = 0x01E9,
五毒巨蝎 = 0x01EA,
五毒巨蛇 = 0x01EB,
五毒蜈蚣 = 0x01EC,
青兽人 = 0x01ED,
剑老头 = 0x01EE,
苗人拳 = 0x01EF,
石长老_单攻 = 0x01F0, // 设定编号119
石长老_全攻 = 0x01F1, // 设定编号148
黑蜘蛛精 = 0x01F2,
绿叶小妖 = 0x01F3,
金蟾鬼母 = 0x01F4,
盖罗娇 = 0x01F5,
蛇女灵儿 = 0x01F6,
鸟人 = 0x01F7,
僵尸兵A = 0x01F8,
僵尸兵B = 0x01F9,
僵尸兵C = 0x01FA,
半人树妖 = 0x01FB,
小树妖 = 0x01FC,
尖头树妖 = 0x01FD,
尖嘴魔兵 = 0x01FE,
铁棍魔兵 = 0x01FF,
黑衣道众 = 0x0200,
狒狒 = 0x0201,
五彩蜘蛛 = 0x0202,
紫凤鸟 = 0x0203,
小毒蝎 = 0x0204,
赤蜈蚣 = 0x0205,
食火蟾 = 0x0206,
明王 = 0x0207,
九头蛇 = 0x0208,
雷龙 = 0x0209,
黑巫师 = 0x020A,
黑苗祭司 = 0x020B,
智修大师 = 0x020C,
林天南 = 0x020D,
黑衣女贼 = 0x020E,
苗枪卒_129 = 0x020F, // 设定编号129
巫王侍卫 = 0x0210,
天鬼皇 = 0x0211,
绿叶妖精 = 0x0212,
火蛟龙 = 0x0213,
土蛟龙 = 0x0214,
黑凤凰 = 0x0215,
红史莱姆 = 0x0216,
紫兽人 = 0x0217,
土蜘蛛 = 0x0218,
绿食火蟾 = 0x0219,
蓝食火蟾 = 0x021A,
毒神龙 = 0x021B,
金神龙 = 0x021C,
土神龙 = 0x021D,
火神龙 = 0x021E,
冰神龙 = 0x021F,
风神龙 = 0x0220,
雷神龙 = 0x0221,
拜月教主 = 0x0222,
八头蛇 = 0x0223,
苗人拳_151 = 0x0224, // 设定编号151
苗枪卒_152 = 0x0225, // 设定编号152
紫九头蛇 = 0x0226,
}

public static Dictionary<short, string> Scenes { get; set; } = new()
{
[-1] = "当前",
[0] = "标题画面中",
[1] = "梦之床_逍遥躺地",
[2] = "余杭_客栈各分立房间_灵儿被劫",
[3] = "余杭_客栈各分立房间_婶婶送行",
[4] = "余杭_客栈大厅",
[5] = "余杭_盛渔村",
[6] = "余杭_集市",
[7] = "余杭_十里坡",
[8] = "余杭_山神庙外",
[9] = "余杭_老王家_老丁家",
[10] = "余杭_废屋",
[11] = "余杭_洪大夫诊所",
[12] = "余杭_山神庙里",
[13] = "余杭_打铁铺",
[14] = "余杭_林师傅木工铺",
[15] = "仙灵岛_岸边",
[16] = "仙灵岛_草妖峡谷",
[17] = "仙灵岛_花树_灵池_原始",
[18] = "仙灵岛_莲池_断",
[19] = "仙灵岛_莲池_连",
[20] = "仙灵岛_洞天_水月宫外",
[21] = "仙灵岛_水月宫_未赠药",
[22] = "苏州_外_城郊_刁蛮小姐策两仆",
[23] = "苏州_内_初至",
[24] = "苏州_内_繁华区",
[25] = "苏州_城东民居_各分立房间",
[26] = "苏州_客栈_大厅",
[27] = "苏州_客栈_各单间",
[28] = "苏州_客栈_大通铺",
[29] = "苏州_客栈_赌厅",
[30] = "苏州_当铺",
[31] = "苏州_药铺",
[32] = "苏州_兵器铺",
[33] = "苏州_林家堡_演武厅_比武招亲",
[34] = "苏州_林家堡_演武厅_演武结束",
[35] = "苏州_林家堡_客厅",
[36] = "苏州_林家堡_后院",
[37] = "苏州_林家堡_西厢房_原始",
[38] = "苏州_林家堡_西厢房_墙破",
[39] = "苏州_林家堡_东厢房",
[40] = "苏州_林家堡_西厢房外_螳螂山_山道",
[41] = "隐龙窟_迷宫_终_无蛇妖男",
[42] = "隐龙窟_迷宫_终_蛇妖男",
[43] = "隐龙窟外_螳螂山_山道",
[44] = "隐龙窟外_螳螂山_柴翁居_1",
[45] = "隐龙窟_迷宫_1",
[46] = "隐龙窟_迷宫_2",
[47] = "隐龙窟_迷宫_3",
[48] = "隐龙窟_内洞",
[49] = "出隐龙窟_山路_释放众少女",
[50] = "白河村",
[51] = "白河村_骆记米行内",
[52] = "白河村_各分立屋宇",
[53] = "白河村_韩医仙屋外",
[54] = "白河村_韩医仙诊厅",
[55] = "出白河村_山路_北通黑水镇_西达玉佛寺",
[56] = "初至鬼阴山_洞外山路_山神压看门狗",
[57] = "玉佛寺_寺外_庙宇未消失",
[58] = "玉佛寺_寺外_庙宇消失",
[59] = "玉佛寺_寺内",
[60] = "将军冢_墓底_血池",
[61] = "将军冢_上层",
[62] = "黑水镇",
[63] = "黑水镇_各分立屋宇",
[64] = "乱葬岗_荒野",
[65] = "乱葬岗_墓地",
[66] = "将军冢_下层_1",
[67] = "将军冢_下层_2",
[68] = "鬼阴山_鬼阴坛_顶撞老人遭教育",
[69] = "鬼阴山_各洞口外山路",
[70] = "鬼阴山_绝顶匪巢_院内",
[71] = "鬼阴山_迷宫1",
[72] = "鬼阴山_迷宫2",
[73] = "鬼阴山_迷宫3",
[74] = "鬼阴山_迷宫4",
[75] = "鬼阴山_迷宫5",
[76] = "鬼阴山_迷宫6",
[77] = "鬼阴山_鬼阴坛石室",
[78] = "鬼阴山_鬼阴坛_梦慈得救公主遭抢",
[79] = "鬼阴山_鬼阴坛_石门通道",
[80] = "扬州城门_只需进城不许出城",
[81] = "出鬼阴山后_山道",
[82] = "扬州_府衙_痛揍_不招再打",
[83] = "扬州_城西",
[84] = "扬州前_山道_初遇问路盖罗娇",
[85] = "扬州_城东",
[86] = "扬州_城墙追贼_第1段_城西城墙之上",
[87] = "扬州_城墙追贼_第2段_城东城墙之上",
[88] = "扬州_城墙追贼_第3段_城北刺史府城墙之上",
[89] = "扬州_监狱地上室内_地牢入口",
[90] = "扬州_飞贼之家_寡妇勾引打翻醋罐",
[91] = "扬州_飞贼之家_密道打开",
[92] = "扬州_监狱地下_牢房",
[93] = "扬州_井底密道及飞贼密室",
[94] = "扬州_客栈大厅",
[95] = "扬州_客栈_杂物间",
[96] = "扬州_客栈_灶间",
[97] = "扬州_各独立商户及井后空屋",
[98] = "扬州_客栈_各独立间",
[99] = "扬州_城墙_各岗哨",
[100] = "扬州_民居",
[101] = "长安",
[102] = "蛤蟆谷_后段_栈道坍塌",
[103] = "蛤蟆谷_前段_剑圣劝归",
[104] = "蛤蟆洞_前段_鬼母豪邸",
[105] = "蛤蟆洞_后段_迷宫",
[106] = "出扬州_山路_蛤蟆谷前",
[107] = "蛤蟆洞外_白苗驿站外_石长老自爆",
[108] = "长安城外_田园摸牛",
[109] = "长安_尚书府_刘晋元居所外_1",
[110] = "长安_尚书府_刘晋元居所外_2",
[111] = "蛤蟆洞外_白苗驿站_驿站内",
[112] = "长安_水仙尊王庙外_恰遇云姨",
[113] = "长安_水仙尊王庙外_水漫金山戏剧",
[114] = "出扬州_山路田园_鬼母故居白鹅向天歌",
[115] = "长安_尚书府内_大门小院",
[116] = "长安_尚书府内_前院后小院_醉仙驱魔",
[117] = "长安_尚书府_幽径_观景长桥",
[118] = "长安_尚书府_刘晋元居所外_毒仙林关闭",
[119] = "长安_尚书府_大厅_林天南到此",
[120] = "长安_尚书府_大厅_楼上_笨天师看病",
[121] = "长安_尚书府_膳厅_用膳",
[122] = "长安_尚书府_膳厅_膳毕",
[123] = "长安_尚书府_刘晋元居所_一楼大厅及满花灶间",
[124] = "长安_尚书府_刘晋元居所_二楼楼道",
[125] = "长安_尚书府_刘晋元居所_二楼房间_刘晋元趴倒",
[126] = "长安_尚书府_刘晋元居所_二楼房间_二人叫醒刘晋元",
[127] = "长安_尚书府_刘晋元居所_二楼房间_笨天师自焚",
[128] = "长安_酒楼_一层",
[129] = "长安_酒楼_二层_笨道士售符",
[130] = "长安_百花浴_男士止步",
[131] = "长安_妓院_一楼",
[132] = "长安_妓院_二楼",
[133] = "长安_妓院_各房间_小雪叹气",
[134] = "长安_妓院_各房间_小雪接待逍遥",
[135] = "长安_妓院_各房间_莺莺夫人",
[136] = "长安_兵器铺",
[137] = "长安_民居",
[138] = "长安_民居_商人家",
[139] = "毒仙林_蜘蛛精居所_酒剑仙一剑秒杀",
[140] = "毒仙林_迷宫",
[141] = "毒仙林_蜘蛛精居所_千年修为抵十年寿",
[142] = "忆往昔_毒仙林晋元救蝶",
[143] = "忆往昔_尚书府蝶仙化形",
[144] = "忆往昔_晋元房双亲订婚",
[145] = "锁妖塔_七星盘龙柱",
[146] = "锁妖塔_底层_剑柱_灵儿被缚",
[147] = "锁妖塔_塔顶_初遇明王",
[148] = "锁妖塔_五层_姜清",
[149] = "锁妖塔_三层_天鬼皇",
[150] = "锁妖塔_五层_塔崩众妖逃窜",
[151] = "蜀山云海_酒剑仙遥望塔毁",
[152] = "田园_长安城外_天鬼皇逃出",
[153] = "锁妖塔_底层_剑柱_化妖池漩涡",
[154] = "锁妖塔_底层_剑柱_妖议出塔之策",
[155] = "锁妖塔_三层_书中仙",
[156] = "蜀山_前山_酒剑仙吩咐不许叫师父",
[157] = "锁妖塔_二层_万道铁链滑似冰",
[158] = "蜀山仙剑派正殿外_大院",
[159] = "蜀山仙剑派后山_酒剑仙送行",
[160] = "蜀山仙剑派正殿内_拜见剑圣",
[161] = "仙剑派弟子房间_寻回小石头",
[162] = "蜀山云海_前段",
[163] = "蜀山云海_后段",
[164] = "锁妖塔外_塔底入口",
[165] = "锁妖塔全景",
[166] = "锁妖塔_七层",
[167] = "锁妖塔_六层",
[168] = "锁妖塔_四层",
[169] = "锁妖塔_底层_剑柱室外",
[170] = "忆往昔_灵岛仙宫亲为辩",
[171] = "忆往昔_灵池未料此般逢",
[172] = "忆往昔_拼尽残生为还魂",
[173] = "圣姑家_灵儿生产",
[174] = "恍惚_林月如梦中送别",
[175] = "圣姑家_李逍遥醒来",
[176] = "桃源村",
[177] = "圣姑室外",
[178] = "圣姑室外_剑圣黯离",
[179] = "桃花源入口_望薄雾淡淡弥漫",
[180] = "灵山",
[181] = "桃花源入口_雾散去",
[182] = "桃花源_决战木道人",
[183] = "桃源村_屋舍化林",
[184] = "桃源村_众桃妖化林_褒奖寿葫芦",
[185] = "神木庵_迷宫",
[186] = "神木林_迷宫_2_凤凰巢",
[187] = "神木林_底",
[188] = "神木庵_出口",
[189] = "神木庵外_阿奴赎魂逍遥",
[190] = "桃花源_迷宫_前段",
[191] = "桃花源_迷宫_后段_宋贺文不敢上前",
[192] = "桃源村_各分立房间",
[193] = "神木林_迷宫_1_黑凤凰电梯",
[194] = "忆往昔_欢喜冤家擂前约",
[195] = "忆往昔_心事暗怀二人心",
[196] = "忆往昔_忧逍遥月如离堡",
[197] = "忆往昔_逞侠肝怒斥逃奴",
[198] = "忆往昔_扬州夜月如幽叹",
[199] = "忆往昔_尚书府二人谐心",
[200] = "忆往昔_言犹在耳成永谶",
[201] = "梦之床_巫后神型回魂仙梦",
[202] = "火麒麟洞_终_火麒麟兽",
[203] = "大理_城门外_正常",
[204] = "大理_女娲神殿_逍遥进入巫后石像",
[205] = "大理_祭坛_正常",
[206] = "大理_族议厅_正常",
[207] = "大理_城内_正常",
[208] = "大理_商业区",
[209] = "大理_汉人聚居地_正常",
[210] = "大理_汉人聚居地_商业区",
[211] = "大理_族议厅_一楼",
[212] = "大理_女娲神殿_外_正常",
[213] = "火麒麟洞_迷宫_第一段",
[214] = "试炼窟_女娲遗迹",
[215] = "试炼窟外_土路1_巨蝎挡路无法通过",
[216] = "试炼窟外_土路2_遭遇盖罗娇",
[217] = "试炼窟_1",
[218] = "试炼窟_2",
[219] = "试炼窟_3",
[220] = "试炼窟_4",
[221] = "试炼窟_5_二层门",
[222] = "试炼窟_废二层",
[223] = "试炼窟_二层_未知_1",
[224] = "试炼窟_二层_未知_2",
[225] = "试炼窟_未知",
[226] = "试炼窟_三层_未知",
[227] = "试炼窟_三层_所有伏",
[228] = "大理_祭坛_已摆满_动画前",
[229] = "大理_城门外_战",
[230] = "大理_城内_战",
[231] = "大理_城门外_战_天降甘霖",
[232] = "大理_祭坛_载歌载舞",
[233] = "大理_女娲神殿_外_防",
[234] = "大理_女娲神殿_灵儿拜母",
[235] = "大理_女娲神殿_内_防",
[236] = "火麒麟洞_终_火麒麟兽_无敌人",
[237] = "大理_族议厅_战",
[238] = "大理_各分立屋宇_空_逃难",
[239] = "大理_汉人聚居地_屠杀",
[240] = "大理_汉人聚居地_商业区_空",
[241] = "大理_族议厅_一楼_2",
[242] = "大理_祭坛_未摆灵珠",
[243] = "火麒麟洞_迷宫1_无敌人",
[244] = "大理_通往汉人聚居地_桥战_雨中",
[245] = "大理_城内_雨后_停止厮杀",
[246] = "大理_女娲神殿_外_雨中",
[247] = "回魂仙梦_荒岛_救公主",
[248] = "回魂仙梦_南绍王宫_内殿_牢房_巫后被囚",
[249] = "回魂仙梦_南绍王宫_外",
[250] = "回魂仙梦_南绍王宫_地下室",
[251] = "回魂仙梦_水底秘道_后段",
[252] = "回魂仙梦_荒岛_逍遥跪地水魔兽封印",
[253] = "回魂仙梦_水底秘道_前段",
[254] = "回魂仙梦_南绍王宫_牢房_遭遇巫王拜月",
[255] = "回魂仙梦_南绍被淹_房顶",
[256] = "回魂仙梦_南绍王宫_外殿_斩汉人祭水魔兽",
[257] = "回魂仙梦_南绍王宫_内殿_2",
[258] = "回魂仙梦_南绍王宫_外殿_地牢入口",
[259] = "回魂仙梦_南绍王宫_空左耳殿",
[260] = "回魂仙梦_南绍王宫_空右耳殿",
[261] = "回魂仙梦_南绍王宫_地下室_内室",
[262] = "回魂仙梦_南绍王宫_地牢_通道1",
[263] = "回魂仙梦_南绍王宫_地牢_通道2",
[264] = "回魂仙梦_南绍王宫_地牢_通道3",
[265] = "回魂仙梦_南绍王宫_地牢_牢房",
[266] = "回魂仙梦_南绍王宫_地牢_石室_天蛇杖",
[267] = "回魂仙梦_余杭_山神庙_外",
[268] = "回魂仙梦_余杭_十年前",
[269] = "回魂仙梦_余杭_山神庙_内_姥姥伤",
[270] = "回魂仙梦_余杭_十里坡",
[271] = "回魂仙梦_余杭_客栈_大厅",
[272] = "回魂仙梦_余杭_客栈_房间",
[273] = "回魂仙梦_余杭_各分立屋宇",
[274] = "回魂仙梦_余杭_集市",
[275] = "回魂仙梦_余杭_集市_各分立屋宇",
[276] = "回魂仙梦_余杭_集市_铁匠铺",
[277] = "回魂仙梦_余杭_集市_林师傅木匠铺",
[278] = "南绍王宫_外殿_地牢入口",
[279] = "南绍王宫_内殿_假巫王刺灵儿",
[280] = "南绍王宫_地牢_通道3_怪",
[281] = "南绍王宫_外_空",
[282] = "南绍王宫_外殿_对战桥头拜月",
[283] = "南绍王宫_空左耳殿",
[284] = "南绍王宫_空右耳殿",
[285] = "南绍王宫_内殿_牢房",
[286] = "南绍王宫_地下室_怪",
[287] = "南绍王宫_地下室_内室_怪",
[288] = "南绍王宫_地牢_通道_1_怪",
[289] = "南绍王宫_地牢_通道_2_怪",
[290] = "南绍王宫_地牢_通道_地牢_怪",
[291] = "南绍王宫_地牢_石室_青龙宝甲",
[292] = "无底深渊_迷宫_1",
[293] = "无底深渊_迷宫_2",
};
