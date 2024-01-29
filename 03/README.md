# Project 3: Memory

DFF(D Flip-Flop)をベースに、Bit・Register・RAMなどの記憶回路とPC(Program Counter)を作成した。

今まではシンプルな組み合わせ回路だったが、今回からはクロック信号や記憶回路のある順序回路が登場し、徐々に複雑になってきている。

- そのままではテストに時間がかかるため、Hardware Simulator画面上部にある速度調整バーを一番右のFastまで動かして、素早くテストできるようにした。

- RAM8, RAM64, RAM512と8倍ずつ大きなRAMを作っていくが、最後のRAM4KからRAM16Kは8倍ではなく4倍である点に注意。

  - [公式のスライド](https://drive.google.com/file/d/1boFooygPrxMX-AxzogFYIZ-8QsZiDz96/view)の53ページに  
  `Why stop at RAM16K? Because that's what we need for building the Hack computer.`  
  とあり、RAM32Kまで行かずRAM16Kで止めたのはこれから作るHackコンピュータに必要なのが16Kまでであるからのようである。

- Bitの作成では出力を入力に接続する、いわゆるフィードバックが存在するが、`Can't connect gate's output pin to part`というエラーが発生した。

DFFの出力`out`をMuxに入力する以下のコードを実行するとエラーとなる。

```
Mux(a=out, b=in, sel=load, out=mux);
DFF(in=mux, out=out);
```

エラーメッセージを参考に、Bitの出力ピンである`out`ではなく新たな`pout`というピンを使って以下のようにフィードバックを記述することで解決した。

```
Mux(a=pout, b=in, sel=load, out=mux);
DFF(in=mux, out=pout, out=out);
```

- [公式のガイドライン](https://drive.google.com/file/d/1ArUW8mkh4Kax-2TXGRpjPWuHf70u6_TJ/view)にあるように`PC.hdl`のコメントに間違いがあった。

以下は間違いであり、

```
if      (inc(t))   out(t+1) = out(t) + 1
else if (load(t))  out(t+1) = in(t)
else if (reset(t)) out(t+1) = 0
else               out(t+1) = out(t)
```

以下が正しい。  
上の式ではincが最優先されているが、下の式ではresetが最優先されている。  
例えば、`inc`と`reset`の入力が同時に`1`だったとき、上の実装ではインクリメントを行うが下の実装ではリセットを行うことになり、動作が変わってくる。

```
if reset(t): out(t+1) = 0
else if load(t): out(t+1) = in(t)
else if inc(t): out(t+1) = out(t) + 1
else out(t+1) = out(t)
```
