#pragma once
#include <vector>
#include <string>  

class Instruction;
class Memory;

class CPU {
public:
    int PC = 0;
    int MAR = 0;
    int MBR = 0;
    int ACC = 0;

    int AL = 0, BL = 0;

    Instruction* IR;

    bool running = true;

    void fetch(std::vector<Instruction*>& program);
    void decode();
    void execute(Memory& memory);

    void printState(std::string stage);
};