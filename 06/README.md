# Project 6: Assembler

Hackアセンブリ言語用のアセンブラをPythonで作成した。
出力ファイルを提供されたアセンブラの比較ファイルに指定することで自作アセンブラのテストを行った。

- 提供されたアセンブラにバグがあるためか、`Pong.asm`内に仕様上存在しないはずの`MD=`で始まる行が存在する。

  - バグの内容はガイドラインの`Known bug`で説明されている。

  - これに対処するため、`code.py`の`dest_table`に`MD`と`AMD`の項目を追加した。
