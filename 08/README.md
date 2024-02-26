# Project 8: VM II: Program Control

前回から引き続き、中間言語からアセンブリ言語への変換器を作成した。

変換器は`.vm`ファイルもしくは`.vm`ファイルを含むディレクトリを入力として受け取って実行する。
入力がディレクトリの場合は、そのディレクトリに含まれるすべての`.vm`ファイルを変換し一つの`.asm`ファイルに出力する。

入力がディレクトリの場合は、Bootstrapコードをファイルの先頭に挿入して出力する。

テストは全部で6つあり、最初の3つ(BasicLoop, FibonacciSeries, SimpleFunction)はファイルが入力であり、最後の3つ(NestedCall, FibonacciElement, StaticTest)はディレクトリが入力である。

## 感想・気づいたこと

- localセグメントへの理解が足りておらず、`NestedCall`でのテスト時に行き詰まった
  - `function`命令を変換すると、ラベルの作成とlocalセグメントへの変数の確保になる
  - `function`前の`call`によって`SP`と`LCL`が同一になるため、localセグメントへの変数の確保は下のように単に変数の数だけ`push constant 0`すればいい

    ```
    // 誤
    // localに0をpushするつもりだったが、これではlocalの0番地をpushしている
    push local 0

    // 誤
    // 上の誤りを見て、localに書き込むにはpopしなければならないと思い修正した
    push constant 0
    pop local 0

    // 正
    push constant 0
    ```

- デバッグにあたって、ROMに読み込まれたときのアドレス付きのコメントがあると便利
  - CPU Emulatorのbreakpointの機能を使うことで特定のアドレスまでスキップすることができる

- `FibonacciElementVME.tst`などのVM Emulator用のテストだとStack Pointerを261にセットしてからテストしている
  - これはCPU Emulator用のテストの場合はBootstrapコード内で`call`命令を実行することで`Sys.init`開始時にはStack Pointerが5ずれて261(=256+5)になるからだと考えられる
