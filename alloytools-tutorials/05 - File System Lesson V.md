これまで作ってきた FileSystem に `move` 操作を追加する・・前に少し周辺の整理をする。

命令的(=手続き的)モデルの場合、あなたは「どうやったらXを起こせるのか？」を自問自答するだろう。
(alloyのような)宣言的モデルの場合、「Xが充足したことをどう認識したら良い？」と自問自答するだろう。

手続き型言語では、`move` 関数の引数としてFileSystem,移動したいオブジェクト,移動先のディレクトリを渡せば移動後の FileSystem を返すように実装できる。
Alloy ではこの場合の出力(≒返り値と捉えて良さそう)を含めて関数の引数として渡し、関数は、入力パラメータが渡された場合に出力パラメータが有効なら true を、そうでなければ false を返すようにすれば良い。
そうして後で「この関数が常に true であること」を求めれば、有効な移動が発生した例を得ることができる。
例えばこう。

```alloy
pred move [fs, fs': FileSystem, x: FSObject, d: Dir] {
    (x + d) in fs.live
    fs'.parent = fs.parent - x -> (x.(fs.parent)) + x -> d
}
```

まず `[]` により、このように引数を定義できる。

`fs` はファイルシステムの移動前の状態で、`fs'` はファイルシステムの移動後の状態、と捉える事ができる。
(ちなみに `'` にAlloy上に特別な意味がある訳ではない。どんな名前でも良い)

ちなみに、 -> の結合優先順位は + や - より高いので、明示的にカッコを付けるならこうなる。
```alloy
fs'.parent = fs.parent - (x -> (x.(fs.parent))) + (x -> d)
```

`x.(fs.parent)` は `fs.parent` が live -> Dir なのでそれと x を join すると、x にマッチするような fs.parent(つまり live -> Dir) が得られ、それと結合して Dir が得られる。この Dir は x とマッチしているものなので、x の元々の parent dir.

なので `x -> (x.(fs.parent))` は、 x とその x の元の親との(直積による)関係。

`fs.parent - ...` は、元の fs の持つ parent 関係集合からこれ↑を引くので、つまり x とその親への関係(= parent) の削除を表してる。
あとは、x の新しい親である d との関係を `x -> d` で表してそれを `+` で結合すれば、x の移動が完了する。

--

同様のノリで、単一の FSObject を削除する `remove` や再帰的に削除する `removeAll` を記述するとこう。
`move` とほぼ同じなので、解釈自体はできると思う。(subtree が反射的推移閉包なのでちょっと飲み込みづらいくらいで)

```alloy
// Delete the file or directory x
pred remove [fs, fs': FileSystem, x: FSObject] {
  x in (fs.live - fs.root)
  fs'.parent = fs.parent - x->(x.(fs.parent))
}

// Recursively delete the object x
pred removeAll [fs, fs': FileSystem, x: FSObject] {
  x in (fs.live - fs.root)
  let subtree = x.*(fs.contents) |
      fs'.parent = fs.parent - subtree->(subtree.(fs.parent))
}
```

 --

moveOkay, removeOkay, removeAllOkay の check については
「`=>` (含意) をこのように使えば、事後状態を書けるのだな」
という以外目新しいことはないので省略する。