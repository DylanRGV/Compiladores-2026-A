#include "Memory.hpp"

Memory::Memory(int size) {
    data.resize(size, 0);
}

int Memory::read(int addr) {
    return data[addr];
}

void Memory::write(int addr, int value) {
    data[addr] = value;
}