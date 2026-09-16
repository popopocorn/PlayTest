#pragma once

enum class EffectID : unsigned char {
    NONE = 0,
    GRENADE_EXPLOSION = 1,
    SPARK = 2,   // 머즐 플래시로 사용
    BLOOD = 3,
    HIT = 4
};

enum class EffectEntityKind : unsigned char {
    NPC = 0,
    PLAYER = 1
};
