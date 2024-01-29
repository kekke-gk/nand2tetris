# Project 2: Boolean Arithmetic

Project 1で作成した論理ゲートを使って、ALU(Arithmetic and Logic Unit)とそれに使う加算器・インクリメンタなどを作成した。

- `x[n]=true`とすることで多ビットバスの特定ビットのみに`1`を入力することができる。

- ALU作成時、`Sub bus of an internal node may not be used`というエラーが発生した。

ALUの16bitの出力を8bitずつに分割してOrに入力する際、以下のように記述するとエラーとなる。  

```
Mux16(a=a, b=b, sel=sel, out=out);
Or8Way(in=out[0..7], out=or0);
Or8Way(in=out[8..15], out=or1);
Or(a=or0, b=or1, out=or);
```

これを解決するには、以下のように新たなバスを定義するとよい。

```
Mux16(a=a, b=b, sel=sel, out[0..7]=out0to7, out[8..15]=out8to15, out=out);
Or8Way(in=out0to7, out=or0);
Or8Way(in=out8to15, out=or1);
Or(a=or0, b=or1, out=or);
```
