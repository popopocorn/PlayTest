#pragma once

#include <vector>
#include <array>
#include <functional>
#include <DirectXMath.h>

using namespace DirectX;

struct tempNavMesh {
    int vertexCnt{};
    int polyCnt{};
    std::vector<XMFLOAT3> vertices;
    std::vector<int>      idx;
};

struct NavigationPoly
{
    int                 ID;
    std::array<XMFLOAT3, 3>  positions;
    std::array<int, 3>       vindex;
    std::array<int, 3>       neighborIDs = { -1, -1, -1 };
    XMFLOAT3            centroid    = XMFLOAT3(0.0, 0.0, 0.0);
};

class AstarNavigation
{
private:
    std::vector<NavigationPoly> mesh;

private:
    void              BuildMesh(const tempNavMesh& m);
    void              FindNeighbor();
    std::vector<XMFLOAT3>  FindPathPoint(std::vector<int> polyidx, XMFLOAT3 start, XMFLOAT3 end);

public:
    void              LoadNavMeshFromFile(const char* file);
    std::vector<XMFLOAT3>  FindPath(XMFLOAT3 start, XMFLOAT3 end);
    int               FindPolyID(const XMFLOAT3& pos);
};

struct AStarNode {
    int   polyID;
    int   parentID;
    float gCost;
    float hCost;

    float GetCost() const { return gCost + hCost; }

    bool operator>(const AStarNode& other) const
    {
        return GetCost() > other.GetCost();
    }
};
