#pragma once

#include <array>
#include <vector>
#include <mutex>
#include <DirectXMath.h>
#include <chrono>
#include "protocol.h"
#include "Server_Weapon.h"   // WeaponType/WeaponGrade

using namespace DirectX;

constexpr int MAX_NPC_PER_ROOM = 66;

struct SERVER_NPC {
    short    id;                 // NPC ID
    char     kind;               // NPC 단계(tier): 1=PISTOL, 2=SMG, 3=RIFLE
    char     outfit;             // 외형 프리셋(0/1/2). tier와 독립 (조합 3x3=9종)
    bool     alive;              // 살아있는지 (죽으면 slot 안 쓰게?)
    char     state;              // NPC상태  NPC_STATE_IDLE / NPC_STATE_RUN / NPC_STATE_DIE

    XMFLOAT3 position;
    XMFLOAT3 spawn_position;    // 복귀 기준점
    float    yaw;               // 라디안

    short    hp;
    short    max_hp;

    float                  path_update_timer;  // A* 주기 (1초마다)
    std::vector<XMFLOAT3>  waypoints;          // 현재 경로
    int                    way_idx;            // 다음 목표 waypoint 인덱스

    float                  die_timer;          // Die 상태 진입 후 경과 시간

    std::vector<XMFLOAT3>  coll_normals;       // 이번 틱 누적 충돌 노멀 (아직안씀?)

    float think_timer;              // AI 행동 주기

    float    lose_sight_timer;      // 마지막 목격 처리 관련
    bool     has_last_seen_player;
    XMFLOAT3 last_seen_player_pos;

    float    return_ignore_timer;

    float    aim_timer;             // 조준 시간, 공격 쿨다운
    float    attack_cooldown;

    int      burst_shots_left;      // 버스트 사격
    int      burst_serial;
    float    burst_shot_timer;
    float    burst_rest_timer;

    float    strafe_timer;          // 스트레이프
    float    strafe_sign;

    int      current_ammo;          // 재장전
    bool     reloading;
    float    reload_timer;

    short    weapon_type;
    short    weapon_grade;

    std::array<ItemSlot, INVENTORY_SIZE>    _inventory;     // 루팅박스 내용물
    bool                                    loot_active;    // 박스 활성 여부
    std::chrono::steady_clock::time_point   death_time;     // lifetime 기준
};

// NPC 단계(tier) 상수
constexpr char NPC_TIER_1 = 1;   // PISTOL
constexpr char NPC_TIER_2 = 2;   // SMG
constexpr char NPC_TIER_3 = 3;   // RIFLE

constexpr short NPC_TIER1_HP = 100;   // 2단계 x1.5=150, 3단계 x2=200

// tier로부터 무기 type/grade와 max_hp 결정. 스폰 시 호출.
inline void ApplyNpcTier(SERVER_NPC& npc, char tier)
{
    npc.kind = tier;
    switch (tier) {
    case NPC_TIER_2:
        npc.weapon_type = static_cast<short>(WeaponType::SMG);
        npc.weapon_grade = static_cast<short>(WeaponGrade::GRADE_2);
        npc.max_hp = static_cast<short>(NPC_TIER1_HP * 3 / 2);   // 150
        break;
    case NPC_TIER_3:
        npc.weapon_type = static_cast<short>(WeaponType::RIFLE);
        npc.weapon_grade = static_cast<short>(WeaponGrade::GRADE_3);
        npc.max_hp = static_cast<short>(NPC_TIER1_HP * 2);       // 200
        break;
    case NPC_TIER_1:
    default:
        npc.weapon_type = static_cast<short>(WeaponType::PISTOL);
        npc.weapon_grade = static_cast<short>(WeaponGrade::BASIC);
        npc.max_hp = NPC_TIER1_HP;                               // 100
        break;
    }
    npc.hp = npc.max_hp;
}

// NpcInputEvent
struct NpcInputEvent {
    enum Type { HIT, GRENADE_EXPLODE, ROUND_JOIN, ROUND_LEAVE };
    Type type;

    int      room_id = -1;      // 이벤트가 적용될 룸
    uint32_t room_gen = 0;      // 룸의 generation과 일치하는지 확인 (옛날룸 이벤트로 현재룸 갱신하는 동작 방지)

    int      attacker_client_id;
    XMFLOAT3 ray_origin;
    XMFLOAT3 ray_direction;

    short    weapon_type;
    short    weapon_grade;

    int      new_client_id;

    XMFLOAT3 explode_pos;
};

// NpcInputQueue
class NpcInputQueue {
    std::mutex                  _mtx;
    std::vector<NpcInputEvent>  _events;
public:
    void Push(NpcInputEvent e);
    void DrainTo(std::vector<NpcInputEvent>& out);
};

extern NpcInputQueue g_npc_input_queue;