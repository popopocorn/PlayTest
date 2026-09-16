#pragma once

#include "ItemDef.h"

constexpr int PORT_NUM = 4000;
constexpr int BUF_SIZE = 200;
constexpr int NAME_SIZE = 20;
constexpr int INVENTORY_SIZE = 10;

constexpr int MAX_USER = 10000;
constexpr int MAX_NPC = 128;

constexpr int W_WIDTH = 400;
constexpr int W_HEIGHT = 400;

// Packet ID
constexpr char CS_LOGIN = 0;
constexpr char CS_MOVE = 1;

constexpr char SC_LOGIN_INFO = 2;
constexpr char SC_ADD_PLAYER = 3;
constexpr char SC_REMOVE_PLAYER = 4;
constexpr char SC_MOVE_PLAYER = 5;

// NPC 패킷 S2C
constexpr char SC_ADD_NPC = 6;
constexpr char SC_REMOVE_NPC = 7;
constexpr char SC_MOVE_NPC = 8;
constexpr char SC_NPC_STATE_CHANGE = 9;
constexpr char SC_NPC_HP_UPDATE = 10;

// NPC 패킷 C2S
constexpr char CS_HIT_NPC = 11;

// 인벤토리 패킷 C2S
constexpr char CS_INVENTORY_CLICK = 12;

// 인벤토리 패킷 S2C
constexpr char SC_INVENTORY_UPDATE = 13;
constexpr char SC_ADD_LOOT_BOX = 14;

// 루트박스 누르기 15, 루트박스 업데이트 16
constexpr char CS_LOOT_PICKUP = 15;
constexpr char SC_LOOT_BOX_SLOT_UPDATE = 16;
constexpr char SC_DEACTIVATE_LOOT_BOX = 17;

constexpr char SC_PLAYER_STATE_CHANGE = 18;
constexpr char SC_PLAY_EFFECT_ATTACHED = 19;
constexpr char SC_PLAYER_HP_UPDATE = 20;
constexpr char SC_PLAY_EFFECT_WORLD = 21;

// 제작(crafting)
constexpr char CS_CRAFT_REQUEST = 22;
constexpr char SC_EQUIPMENT_UPDATE = 23;

// PvP 패킷
constexpr char CS_HIT_PLAYER = 24;

// 무기 변경 동기화
constexpr char CS_CHANGE_WEAPON = 25;
constexpr char SC_CHANGE_WEAPON = 26;

// 라운드 시작 패킷
constexpr char SC_ROUND_START = 27;

// 탈출 성공 패킷
constexpr char SC_ESCAPE_SUCCESS = 28;

// 수류탄 폭발 (C2S) — 클라가 최종 폭발 위치 전송 
constexpr char CS_GRENADE_EXPLODE = 29;

// OtherPlayer 상태 변환
constexpr char CS_PLAYER_STATE_CHANGE = 30;

// 총알 브로드캐스트
constexpr char SC_FIRE_TRACER = 31;

// 라운드 제한 시간 초과
constexpr char SC_GAME_OVER = 32;

constexpr char CS_RELOAD_REQUEST = 33;		// C2S 재장전 시도
constexpr char SC_AMMO_STATE = 34;			// S2C 
constexpr char SC_GRENADE_COUNT = 35;

constexpr char SC_ESCAPE_PROGRESS = 36;

constexpr char SC_ROUND_RESET = 37;			// 로비로 나갈 때 월드 초기화
constexpr char CS_ROUND_JOIN = 38;			// 로비에서 라운드로 들어올 때
constexpr char CS_ROUND_LEAVE = 39;			// 게임오버 후 로비로 나가기 (연결끊기 아님)

// C2S 무적 모드 토글 (디버그용)
constexpr char CS_TOGGLE_GODMODE = 40;		

constexpr char ESCAPE_PROG_START = 0;		// 탈출 진행 시작
constexpr char ESCAPE_PROG_RESET = 1;		// 영역 내 피격으로 인한 타이머 리셋
constexpr char ESCAPE_PROG_CANCEL = 2;		// 탈출 지역 이탈, 진행 취소

// CS_MOVE_PACKET inputs 비트 플래그
constexpr char MOVE_W = 0x01;
constexpr char MOVE_S = 0x02;
constexpr char MOVE_A = 0x04;
constexpr char MOVE_D = 0x08;

constexpr char INV_ACTION_CLICK = 0;

constexpr char PLAYER_STATE_IDLE = 0;
constexpr char PLAYER_STATE_RUN = 1;
constexpr char PLAYER_STATE_SHOOT = 2;
constexpr char PLAYER_STATE_RELOAD = 3;
constexpr char PLAYER_STATE_GRENADE = 4;
constexpr char PLAYER_STATE_DIE = 5;

constexpr char NPC_STATE_IDLE = 0;
constexpr char NPC_STATE_RUN = 1;
constexpr char NPC_STATE_DIE = 2;
constexpr char NPC_STATE_RETURN = 3;
constexpr char NPC_STATE_ATTACK = 4;
constexpr char NPC_STATE_RELOAD = 5;

#pragma pack (push, 1)
struct CS_LOGIN_PACKET {
	unsigned char size;
	char	type;
	char	name[NAME_SIZE];
};

struct CS_MOVE_PACKET {
	unsigned char size;
	char          type;
	char          inputs;       // WASD 비트 플래그 (MOVE_W, MOVE_S, MOVE_A, MOVE_D)
	float         yaw;          // 카메라 Yaw (도 단위) — 이동 방향 계산용
	unsigned int  move_time;    // 패킷 순서 보정용 
};

struct SC_LOGIN_INFO_PACKET {
	unsigned char size;
	char          type;
	short         id;
	float         x, y, z;        // short → float
};

struct SC_ADD_PLAYER_PACKET {
	unsigned char size;
	char          type;
	short         id;
	float         x, y, z;
	float         yaw;
	char          state;
	char          name[NAME_SIZE];
};

struct SC_REMOVE_PLAYER_PACKET {
	unsigned char size;
	char	type;
	short	id;
};

struct SC_MOVE_PLAYER_PACKET {
	unsigned char size;
	char          type;
	short         id;
	float         x, y, z;
	float         yaw;
	unsigned int  move_time;
};

struct CS_INVENTORY_CLICK_PACKET {
	unsigned char size;
	char          type;
	char          action;
	short         slotidx;
};

// NPC 패킷 추가

struct SC_ADD_NPC_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;
	char          npc_kind;       // NPC 단계(tier 1/2/3)
	char          npc_outfit;     // 외형 프리셋(0/1/2)
	float         x, y, z;
	float         yaw;
	short         hp;
};

struct SC_REMOVE_NPC_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;
};

struct SC_MOVE_NPC_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;
	float         x, y, z;
	float         yaw;
};

struct SC_NPC_STATE_CHANGE_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;
	char          state;          // NPC 상태 변환용
};

struct SC_NPC_HP_UPDATE_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;
	short         hp;
};

struct CS_HIT_NPC_PACKET {
	unsigned char size;
	char          type;
	float         ray_ox, ray_oy, ray_oz;
	float         ray_dx, ray_dy, ray_dz;
	short         weapon_type;     // WeaponType (PISTOL=0..SHOTGUN=3)
	short         weapon_grade;    // WeaponGrade (BASIC=0..GRADE_4=4)
	unsigned int  fire_time;
};

struct SC_INVENTORY_UPDATE_PACKET {
	unsigned char size;
	char          type;
	short         slotidx;
	ItemID        item_id;   // sizeof = 2 (enum class ItemID : short)
	int           count;
};

struct SC_ADD_LOOT_BOX_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;             // = box_id
	float         x, y, z;            // 사망 위치
	ItemID        items[INVENTORY_SIZE];
	int           counts[INVENTORY_SIZE];
};

struct CS_LOOT_PICKUP_PACKET {
	unsigned char size;
	char          type;
	short         box_id;     // = NPC id
	short         slotidx;
};

struct SC_LOOT_BOX_SLOT_UPDATE_PACKET {
	unsigned char size;
	char          type;
	short         box_id;
	short         slotidx;
	ItemID        item_id;
	int           count;
};

struct SC_DEACTIVATE_LOOT_BOX_PACKET {
	unsigned char size;
	char          type;
	short         npc_id;
};

struct SC_PLAYER_STATE_CHANGE_PACKET {
	unsigned char size;
	char          type;
	short         id;
	char          state;
};

struct SC_PLAY_EFFECT_ATTACHED_PACKET {
	unsigned char size;
	char          type;
	unsigned char effect_id;     // EffectID raw 값
	unsigned char entity_kind;   // 0=NPC, 1=PLAYER (id 공간 구분)
	short         entity_id;
};

struct SC_PLAYER_HP_UPDATE_PACKET {
	unsigned char size;
	char          type;
	short         id;
	short         hp;
};

struct SC_PLAY_EFFECT_WORLD_PACKET {
	unsigned char size;
	char          type;
	unsigned char effect_id;     // EffectID raw 값
	float         x, y, z;       // 발생 위치
	float         dx, dy, dz;    // 방향 (방향 무의미한 이펙트는 클라가 무시)
};

struct CS_CRAFT_REQUEST_PACKET {
	unsigned char size;
	char          type;
	ItemID        target;
};

struct SC_EQUIPMENT_UPDATE_PACKET {
	unsigned char size;
	char          type;
	ItemID        equip_id;
};

struct CS_HIT_PLAYER_PACKET {
	unsigned char size;
	char          type;
	float         ray_ox, ray_oy, ray_oz;
	float         ray_dx, ray_dy, ray_dz;
	short         weapon_type;				// WeaponType
	short         weapon_grade;				// WeaponGrade
	unsigned int  fire_time;				// 나중에
};

struct CS_CHANGE_WEAPON_PACKET {
	unsigned char size;
	char          type;
	short         weapon_type;		// ItemType
	short         weapon_grade;		// ItemGrade
};

struct SC_CHANGE_WEAPON_PACKET {
	unsigned char size;
	char          type;
	short         id;
	short         weapon_type;		// ItemType
	short         weapon_grade;		// ItemGrade
};

struct SC_ROUND_START_PACKET {
	unsigned char size;
	char          type;
	float         x, y, z;			// 이번 라운드 내 스폰 위치
};
struct CS_ROUND_JOIN_PACKET {
	unsigned char	size;
	char			type;
};

struct CS_ROUND_LEAVE_PACKET {
	unsigned char	size;
	char			type;
};

struct SC_ROUND_RESET_PACKET {
	unsigned char	size;
	char			type;
};

struct SC_ESCAPE_SUCCESS_PACKET {
	unsigned char size;
	char          type;
	float         escape_time_sec;   // 라운드 시작~탈출까지 걸린 시간(초)
};

struct CS_GRENADE_EXPLODE_PACKET {
	unsigned char size;
	char          type;
	float         x, y, z;   // 최종 폭발 위치 (grenadeFinalPos), 판정은 XZ만 사용
};

struct CS_PLAYER_STATE_CHANGE_PACKET {
	unsigned char size;
	char          type;
	char          state;     // PLAYER_STATE_*
};

struct SC_FIRE_TRACER_PACKET {
	unsigned char	size;
	char			type;			// SC_FIRE_TRACER
	short			shooter_id;		// 발사자 (수신 클라가 자기 자신이면 무시)
	float			ox, oy, oz;		// 시작 위치
	float			dx, dy, dz;		// 방향
	short			weapon_type;	// WeaponType (ItemType 기준, 사운드 재생 용도)
	unsigned char	hit_kind;		// 0=허공, 1=벽, 2=캐릭터
	float			distance;		// 진행 거리 (시작점부터 종착점까지)
	float			nx, ny, nz;		// 데칼 노멀 (hit_kind==1일 때만 유효)
};

struct SC_GAME_OVER_PACKET {
	unsigned char size;
	char          type;
};

struct CS_RELOAD_REQUEST_PACKET {
	unsigned char size;
	char          type;
	short         weapon_type;		// 재장전할 무기 (0~3)
};

struct SC_AMMO_STATE_PACKET {
	unsigned char size;
	char          type;
	short         ammo[4];			// WeaponType 인덱스별 현재 탄약
};

struct SC_GRENADE_COUNT_PACKET {
	unsigned char size;
	char          type;
	short         grenade_count;
};

struct SC_ESCAPE_PROGRESS_PACKET {
	unsigned char size;
	char          type;
	char          event;			// ESCAPE_PROG_START / RESET / CANCEL
};

struct CS_TOGGLE_GODMODE_PACKET {
	unsigned char	size;
	char			type;
};

#pragma pack (pop)