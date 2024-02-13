#!/usr/bin/env python

from pathlib import Path
import argparse

from vm_parser import parse_all, Command
from code_writer import CodeWriter


def translate(lines: list[str], filename: str) -> list[str]:
    commands: list[Command] = parse_all(lines)

    code_writer = CodeWriter(filename)
    asmcodes: list[str] = code_writer.commands2asmcodes(commands)

    return asmcodes


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("vm_path")
    args = parser.parse_args()
    vm_path = Path(args.vm_path)

    assert vm_path.is_file()
    assert vm_path.suffix == ".vm"

    with vm_path.open("r") as f:
        lines = f.readlines()

        assert lines

    asm_path = vm_path.with_suffix(".asm")

    with asm_path.open("w") as f:
        asmcodes = translate(lines, vm_path.stem)
        f.writelines(map(lambda x: x + "\n", asmcodes))
