# Project 7: VM I: Stack Arithmetic

本プロジェクトではコンパイラが高級言語から直接機械語を出力する方法ではなく、
コンパイラは仮想マシン用の中間言語を出力し、その中間言語を機械語に変換する2段階のプロセスを採用している。

今回は中間言語から機械語（アセンブリ言語）への変換器を途中まで作成した。

変換器の実装にはPythonを利用した。

- 資料に書いてある仕様どおりに変換器を実装したが、そもそもなぜこの仕様であるべきなのかについては理解できなかった。

- `R13, R14, R15`が汎用レジスタのなっているのでpopやaddなどをするときにはそこを利用する。

  - 他の`R0`から`R12`は用途が決まっているため注意。

- `eq, gt, lt`命令では結果が真のとき`-1`、偽のとき`0`をpushする。
