#!/usr/bin/env python

from pathlib import Path
import argparse

from vm_parser import parse_all, Command
from code_writer import CodeWriter


def translate(code_writer, lines: list[str], filename: str) -> list[str]:
    commands: list[Command] = parse_all(lines)

    # code_writer = CodeWriter(filename)
    code_writer.filename = filename
    asmcodes: list[str] = code_writer.commands2asmcodes(commands)

    return asmcodes


def translate_and_write(code_writer, vm_path, asm_path):
    with vm_path.open("r") as f:
        lines = f.readlines()

        assert lines

    with asm_path.open("a") as f:
        asmcodes = translate(code_writer, lines, vm_path.stem)
        f.writelines(map(lambda x: x + "\n", asmcodes))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("vm_path")
    args = parser.parse_args()
    vm_path = Path(args.vm_path)

    assert vm_path.exists()

    if vm_path.is_dir():
        asm_path = vm_path / vm_path.with_suffix(".asm").name

        vm_paths = list(vm_path.glob("*.vm"))

        assert vm_paths

        code_writer = CodeWriter()
        asmcodes: list[str] = code_writer.bootstrap_asmcodes()

        with asm_path.open("w") as f:
            f.writelines(map(lambda x: x + "\n", asmcodes))

        for vm_file in vm_paths:
            translate_and_write(code_writer, vm_file, asm_path)

        
        with asm_path.open('r') as f:
            lines = f.readlines()

        lines = list(map(lambda line: line.strip(), lines))

        i = 0
        lines_num = []
        for line in lines:
            if line.startswith('//'):
                lines_num.append(line + f' {i}')
            elif line.startswith('('):
                lines_num.append(line)
            else:
                i += 1
                lines_num.append(line)

        with asm_path.open('w') as f:
            f.writelines(map(lambda x: x + "\n", lines_num))


    else:
        assert vm_path.suffix == ".vm"

        asm_path = vm_path.with_suffix(".asm")
        translate_and_write(vm_path, asm_path)
