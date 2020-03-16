先程の remove, removeAll の反例を探すとスコープ 2 で(= `for 2` で)反例が見つかる。

viewer を projection: FileSystem にしたまま、tutorial のように Implies の前後の状態を見分ける方法がよくわからなかったが、projection: none に戻せばどうにか分かる。
projection: none の場合は
- `($removeOkay_fs)` のラベルがある方が削除前の FileSystem で、`($removeOkay_fs')` が削除後
- 削除前は、Dir0, Dir1 が live で、Dir0 が root.
- 削除前の FileSystem から Dir0 へ `parent` の線が伸びてるのはよくわからない
  - turorial によると Dir1 の parent が Dir0 になるようなのだが
- 削除するのは Dir1 らしいがそれは図からは読み取れず

Q. remove の定義は次の通り。これで上記のような「root の移動」が生じる理由は？
```alloy
pred remove [fs, fs': FileSystem, x: FSObject] {
  x in (fs.live - fs.root)
  fs'.parent = fs.parent - x->(x.(fs.parent))
}
```

A.
- まず、`fs'` は `fs` から元を1つ取り除いたもの...という意味で`fs`の部分集合である
- root というのは `live in root.*contents` という形で、contents を辿る時の出発点である、としか規定されていない。そのため...
  - remove してもまだ `fs'` に contents がある状況なら、`fs` と `fs'` の root は同じで今回のような事は起きない
  - remove した結果 `fs'` に contents か空になる状況(今回のケース)だと、`root.*contents` は `iden` 的にしか作用しなくなり、単独の dir なら root かつ live と見なせるようになってしまって、今回の状況になる・・？

ちょっとよくわからず。

修正するなら以下のようにする、というのはわかる。

```alloy
pred remove [fs, fs': FileSystem, x: FSObject] {
  x in (fs.live - fs.root)
  fs'.root = fs.root
  fs'.parent = fs.parent - x->(x.(fs.parent))
}
```

このわかりにくい反例は、FileSystem の root や live の周りの記述を洗練しすぎたが故のような気がしないでもない。
あえてモデルを元に戻す事で直ったりしないのか？試してみる。
→ File System Model III にする程度では意味がない。結局 `live = root.*contents` としているからかな・・？