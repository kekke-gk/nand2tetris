#!/usr/bin/env python

from pathlib import Path
import argparse

from hack_parser import parse_all, Instruction
from code import dest_table, comp_table, jump_table
from symbol_table import SymbolTable

def assemble(lines: list[str]) -> list[str]:
    instructions: list[Instruction] = parse_all(lines)

    symbol_table: SymbolTable = create_symbol_table(instructions)

    bincodes: list[str] = [instruction2bincode(instruction, symbol_table) for instruction in instructions]
    bincodes = list(filter(None, bincodes))

    return bincodes

def create_symbol_table(instructions: list[Instruction]) -> SymbolTable:
    symbol_table: SymbolTable = SymbolTable()

    address: int = 0
    for instruction in instructions:
        if instruction.type == Instruction.Type.L:
            symbol_table[instruction.symbol] = address
        else:
            address += 1

    return symbol_table

def instruction2bincode(instruction: Instruction, symbol_table: SymbolTable) -> str:
    if instruction.type == Instruction.Type.L:
        return ''

    if instruction.type == Instruction.Type.A:
        if hasattr(instruction, 'symbol'):
            symbol = instruction.symbol
            if symbol not in symbol_table:
                symbol_table.add_variable(symbol)
            return f'{symbol_table[symbol]:016b}'
        else:
            return f'{instruction.value:016b}'

    if instruction.type == Instruction.Type.C:
        comp = comp_table[instruction.comp]
        dest = dest_table[instruction.dest]
        jump = jump_table[instruction.jump]
        return f'111{comp}{dest}{jump}'

    raise Exception('instruction')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('asm_path')
    args = parser.parse_args()
    asm_path = Path(args.asm_path)

    assert asm_path.is_file()
    assert asm_path.suffix == '.asm'

    hack_path = asm_path.with_suffix('.hack')

    with asm_path.open('r') as f:
        lines = f.readlines()

        assert lines

    with hack_path.open('w') as f:
        bincodes = assemble(lines)
        f.writelines(map(lambda x: x + '\n', bincodes))
