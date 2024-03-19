# Project 10: Compiler I: Syntax Analysis

Jack言語用のコンパイラのうち構文解析部分まで作成した。

構文解析ではJack言語で書かれたソースコードを入力として受け取り、構文解析をした結果をXMLファイルとして出力する。

作成は字句解析器(Tokenizer)の作成と構文解析器(Syntax Analyzer)の作成の2段階にわけて行った。
それに合わせて答えとなるXMLファイルも2種類用意されていて、
`Hoge.xml`と`HogeT.xml`の2種類のうち、前者が構文解析器の出力ファイル、後者が字句解析器の出力ファイルとなっている。
作成したプログラムもそれにならい、構文解析器の結果は`Hoge_.xml`に字句解析器の結果は`HogeT_.xml`にそれぞれ出力するようにした。

## 感想・気づいたこと

今回は2段階にわけて作成を行ったが、作者は

1. 字句解析器
2. Expression以外に対応した構文解析器
3. Expressionにも対応した完全な構文解析器

の3段階にわけて作成することを推奨しているようである。
そのためにSquareというプログラムからExpressionを取り除いたExpressionLessSquareというプログラムが用意されている。

作者が構文解析器を2段階目と3段階目にわけることを推奨しているのは、
ExpressionのみがLL(2)文法になっているからだと思われる。

[公式の講義スライド](https://drive.google.com/file/d/1CM_w6cxQpYnYHcP-OhNkNU6oD5rMnjzv/view)の39ページに書いてあるように、
Jack言語の文法はExpression以外はLL(1)であるらしい。
きちんと理解していないが、一般にLL(k)というのはk個先までトークンを読めばどの要素なのかわかるような文法であるらしい。
つまりJack言語は基本的に1個先を見るだけでどの要素なのかわかるシンプルな言語であるということである。
メソッドの呼び出しをする`doStatement`で、先頭に`do`というキーワードが必要なのはLL(1)文法にするためであると思われる。

Jack言語の文法が表として与えられるが、その中のすべての要素がXMLのタグを持っているわけではないという点に注意が必要である。
例えば、表の中にはsubroutineCallという要素があるが`<subroutineCall></subroutineCall>`というタグはXMLには登場しない。

今まで作ってきたアセンブラなどはPythonで書いていたが、今回はSwiftを使ってみた。
SwiftはPythonと比べて文字列の操作が複雑でわかりづらく感じた。
しかし、Null安全や強力なenumはとても良かった。

構文解析のことを考えず字句解析器を実装したため、構文解析器を実装するときに大きな修正が発生してしまった。
enumとして定義していたTokenを削除し、その代わりにElementプロトコルやTerminalElementプロトコルを定義した。

コマンドライン引数を受け取るために公式が提供している[ArgumentParser](https://github.com/apple/swift-argument-parser)というライブラリを使った。
