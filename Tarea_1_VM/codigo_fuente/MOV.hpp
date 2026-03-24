#pragma once
#include "Instruction.hpp"

class MOV : public Instruction {
private:
    std::string reg;
    int addr;

public:
    MOV(std::string r, int a);
    void execute(CPU& cpu, Memory& memory) override;
    std::string toString() override;
};