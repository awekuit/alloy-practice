
前回の File System はこのようにしていたが、これには問題があるので、それを修正していく。

```alloy
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

Q. `live in root.*contents` の問題点は？

A. root から到達できるのに live ではない FSObject が存在してしまう。
もし、そうではなく「root から到達できる FSObject は live である」としたいなら、こう書く。
```alloy
live = root.*contents
```
これなら、root から contents で到達できる FSObject の集合が live になる。
(ちなみに、ここは appended fact なので `=` は代入ではなく filter の条件であり、他言語の `==` のようなものである事に注意)

Q. この状態ではまだ、contents と parent のタプルにはまだ FileSystem に存在しないタプルも保持している。なぜか？

A. なぜなら `contents: Dir lone -> FSObject` はあくまで Dir からあらゆる FSObject に contents という関係で辿れることしか示しておらず FileSystem の他のフィールド(root や live)との関連性が一切ないから。preant も同様の状況。
(この辺りは、OOP的な感覚の捨て所かもしれない。FileSystem のフィールドとして contents があってもこれはあくまで `Dir lone -> FSObject` を満たす全ての直積を示している)

そのため、FileSystem の root から辿っていけない FSObject 同士が勝手に contents, parent の関係で繋がっている。

Q. ↑の状況を避けたいなら、どうするか？

A. 次の制約を加える
```alloy
contents in live -> live
```
ちなみに `in` の代わりに `=` とすると run しても No Instance になる。
これは live 自体が `live = root.*contents` でそこで使われている contents が live -> live と言われてもそれらを満たすような live が存在しないから・・？
もしくは別方向から解釈すると「`in` による部分集合は互いに素とは限らない」というのが、こういう所で単に制約として書くのに適している・・？(まぁ fact では in 書くのが基本っぽいけども)

まぁ単純に、live も最初は `live in root.*contents` と書いていたことだし、 単にゆるく制約を与えるなら in はわかりやすい。
`contents in live -> live` も live がすでに定まってるなら live -> live な直積集合の部分集合になるようフィルタリングするというのは、とてもわかり易い。

ちなみに、この制約を足してもあくまで、「rootから辿れない Dir や File が勝手に contents / parent で繋がっている」というパターンが無くなるだけで、root から辿れない Dir や File はまだ存在する事に注意。