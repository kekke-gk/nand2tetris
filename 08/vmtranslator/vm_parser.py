from enum import Flag, auto
from typing import Iterable
import re


class Command:
    def __init__(self, line: str) -> None:
        self.line: str = line
        self.type: Command.Type = self.__analyze()

    def __repr__(self) -> str:
        return f"{self.line}({self.type.value})"

    class Type(Flag):
        C_ARITHMETIC = auto()
        C_PUSH = auto()
        C_POP = auto()
        C_LABEL = auto()
        C_GOTO = auto()
        C_IF = auto()
        C_FUNCTION = auto()
        C_RETURN = auto()
        C_CALL = auto()

    def __analyze(self) -> Type:
        self.args: list[str] = self.line.split()
        if self.args[0] == "push":
            return self.Type.C_PUSH
        if self.args[0] == "pop":
            return self.Type.C_POP
        return self.Type.C_ARITHMETIC


def parse_all(lines: list[str]) -> list[Command]:
    lines = remove_white_space(lines)
    commands: list[Command] = list(map(Command, lines))
    return commands


def remove_white_space(lines: Iterable[str]) -> list[str]:
    lines = map(lambda line: re.sub(r"\/\/.*", "", line), lines)
    lines = map(lambda line: line.strip(), lines)
    lines = filter(None, lines)
    lines = list(lines)
    return lines
