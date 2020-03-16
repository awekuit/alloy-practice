
前回の File System は単一かつ静的だったので

- 複数の File System
- 移動や削除などの操作

を可能とする File System を作っていくとする。

```alloy
abstract sig FSObject { }

// File system objects must be either directories or files.
sig File, Dir extends FSObject { }

// A File System
sig FileSystem {
  root: Dir,
  live: set FSObject,
  contents: Dir lone -> FSObject,
  parent: FSObject -> lone Dir
}  {
    // root has no parent
    no root.parent
    // live objects must be reachable from the root
    live in root.*contents
    // parent is the inverse of contents
    parent = ~contents
}
```

この contents の `->` は直積(矢印積)。詳細は[こちら](Syntax for the relational product (->) operator)にある。

- 2つのリレーション p と q の積を p -> q と記述できる
- p -> q は、p からのタプルと q からのタプルの全ての組み合わせを取得しそれらを連結するこのによって得られるリレーションの集合
- つまり [join](https://alloytools.org/tutorials/online/sidenote-relational-join.html)(`p.q`) と似ているが、join と違ってマッチングをしないしマッチしたアトムの削除などもしない。
  - join は p のタプルの最後のアトムのみが q のタプルの最初のアトムとマッチし、そのマッチしたアトムは join 後の tuple から削除される、という挙動をする

<私見>
- tuple は平易な概念でいうと「集合の要素」と言い変えても良い(日本の数学用語だと元)。たとえば整数の集合があったら、1,2,3,4,5,... のような各要素は 1-tuple と言えるので、そういった 1-tuple な整数値の集合が整数の集合なのだ、言い表すようなノリなのだと思う
- 要素と言わずに tuple と表現するのは、集合の要素自体が複数の構成要素を持つ(つまり n-tuple)であるとしてより汎化した扱いとして tuple としているのだと・・思う
- そして 2-tuple はおそらく関係を表す・・？ つまり (1,a) という tuple は 1 を与えたら a を返す関数的な役割としての`関係`なのだと思う。ここでいう 1 を与える(関数適用する)のが join(`a.b`) の[模様](https://www.slideshare.net/konn/alloy-analyzer-9379488/29)
- 追記:[この辺り](https://alloytools.org/tutorials/online/sidenote-relations-are-ordered-pairs.html)に書いてあるようだ

上記 contents は、「各FSObjectは、与えられた File System 内の多くとも1つのディレクトリに(contentsとして)含まれる」事を表している。
つまり、FSObject とは 0 or 1 つの Dir に含まれるという事。0 というのは root ディレクトリだろう。
上記 parent も同じようなもので、各FSObjectは多くとも1つの Dir を親に持つことを表している。つまり、FSObjectの親Dirが2つあるなんて事はなく、親Dirが0個というのはありうる(おそらく root だろう)。

`live in root.*contents` は、root から0回以上 contents を辿れば `live: set FSObject` としていた FSObject の集合に辿り着けることを示している。引っ掛かるのは root の型である Dir が contents というフィールドを持っておらず FileSystem の方にそれが定義されているのに、このように呼べてしまう事だが、この FileSystem.contents

`parent = ~contents` は、parent と contents がそれぞれ1引数で1返り値の関数的なもの([二項関係](https://ja.wikipedia.org/wiki/%E4%BA%8C%E9%A0%85%E9%96%A2%E4%BF%82))を tuple で表しているので、tuple の順序をひっくり返せば等しくなる事を表している。

ちなみに、これら制約を単体の fact で書くならこう。
```alloy
fact {
  all fs: FileSystem {
    no fs.root.(fs.parent)
    fs.live in fs.root.*(fs.contents)
    fs.parent = ~(fs.contents)
  }
}
```
ちなみにこのように `all fs: FileSystem { }` の中に入れることで、3つの記述の先頭にいちいち `all fs: FileSystem | ` と付けなくても良くなる。

