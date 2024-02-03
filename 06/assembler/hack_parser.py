import re
from enum import Enum
from typing import Iterable

class Instruction:
    def __init__(self, line: str) -> None:
        self.line: str = line
        self.type: Instruction.Type = self.__analyze()

    def __repr__(self) -> str:
        return f'{self.line}({self.type.value})'

    class Type(Enum):
        A = 'A'
        C = 'C'
        L = 'L'

    def __analyze(self) -> Type:
        if self.line[0] == '@':
            return self.__analyze_a()
        elif self.line[0] == '(':
            return self.__analyze_l()
        else:
            return self.__analyze_c()

    def __analyze_a(self) -> Type:
        num: list[str] = re.findall(r'@(\d*)', self.line)
        if num and num[0]:
            self.value: int = int(num[0])
        else:
            self.symbol: str = self.line[1:]

        return self.Type.A

    def __analyze_c(self) -> Type:
        self.dest: str = ''
        if len(d := re.findall(r'(.*)=', self.line)) == 1:
            self.dest = d[0]

        self.comp: str = re.sub(r';.*', '', re.sub(r'.*=', '', self.line))

        self.jump: str = ''
        if len(j := re.findall(r';(.*)', self.line)) == 1:
            self.jump = j[0]

        return self.Type.C

    def __analyze_l(self) -> Type:
        self.symbol = re.findall(r'\((.*)\)', self.line)[0]
        return self.Type.L

def parse_all(lines: list[str]) -> list[Instruction]:
    lines = remove_white_space(lines)
    instructions: list[Instruction] = list(map(Instruction, lines))
    return instructions

def remove_white_space(lines: Iterable[str]) -> list[str]:
    lines = map(lambda line: re.sub(r'\/\/.*', '', line), lines)
    lines = map(lambda line: line.strip(), lines)
    lines = filter(None, lines)
    lines = list(lines)
    return lines
