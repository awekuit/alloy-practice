abstract sig Event {}
one sig 卒業式 extends Event {}
one sig 海外旅行 extends Event {}
one sig 入社式 extends Event {}
one sig 花見 extends Event {}
one sig ハイキング extends Event {}

abstract sig Item {}
one sig 靴 extends Item {}
one sig ハンカチ extends Item {}
one sig シャツ extends Item {}
one sig ズボン extends Item {}
one sig カメラ extends Item {}

abstract sig Person {
    event: one Event,
    item: one Item
}
one sig 田中 extends Person {}
one sig 竹内 extends Person {}
one sig 石田 extends Person {}
one sig 葛西 extends Person {}
one sig 青山 extends Person {}

fact {
  all p1, p2: Person | p1=p2 implies p1.event=p2.event else p1.event!=p2.event
  all p1, p2: Person | p1=p2 implies p1.item=p2.item else p1.item!=p2.item
}

fact {
    田中.item in シャツ
}
fact {
    竹内.event in 花見
    竹内.item in ズボン
}
fact {
    all p:Person | p.event in 入社式 implies p.item in 靴
    石田.event not in 入社式
    石田.item not in 靴 
}
fact {
    葛西.event not in 卒業式
    田中.event not in 卒業式
}
fact {
    青山.event not in 卒業式
    青山.event not in ハイキング
    青山.item not in 靴
    青山.item not in カメラ
}

pred show{}
run show