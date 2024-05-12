# Project 12: Operating System

今まで当然のように使っていた、OSが提供する配列・文字列・算術などの処理を作成した。
講義スライドにしたがって、以下の順に実装を進めた。

1. `Math.jack`
1. `Memory.jack`
1. `Screen.jack`
1. `output.jack`
1. `Keyboard.jack`
1. `String.jack`
1. `Array.jack`
1. `Sys.jack`

`Math.jack`では掛け算や割り算の処理を効率的に行うアルゴリズムで実装した。
他の実装をしていて、シフト演算やモジュロ演算がないのは少し不便でかつプログラムがわかりづらくなると感じる場面があった。

`Memory.jack`の`deAlloc`関数では発展課題としてdefragmentation処理があったが、今回そこまでは行わなかった。
そのため、`alloc`・`deAlloc`を繰り返すとだんだんとHeapが細かいblockに分割されていき、大きな領域を確保できなくなったり、blockの数に比例して生まれるオーバーヘッドによって領域が無駄に利用されてしまったりする。

`Sys.jack`の`init`では深く考えず、各ファイルの`init`を実装した順番に呼び出した。
しかし、`Math.jack`の`init`内では`Array`を使っていて`Array`内では`Memory`を使っているため、`Memory.init`が呼び出される前に`Memory`を使うことになってしまいエラーとなった。
`Math.init`の前に`Memory.init`を呼び出すように順番を変更することでエラーが解消された。

各ファイルごとのテストが終わり、最後のテストとして今まで作成したすべてのファイルを`projects/11/Pong`にコピーして実行したが、エラーなく動作はしたが表示が遅すぎてまともにプレイできなかった。
試しに`Screen.jack`のみ削除するとスムーズに動くようになったため、`Screen.jack`の実装に非効率な部分があると考えられる。
