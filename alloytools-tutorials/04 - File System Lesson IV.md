前回のコードをもっとわかりやすく単純なコードに置き換えていく。
前回はこう
```alloy
// A file system object in the file system
abstract sig FSObject { }

// File system objects must be either directories or files.
sig File, Dir extends FSObject { }

// A File System
sig FileSystem {
  root: Dir,
  live: set FSObject,
  contents: Dir lone-> FSObject,
  parent: FSObject ->lone Dir
}{
  // root has no parent
  no root.parent
  // live objects sare those reachable from the root
  live = root.*contents
  // contents only defined on live objects
  contents in live->live
  // parent is the inverse of contents
  parent = ~contents
}
```

Q. `no root.parent` を不要にするにはどうすれば良い？

A. `parent: (live - root) -> one (Dir & live)` とする事で root はそもそも parent 関係を持たなくさせる。そうすると `lone Dir` はそもそも root から parent に進む場合を表現していたので、その 0 の方が不要になるのでここは `one` で良くなる。また `->` の左右どちらも live を中心として記述する事で、File System が live な集合を表すことがわかりやすくなる。

ちなみにこうすると `contents` の多重度も消せてこう書ける。
```alloy
contents: Dir -> FSObject
```

ちなみに、`root: Dir` より `root: Dir & live` と書くほうが良いように書かれてたけどその説明が理解できなかった。
まぁ情報が増えて、これ見ただけで「root は必ず live だろうな」というのは分かるようにはなる。
ただ、 そもそも `live = root.*contents` という制約が付いているので、root は必ず live になるという意味では、`root: Dir & live` とする必要はなさそう。
情報が増えてより自明になるからという理由で安易に集合を限定的にしていって良いのかどうかは不明。

ただまぁ、集合が限定されていた方が理解しやすいモデルだとは思うので、その意味で当面は集合を限定していって良さそう。

### まとめ

- fact は減らせた方がスマート。その方が、モデルを豊かに表現できている可能性が高い
- 多重度も減らす or よりシンプルなもの(oneとか)に出来た方が、理解しやすくなりそう