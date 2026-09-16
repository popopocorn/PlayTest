#include "Server_Collision.h"

#include <vector>
#include <limits>
#include <cmath>

ColResult CalcCollision(const BoundingOrientedBox& main, const BoundingOrientedBox& target)
{
	XMVECTOR centerA = XMLoadFloat3(&main.Center);
	XMVECTOR centerB = XMLoadFloat3(&target.Center);
	XMVECTOR extentsA = XMLoadFloat3(&main.Extents);
	XMVECTOR extentsB = XMLoadFloat3(&target.Extents);
	XMVECTOR quatA = XMLoadFloat4(&main.Orientation);
	XMVECTOR quatB = XMLoadFloat4(&target.Orientation);

	// 2. 각 박스의 기저 벡터(축) 추출
	XMMATRIX matA = XMMatrixRotationQuaternion(quatA);
	XMMATRIX matB = XMMatrixRotationQuaternion(quatB);

	XMVECTOR axesA[3] = { matA.r[0], matA.r[1], matA.r[2] };
	XMVECTOR axesB[3] = { matB.r[0], matB.r[1], matB.r[2] };

	// 3. 테스트할 15개의 분리 축 후보 생성
	std::vector<XMVECTOR> testAxes;
	testAxes.reserve(15);

	for (int i = 0; i < 3; ++i) testAxes.push_back(axesA[i]);
	for (int i = 0; i < 3; ++i) testAxes.push_back(axesB[i]);

	// 외적 축 (Edge-Edge 충돌 감지용)
	for (int i = 0; i < 3; ++i)
	{
		for (int j = 0; j < 3; ++j)
		{
			XMVECTOR cross = XMVector3Cross(axesA[i], axesB[j]);
			if (XMVectorGetX(XMVector3LengthSq(cross)) > 0.001f)
			{
				testAxes.push_back(XMVector3Normalize(cross));
			}
		}
	}

	// 4. SAT 알고리즘: 분리축 검사 및 최소 침투 깊이 찾기
	float minPenetration = std::numeric_limits<float>::max();
	XMVECTOR bestAxis = XMVectorZero(); // 초기화

	XMVECTOR centerDiff = centerA - centerB;

	for (const auto& axis : testAxes)
	{
		float rA =
			std::abs(XMVectorGetX(XMVector3Dot(axesA[0], axis))) * XMVectorGetX(extentsA) +
			std::abs(XMVectorGetX(XMVector3Dot(axesA[1], axis))) * XMVectorGetY(extentsA) +
			std::abs(XMVectorGetX(XMVector3Dot(axesA[2], axis))) * XMVectorGetZ(extentsA);

		float rB =
			std::abs(XMVectorGetX(XMVector3Dot(axesB[0], axis))) * XMVectorGetX(extentsB) +
			std::abs(XMVectorGetX(XMVector3Dot(axesB[1], axis))) * XMVectorGetY(extentsB) +
			std::abs(XMVectorGetX(XMVector3Dot(axesB[2], axis))) * XMVectorGetZ(extentsB);

		float dist = std::abs(XMVectorGetX(XMVector3Dot(centerDiff, axis)));
		float penetration = (rA + rB) - dist;

		// [핵심 수정] 
		// 침투 깊이가 0보다 작으면 두 박스 사이에 빈 공간이 있다는 뜻(분리축 발견)
		// 절대 충돌할 수 없으므로 즉시 false 반환 (최적화)
		if (penetration < 0.0f)
		{
			return { false, XMFLOAT3(0, 0, 0), XMFLOAT3(0, 0, 0) };
		}

		// 가장 얕게 겹친 축을 충돌 노멀로 저장
		if (penetration < minPenetration)
		{
			minPenetration = penetration;
			bestAxis = axis;
		}
	}

	// 15개 축 모두에서 겹침(penetration >= 0)이 발생했다면 충돌한 것!

	// 5. 노멀 방향 보정 (B에서 A를 밀어내는 방향으로 일관되게)
	if (XMVectorGetX(XMVector3Dot(bestAxis, centerDiff)) < 0)
	{
		bestAxis = XMVectorNegate(bestAxis); // DirectXMath 최적화 함수 사용
	}

	// 6. ColResult 결과 포장
	ColResult result;
	result.isCollide = true;

	// 노멀 벡터 저장
	XMStoreFloat3(&result.normal, bestAxis);

	// 밀어낼 벡터 (MTV) = 노멀 방향 * 최소 침투 깊이
	XMVECTOR mtv = XMVectorScale(bestAxis, minPenetration);
	XMStoreFloat3(&result.mtv, mtv);

	return result;
}

BoundingOrientedBox MakePlayerOOBB(const XMFLOAT3& position, float yawRad)
{
	BoundingOrientedBox obb;

	// 로컬 center를 위치만큼 평행이동
	// (로컬 center가 (0, 0.9, 0)이라 yaw 회전이 center에는 영향 없음)
	obb.Center.x = position.x + PLAYER_OOBB_CENTER.x;
	obb.Center.y = position.y + PLAYER_OOBB_CENTER.y;
	obb.Center.z = position.z + PLAYER_OOBB_CENTER.z;

	// Extents는 로컬값 그대로
	obb.Extents = PLAYER_OOBB_EXTENTS;

	// yaw를 Y축 회전 쿼터니언으로
	XMVECTOR q = XMQuaternionRotationAxis(
		XMVectorSet(0.0f, 1.0f, 0.0f, 0.0f), yawRad);
	XMStoreFloat4(&obb.Orientation, q);

	return obb;
}

BoundingOrientedBox MakeNpcOOBB(const XMFLOAT3& position, float yawRad)
{
	BoundingOrientedBox obb;

	// 로컬 center를 위치만큼 평행이동
	obb.Center.x = position.x + NPC_OOBB_CENTER.x;
	obb.Center.y = position.y + NPC_OOBB_CENTER.y;
	obb.Center.z = position.z + NPC_OOBB_CENTER.z;

	// Extents는 로컬값 그대로
	obb.Extents = NPC_OOBB_EXTENTS;

	// yaw를 Y축 회전 쿼터니언으로
	XMVECTOR q = XMQuaternionRotationAxis(
		XMVectorSet(0.0f, 1.0f, 0.0f, 0.0f), yawRad);
	XMStoreFloat4(&obb.Orientation, q);

	return obb;
}

std::vector<ColResult> CheckCollisionWithMap(const BoundingOrientedBox& playerOOBB, const std::vector<BoundingOrientedBox>& mapOOBBs)
{
	std::vector<ColResult> results;
	results.reserve(mapOOBBs.size());

	for (const auto& mapOOBB : mapOOBBs)
	{
		ColResult res = CalcCollision(playerOOBB, mapOOBB);
		if (res.isCollide)
		{
			results.push_back(res);
		}
	}

	return results;
}

float NearestWallHit(const XMVECTOR& origin, const XMVECTOR& dir,
	const std::vector<BoundingOrientedBox>& mapOOBBs, int* outWallIdx)
{
	float nearest = std::numeric_limits<float>::max();
	int   idx = -1;
	for (int i = 0; i < (int)mapOOBBs.size(); ++i) {
		float t;
		if (mapOOBBs[i].Intersects(origin, dir, t) && t >= 0.0f && t < nearest) {
			nearest = t;
			idx = i;
		}
	}
	if (outWallIdx) *outWallIdx = idx;
	return nearest;
}

XMFLOAT3 GetOOBBHitNormal(const BoundingOrientedBox& oobb, const XMFLOAT3& hitPos)
{
	XMVECTOR vHitPos = XMLoadFloat3(&hitPos);
	XMVECTOR vCenter = XMLoadFloat3(&oobb.Center);
	XMVECTOR vOrientation = XMLoadFloat4(&oobb.Orientation);

	XMVECTOR vInverseRot = XMQuaternionInverse(vOrientation);
	XMMATRIX matInverseRot = XMMatrixRotationQuaternion(vInverseRot);

	XMVECTOR vLocalHit = XMVector3TransformCoord(vHitPos - vCenter, matInverseRot);
	XMFLOAT3 localHit;
	XMStoreFloat3(&localHit, vLocalHit);

	float dx = abs(localHit.x) / oobb.Extents.x;
	float dy = abs(localHit.y) / oobb.Extents.y;
	float dz = abs(localHit.z) / oobb.Extents.z;

	XMFLOAT3 localNormal = { 0.0f, 0.0f, 0.0f };

	if (dx >= dy && dx >= dz) {
		localNormal.x = (localHit.x > 0.0f) ? 1.0f : -1.0f;
	}
	else if (dy >= dx && dy >= dz) {
		localNormal.y = (localHit.y > 0.0f) ? 1.0f : -1.0f;
	}
	else {
		localNormal.z = (localHit.z > 0.0f) ? 1.0f : -1.0f;
	}

	XMMATRIX matRot = XMMatrixRotationQuaternion(vOrientation);
	XMVECTOR vWorldNormal = XMVector3TransformNormal(XMLoadFloat3(&localNormal), matRot);
	vWorldNormal = XMVector3Normalize(vWorldNormal);

	XMFLOAT3 worldNormal;
	XMStoreFloat3(&worldNormal, vWorldNormal);

	return worldNormal;
}