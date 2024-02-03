class SymbolTable(dict[str, int]):
    R_NUM: int = 16

    def __init__(self) -> None:
        self.__add_predefined_symbols()
        self.variables_num: int = 0

    def __add_predefined_symbols(self) -> None:
        self.update({f'R{i}': i for i in range(self.R_NUM)})
        self['SCREEN'] = 16384
        self['KBD'] = 24576
        self['SP'] = 0
        self['LCL'] = 1
        self['ARG'] = 2
        self['THIS'] = 3
        self['THAT'] = 4

    def add_variable(self, symbol: str) -> None:
        self[symbol] = self.R_NUM + self.variables_num
        self.variables_num += 1
