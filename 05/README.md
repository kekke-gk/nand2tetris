# Project 5: Computer Architecture

HDLで`Memory`と`CPU`を作成し、それを利用して`Computer`まで作成した。

- `Memory.hdl`では、入力`address`の13bit目と14bit目を利用することで、`RAM16K, Screen, Keyboard`のうちどれにアクセスしようとしているか判断できる。

- `CPU.hdl`ではわかりやすさのために最初に`Or16`を配置した。

- `CPU.hdl`の`PC`の入力`inc`は常にtrueで問題ない。
