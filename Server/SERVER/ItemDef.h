#pragma once

//아이템 선언
enum class ItemType {
	PISTOL,
	RIFLE,
	SMG,
	SHOTGUN,
	ARMOR_HELMET,//
	ARMOR_BODY,
	ARMOR_SHOES,
	PLATE,
	CONSUMABLE,
	MATERIAL,
};

enum class ItemGrade
{
	BASIC,
	GRADE_1,
	GRADE_2,
	GRADE_3,
	GRADE_4
};


enum class ItemID : short {
	//재료
	NONE = 0,
	MAT_1_FIBER,
	MAT_2_METAL_PLATE,
	MAT_3_BOLT_AND_NUT,
	WEAPON_UPGRADE_2,
	WEAPON_UPGRADE_3,
	WEAPON_UPGRADE_4,
	ARMOR_PLATE,
	//완성품
	WEAPON_RIFLE_01,
	WEAPON_RIFLE_02,
	WEAPON_RIFLE_03,
	WEAPON_RIFLE_04,

	WEAPON_SMG_01,
	WEAPON_SMG_02,
	WEAPON_SMG_03,
	WEAPON_SMG_04,

	WEAPON_SHOTGUN_01,
	WEAPON_SHOTGUN_02,
	WEAPON_SHOTGUN_03,
	WEAPON_SHOTGUN_04,

	ARMOR_HELMET_01,
	ARMOR_HELMET_02,
	ARMOR_HELMET_03,
	ARMOR_HELMET_04,

	ARMOR_BODY_01,
	ARMOR_BODY_02,
	ARMOR_BODY_03,
	ARMOR_BODY_04,

	ARMOR_SHOES_01,
	ARMOR_SHOES_02,
	ARMOR_SHOES_03,
	ARMOR_SHOES_04,

	ESCAPE_KEY,

	ITEMID_END
};

constexpr int MAX_SLOTS = 10;

struct ItemSlot {
	ItemID item = ItemID::NONE;
	int    count = 0;
};

struct RecipeIngredient {
	ItemID item;
	int    count;
};

constexpr int MAX_RECIPE_INGREDIENTS = 4;
struct CraftRecipe {
	ItemID           result;
	int              resultCount;
	RecipeIngredient ingredients[MAX_RECIPE_INGREDIENTS];
};

inline constexpr CraftRecipe g_craftRecipes[] = {
	
	// 무기: 라이플 (금속판, 볼트/너트 중심)
	{ ItemID::WEAPON_RIFLE_01, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 3 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 3 },
		{ ItemID::NONE, 0 }, { ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_RIFLE_02, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 6 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 6 },
		{ ItemID::WEAPON_UPGRADE_2, 1 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_RIFLE_03, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 10 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 10 },
		{ ItemID::WEAPON_UPGRADE_3, 1 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_RIFLE_04, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 15 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 15 },
		{ ItemID::WEAPON_UPGRADE_4, 1 },
		{ ItemID::NONE, 0 } } },

	
	// 무기: SMG (섬유 포함, 금속/볼트 요구량 상대적으로 낮음)
	{ ItemID::WEAPON_SMG_01, 1, {
		{ ItemID::MAT_1_FIBER, 2 },
		{ ItemID::MAT_2_METAL_PLATE, 2 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 2 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_SMG_02, 1, {
		{ ItemID::MAT_1_FIBER, 4 },
		{ ItemID::MAT_2_METAL_PLATE, 4 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 4 },
		{ ItemID::WEAPON_UPGRADE_2, 1 } } },

	{ ItemID::WEAPON_SMG_03, 1, {
		{ ItemID::MAT_1_FIBER, 6 },
		{ ItemID::MAT_2_METAL_PLATE, 8 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 6 },
		{ ItemID::WEAPON_UPGRADE_3, 1 } } },

	{ ItemID::WEAPON_SMG_04, 1, {
		{ ItemID::MAT_1_FIBER, 10 },
		{ ItemID::MAT_2_METAL_PLATE, 12 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 8 },
		{ ItemID::WEAPON_UPGRADE_4, 1 } } },

	
	// 무기: 샷건 (금속판 다량 요구, 볼트/너트 약간)
	{ ItemID::WEAPON_SHOTGUN_01, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 4 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 2 },
		{ ItemID::NONE, 0 }, { ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_SHOTGUN_02, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 8 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 4 },
		{ ItemID::WEAPON_UPGRADE_2, 1 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_SHOTGUN_03, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 12 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 6 },
		{ ItemID::WEAPON_UPGRADE_3, 1 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::WEAPON_SHOTGUN_04, 1, {
		{ ItemID::MAT_2_METAL_PLATE, 18 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 10 },
		{ ItemID::WEAPON_UPGRADE_4, 1 },
		{ ItemID::NONE, 0 } } },


	// 방어구: 헬멧 (섬유, 금속판 중심)
	{ ItemID::ARMOR_HELMET_01, 1, {
		{ ItemID::MAT_1_FIBER, 3 },
		{ ItemID::MAT_2_METAL_PLATE, 3 },
		{ ItemID::NONE, 0 }, 
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_HELMET_02, 1, {
		{ ItemID::MAT_1_FIBER, 5 },
		{ ItemID::MAT_2_METAL_PLATE, 5 },
		{ ItemID::NONE, 0 }, 
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_HELMET_03, 1, {
		{ ItemID::MAT_1_FIBER, 8 },
		{ ItemID::MAT_2_METAL_PLATE, 8 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 2 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_HELMET_04, 1, {
		{ ItemID::MAT_1_FIBER, 12 },
		{ ItemID::MAT_2_METAL_PLATE, 12 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 4 },
		{ ItemID::NONE, 0 } } },


	
	// 방어구: 바디 (가장 많은 재료 요구, 3종류 모두 골고루 사용)
	{ ItemID::ARMOR_BODY_01, 1, {
		{ ItemID::MAT_1_FIBER, 3 },
		{ ItemID::MAT_2_METAL_PLATE, 3 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 2 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_BODY_02, 1, {
		{ ItemID::MAT_1_FIBER, 6 },
		{ ItemID::MAT_2_METAL_PLATE, 6 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 4 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_BODY_03, 1, {
		{ ItemID::MAT_1_FIBER, 10 },
		{ ItemID::MAT_2_METAL_PLATE, 10 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 8 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_BODY_04, 1, {
		{ ItemID::MAT_1_FIBER, 15 },
		{ ItemID::MAT_2_METAL_PLATE, 15 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 12 },
		{ ItemID::NONE, 0 } } },

	
	// 방어구: 신발 (섬유, 볼트/너트 중심)
	{ ItemID::ARMOR_SHOES_01, 1, {
		{ ItemID::MAT_1_FIBER, 3 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 3 },
		{ ItemID::NONE, 0 }, 
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_SHOES_02, 1, {
		{ ItemID::MAT_1_FIBER, 5 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 5 },
		{ ItemID::NONE, 0 }, 
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_SHOES_03, 1, {
		{ ItemID::MAT_1_FIBER, 8 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 8 },
		{ ItemID::MAT_2_METAL_PLATE, 2 },
		{ ItemID::NONE, 0 } } },

	{ ItemID::ARMOR_SHOES_04, 1, {
		{ ItemID::MAT_1_FIBER, 12 },
		{ ItemID::MAT_3_BOLT_AND_NUT, 12 },
		{ ItemID::MAT_2_METAL_PLATE, 4 },
		{ ItemID::NONE, 0 } } },
};

constexpr int g_craftRecipeCount = static_cast<int>(sizeof(g_craftRecipes) / sizeof(g_craftRecipes[0]));

inline const CraftRecipe* FindCraftRecipe(ItemID target) {
	for (int i = 0; i < g_craftRecipeCount; ++i) {
		if (g_craftRecipes[i].result == target) return &g_craftRecipes[i];
	}
	return nullptr;
}

constexpr int ARMOR_DR_PERCENT[5]    = { 0, 5, 7, 10, 15 };   // 헬멧 / 상의 공용 (합산 적용)
constexpr int SHOES_SPEED_PERCENT[5] = { 0, 3, 5,  7, 10 };   // 신발 (합산 없음)

enum class ArmorSlot : int {
	NONE   = -1,
	HELMET = 0,
	BODY   = 1,
	SHOES  = 2,
};

inline bool ClassifyArmor(ItemID id, ArmorSlot& outSlot, int& outGrade)
{
	const int v = static_cast<int>(id);

	if (v >= static_cast<int>(ItemID::ARMOR_HELMET_01) &&
		v <= static_cast<int>(ItemID::ARMOR_HELMET_04)) {
		outSlot  = ArmorSlot::HELMET;
		outGrade = v - static_cast<int>(ItemID::ARMOR_HELMET_01) + 1;
		return true;
	}

	if (v >= static_cast<int>(ItemID::ARMOR_BODY_01) &&
		v <= static_cast<int>(ItemID::ARMOR_BODY_04)) {
		outSlot  = ArmorSlot::BODY;
		outGrade = v - static_cast<int>(ItemID::ARMOR_BODY_01) + 1;
		return true;
	}

	if (v >= static_cast<int>(ItemID::ARMOR_SHOES_01) &&
		v <= static_cast<int>(ItemID::ARMOR_SHOES_04)) {
		outSlot  = ArmorSlot::SHOES;
		outGrade = v - static_cast<int>(ItemID::ARMOR_SHOES_01) + 1;
		return true;
	}

	outSlot  = ArmorSlot::NONE;
	outGrade = 0;
	return false;
}

inline short ApplyArmorReduction(short dmg, int helmet_grade, int body_grade)
{
	if (dmg <= 0) return 0;

	if (helmet_grade < 0 || helmet_grade > 4) helmet_grade = 0;
	if (body_grade   < 0 || body_grade   > 4) body_grade   = 0;

	int dr = ARMOR_DR_PERCENT[helmet_grade] + ARMOR_DR_PERCENT[body_grade];
	if (dr > 100) dr = 100;

	int result = (static_cast<int>(dmg) * (100 - dr)) / 100;
	if (result < 1) result = 1;

	return static_cast<short>(result);
}
