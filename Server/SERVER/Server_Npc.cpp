#include "Server_Npc.h"

// NpcInputQueue
NpcInputQueue g_npc_input_queue;

void NpcInputQueue::Push(NpcInputEvent e)
{
    std::lock_guard<std::mutex> lk(_mtx);
    _events.push_back(std::move(e));
}

void NpcInputQueue::DrainTo(std::vector<NpcInputEvent>& out)
{
    // 이전 out 비운 뒤 swap 하기
    out.clear();
    std::lock_guard<std::mutex> lk(_mtx);
    std::swap(out, _events);
}