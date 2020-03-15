open util/ordering[Day]

sig Day {
	メイン担当者: Person,
	サブ担当者: Person
}

abstract sig Person {
	メイン担当日: set Day,
	サブ担当日: set Day
}

one sig PersonS extends Person {}
one sig PersonO extends Person {}
one sig PersonW extends Person {}

fact {
	no d: Day | d.メイン担当者 = d.サブ担当者
	all d: Day, p: Person | d in p.メイン担当日 => d not in p.サブ担当日
	all d: Day, p: Person | p in d.メイン担当者 => d in p.メイン担当日 else d not in p.メイン担当日
	all d: Day, p: Person | p in d.サブ担当者 => d in p.サブ担当日 else d not in p.サブ担当日
	all d: Day, p: Person | p in d.メイン担当者 => p not in d.サブ担当者
}

fact {
	all p1, p2: Person | #p1.(メイン担当日 + サブ担当日) - #p2.(メイン担当日 + サブ担当日) =< 1
}

fact {
	-- util/ordering[Day] により first は最初の Day を表せる。また、翌日は next を組み合わせることで表せる
	first.メイン担当者 in PersonO
	first.next.メイン担当者 in PersonW
	first.next.next.メイン担当者 in PersonS
}

fact {
	-- last も util/ordering[Day] により使用可能に
	-- ここでの formula は「ある日メイン担当者となったら翌日は何も担当しないこと」なので、翌日の存在しない最終日を除外するため Day - last としている
	all d: Day - last | d.メイン担当者 not in (d.next.メイン担当者 + d.next.サブ担当者)
}

pred show{}
run {} for 3 but 6 Day