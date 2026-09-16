#pragma once

enum class WeaponType : short {
    PISTOL = 0,
    RIFLE = 1,
    SMG = 2,
    SHOTGUN = 3,
};

enum class WeaponGrade : short {
    BASIC = 0,
    GRADE_1 = 1,
    GRADE_2 = 2,
    GRADE_3 = 3,
    GRADE_4 = 4,
};

// 깡통 (NPC/플레이어 소유)
struct WeaponSpec {
    short damage = 0;
    float rpm = 0.0f;
    float range = 0.0f;         // 피격 무효 판정
    short magazineSize = 0;
    float reloadTime = 0.0f;
    // 거리 감쇠
    float maxDistanceDamageReductionRatio = 0.0f;       // 데미지 감쇠 계수. 0이면 감쇠 없음. 
};

// 거리 기반 최종 데미지 계산. 
inline short ComputeDamage(const WeaponSpec& spec, float dist)
{
    if (dist < 0.0f) dist = 0.0f;
    if (dist > spec.range) return 0;   // 컷오프 거리 초과 -> 미적용

    float dmg = static_cast<float>(spec.damage);
    if (spec.maxDistanceDamageReductionRatio > 0.0f) {
        float falloff = 1.0f - spec.maxDistanceDamageReductionRatio * (dist / spec.range);
        dmg *= falloff;
    }
    short result = static_cast<short>(dmg + 0.5f);   // 반올림
    if (result < 1) result = 1;                       // 명중했으면 최소 1
    return result;
}

// type x grade = spec / 클라 BuildSpec 복제
// PISTOL은 등급 무관 고정. 
// RIFLE/SMG/SHOTGUN은 GRADE_1~4만 유효.
inline WeaponSpec LookupWeaponSpec(WeaponType type, WeaponGrade grade)
{
    WeaponSpec s;
    switch (type) {
    case WeaponType::PISTOL:
        s.damage = 7;  s.rpm = 550.0f; s.range = 10.0f; 
        s.magazineSize = 15; s.reloadTime = 1.2f;
        break;

    case WeaponType::RIFLE:
        s.rpm = 700.0f; s.range = 50.0f;
        s.magazineSize = 30; s.reloadTime = 1.8f;
        s.maxDistanceDamageReductionRatio = 0.10f;
        switch (grade) {
        case WeaponGrade::GRADE_1: s.damage = 11; break;
        case WeaponGrade::GRADE_2: s.damage = 14; break;
        case WeaponGrade::GRADE_3: s.damage = 18; break;
        case WeaponGrade::GRADE_4: s.damage = 23; break;
        default: break;
        }
        break;

    case WeaponType::SMG:
        s.rpm = 900.0f; s.range = 50.0f;
        s.magazineSize = 35; s.reloadTime = 1.6f;
        s.maxDistanceDamageReductionRatio = 0.50f;
        switch (grade) {
        case WeaponGrade::GRADE_1: s.damage = 9;  break;
        case WeaponGrade::GRADE_2: s.damage = 11; break;
        case WeaponGrade::GRADE_3: s.damage = 14; break;
        case WeaponGrade::GRADE_4: s.damage = 17; break;
        default: break;
        }
        break;

    case WeaponType::SHOTGUN:
        s.rpm = 200.0f; s.range = 20.0f;
        s.magazineSize = 8; s.reloadTime = 2.4f;
        //s.zeroDamageBeyondDistance = 20.0f;       // --> range
        switch (grade) {
        case WeaponGrade::GRADE_1: s.damage = 64; break;
        case WeaponGrade::GRADE_2: s.damage = 72; break;
        case WeaponGrade::GRADE_3: s.damage = 80; break;
        case WeaponGrade::GRADE_4: s.damage = 88; break;
        default: break;
        }
        break;
    }
    return s;
}

struct GrenadeSpec {
    short damageMax = 80;
    float radius = 5.0f;
    float falloffRatio = 0.7f;
};

inline GrenadeSpec GetGrenadeSpec() 
{ 
    GrenadeSpec g;
    return g;
}

inline short ComputeGrenadeDamage(const GrenadeSpec& g, float dist) 
{ 
    if (dist < 0.0f) dist = 0.0f;
    if (dist > g.radius) return 0;   // 반경 밖 -> 미적용
    float dmg = static_cast<float>(g.damageMax);
    if (g.falloffRatio > 0.0f) {
        float falloff = 1.0f - g.falloffRatio * (dist / g.radius);
        dmg *= falloff;
    }
    short result = static_cast<short>(dmg + 0.5f);   // 반올림
    if (result < 1) result = 1;                       // 반경 내면 최소 1
    return result;
}