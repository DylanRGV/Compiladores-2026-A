#pragma once
#include "Instruction.hpp"

class ADD : public Instruction {
public:
    void execute(CPU& cpu, Memory& memory) override;
    std::string toString() override;
};