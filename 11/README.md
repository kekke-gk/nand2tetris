# Project 11: Compiler II: Code Generation

前回の続きとして、Jack言語用コンパイラのコード生成部分を作りコンパイラを完成させた。

前回の時点ですでに講義スライドの設計とは違う設計になっていたが、
今回でより一層講義スライドと異なる設計になった。
例えば、スライドでは`VMWriter`というクラスがあるが、今回の実装では`Term`や`Expression`などの各要素の`vmcode`というメソッドに処理が分けたため`VMWriter`は存在しない。

今までは一通り完成したと思ってから各テストを行っていたが、今回は各テストに必要な部分のみ作ってはテストするという手順で進めた。

テストでは与えられたコンパイラと出力が同じであるかの確認をした。
一部、スライドと与えられたコンパイラで仕様が異なる部分があり、テストに手間取った。
最終的にスライドではなく与えられたコンパイラと同じ出力をするような実装をした。
また、if文やwhile文でのラベルの命名も与えられたコンパイラの出力を確認してそれと同じになるような実装をした。

例えば下のようなif文について、スライドとコンパイラで以下のような違いがあった。

```
if (expression) {
    statementTrue
} else {
    statementFalse
}
```

```
// スライドに書いてある仕様
    expression
    not
    if-goto L1
    statementTrue
    goto L2
label L1
    statementFalse
label L2
```

```
// 与えられたコンパイラの仕様
    expression
    if-goto L_TRUE
    goto L_FALSE
label L_TRUE
    statementTrue
    goto L_END
label L_FALSE
    statementFalse
label L_END
```
