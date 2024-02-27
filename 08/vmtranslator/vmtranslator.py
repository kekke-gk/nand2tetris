#!/usr/bin/env python

from pathlib import Path
import argparse

from code_writer import CodeWriter


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("vm_path")
    args = parser.parse_args()
    vm_path = Path(args.vm_path)

    assert vm_path.exists()

    if vm_path.is_dir():
        asm_path: Path = vm_path / vm_path.with_suffix(".asm").name

        vm_files: list[Path] = list(vm_path.glob("*.vm"))

        assert vm_files

        code_writer = CodeWriter(asm_path)
        code_writer.write_files_with_bootstrap(vm_files)
    else:
        assert vm_path.suffix == ".vm"

        asm_path: Path = vm_path.with_suffix(".asm")

        code_writer = CodeWriter(asm_path)
        code_writer.write_file_with_endloop(vm_path)
