#pragma once
#include <vector>

class Memory {
private:
    std::vector<int> data;

public:
    Memory(int size);
    int read(int addr);
    void write(int addr, int value);
};