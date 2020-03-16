```alloy
// A file system object in the file system
sig FSObject { parent: lone Dir }

// A directory in the file system
sig Dir extends FSObject { contents: set FSObject }

// A file in the file system
sig File extends FSObject { }
```

次の4つの fact はどの書き方をしても同じ。`all` のあと `,` で区切る限りは `all` の作用が引き継がれる？
```alloy
fact { all d: Dir, o: d.contents | o.parent = d }

fact { all d: Dir | all o: d.contents | o.parent = d }

fact { all d: Dir, o: FSObject | o in d.contents => o.parent = d }

fact { all d: Dir | all o: FSObject | o in d.contents => o.parent = d }
```

`.` operator は
1. signature の直後の `.` はフィールドへのアクセス
2. それ以外は "[relation composition](https://alloytools.org/tutorials/online/sidenote-relational-join.html0" (relational join). つまり、関数合成の合成のようなものと見なして良さそう
3. 本質的には1も2も同じなのかも知れないがよくわからん

「すべての FSObject は File または Dir である」を表現方法は、次のどちらでも良い.
```alloy
// pattern 1
fact {
  File + Dir = FSObject
}
```
```alloy
// pattern 2
abstract sig FSObject {}
sig Dir extends FSObject { contents: set FSObject }
sig File extends FSObject { }
```
`+` は和集合を示すので、pattern 1 の fact は「すべてのFileとすべてのDirの結合は、すべてのFSObjectの集合と同じ」という事を示す.
`abstract` については下記の補遺を参照のこと。

 --

いわゆるディレクトリのルートは次のように表せる。2つ目の`{ }`は appended facts(後述.ただ呼び名の通り fact の追加)
```alloy
  // There exists a root
  one sig Root extends Dir { } { no parent }
```
ちなみに、↑と次の3つは同じ.

```alloy
  sig Root extends Dir { }
  fact { one Root }
  fact { no Root.parent }
```
```alloy
  sig Root extends Dir { }
  fact {
    one Root
    no Root.parent
  }
```
```alloy
  sig Root extends Dir { }
  fact {
    one Root
    all r:Root | no r.parent
  }
```

最後に、すべての FSObject が Root に接続されている事を確認する fact を足す。

```alloy
fact {
  FSObject in Root.*contents
}
```
`A in B` は A は B の部分集合(subset)と読み下す。

`*` は「再帰的推移的閉包([Reflexive Transitive Closure](https://alloytools.org/tutorials/online/sidenote-rtc.html))の演算子。
`^` は[非再帰的な推移閉包](https://alloytools.org/tutorials/online/sidenote-nrtc.html)の演算子。
`*bar` は `iden + ^bar` と等価。つまり、`*`の方は自分自身を含み、`^`の方は自分自身を含まない(※ あとで `^`使う例が出てくる)

なので、上記 fact は次のことを言っている

1. 「すべての FSObject の集合は」
2. 「Root から `contents` relation を 0 or 1 回以上辿ることで到達可能な集合の」
3. 「部分集合である」

fact と assert の使い分けは
- fact: そのモデルを成立させるために必須なもの
- assert: そのモデルが成立しているならば成り立つようなこと

つまり
- fact は1つでも消してしまうと、そもそもそのモデルが成立しなくなる
- assert は消してもそのモデルの成立には問題がない

ということ。そのため、fact は必要最低限の記述で抑えて、冗長な事実は assert に書くと良い。
(assert をあえて fact にしてしまうと、重要な反例を見逃してしまう事に繋がるので注意)


ここまで触れてきた File System のモデルが期待通りに機能しているなら、次のようなことが言えるはず。
```alloy
  // The contents path is acyclic
  assert acyclic {
    no d: Dir | d in d.^contents
  }
```
ただしここで `d.*contents` とすると、contents を 0 回辿るケース(つまり contents を辿らない自分自身)を含んで assertion は false になるため注意。

assert は次のように　check する。ここでは FSObject を最大で5つ生成するパターンを網羅的に検査する。

```alloy
check acyclic for 5
```

check は反例がなければ `no solution found` と返し、反例があれば `solution found` を返す。
反例は最小のインスタンス数の例とは限らないので、より少ないインスタンス数でも反例を見つけさせると、視覚化した時わかりやすい。

Q. 「Root は1つだけである」という Assert はどう書く？

A. Root のみが持つ特徴を捉えて、それがただ1つ存在することを主張する
```alloy
 assert oneRoot {
    one d: Dir | no d.parent
 }
```

Q. 「すべての FSObject が 1つの Directory に含まれるケースがある」という Assert はどう書く？

A. `lone` を使うのがポイント
`lone`でなく`one`にしてしまうと、(WIP. 実行結果から解釈してここに書く)
```alloy
  assert oneLocation {
    all o: FSObject | lone d: Dir | o in d.contents
  }
```

# 補遺

### [Set Operations](https://alloytools.org/tutorials/online/sidenote-set-ops.html)
- union(`+`): 和集合
- intersection(`&`): [共通部分](https://ja.wikipedia.org/wiki/%E5%85%B1%E9%80%9A%E9%83%A8%E5%88%86_(%E6%95%B0%E5%AD%A6))。交叉、交わり、などとも呼ばれる。積集合は基本的には直積集合のことを指すが、共通集合の意味で使われることもある
- subtraction(`-`): [差集合](https://ja.wikipedia.org/wiki/%E5%B7%AE%E9%9B%86%E5%90%88)
- membership/subset(`in`): `in` キーワードは membership と subset のどちらも示す。Alloy は atoms と singleton sets を区別しないため。

### [extends, in, abstract, one](https://alloytools.org/tutorials/online/sidenote-format-sig.html)

```alloy
sig A, B extends C {}
```
- A と B は C の部分集合(sub set)
- A と B は 互いに素(disjoint)
  - つまり、2つの集合が交わりを持たない

```alloy
sig A, B in C {}
```

- A と B は C の部分集合(sub set)
- A と B は 互いに素とは限らない

```alloy
abstract sig Foo {
//fields
}

sig Bar extends Foo {
//fields
}

sig Cuz extends Foo {
//fields
}
```

- `abstract` は Java のような OOP のそれと似ている
- `abstract` を使用する事で、Bar でも Cuz でもない Foo がない事が保証される
  - ただし、もし Foo を extends する部分集合が1つもなければ、この保証はされず、`abstract` の効果はなくなり `sig Foo` と同じ扱いになる

```alloy
one sig name {
// fields
}
```

- sig の前に `one` キーワードを使うと、その sig のインスタンスを常に1つにする事ができる
- これにより、この sig へのあらゆす参照は1つのアトム(≒ オブジェクト?)を参照することも保証される
  - 要するにシングルトンオブジェクト？


### [Quantifiers](https://alloytools.org/tutorials/online/sidenote-quantifiers.html)
- `all x:X | formula`: X 型のすべての x が fomula を満たす
- `some x:X | formula`: X 型の1つ以上の x が formula を満たす
- `no x:X | formula`: X型の x で formula を満たすものはゼロ
- `one x:X | formula`: X型の x で formula を満たすものはただ1つだけ
- `lone x:X | formula`: X型の x で formula を満たすものは、0 または 1 つだけ

formula(式)を評価するとBooleanになる事に注意すること。(formula は`関係`ではない)

set や relation(関係) に対して使うと次のような意味になる。
- some X - there is at least one X
- no X - there are no X's
- one X - there is exactly one X
- lone X - there are either zero or one X's

Quantifiers(数量詞)を使った基本的な書き方は次の2つ(`|` を使うパターンと`{}`を使うパターン)
```
quantifier variable:type | formula
quantifier variable:type { formula }
```

例
```alloy
  // Does any directory contain itself?
  some d: Dir | d.parent = d

  // every file is some directory
  all f:File | some d:Dir | f.parent = d

  // no two directories have exactly the same contents
  no dir1, dir2: Dir | dir1!=dir2 && dir1.contents=dir2.contents
```

### [Syntax for appended facts](https://alloytools.org/tutorials/online/sidenote-format-appended-fact.html)

次のように、2つ目の `{}` には、その sig に対する fact を書くことができる。
これを使うと、モデルに関する制約を1箇所に書けるため、モデルがより明確で見通しがよくなる。
```alloy
  sig name {
    // fields of the signature
  }{
    // appended fact constraints
  }
```

次の2つは同じ。
appended facts に書く場合は、暗黙的に次の2つが働いているので、そのように書くこと。
- `all this: SigName |`が先頭についた上で
- formula にも `this.` が常に付く

```alloy
  sig Person {
      closeFriends: set Person,
      friends: set Person
  } {
      closeFriends in friends
  }
```

```alloy
  sig Person {
      closeFriends: set Person,
      friends: set Person
  }

  fact {
      all x:Person | x.closeFriends in x.friends
  }
```