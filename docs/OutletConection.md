# "Could not insert new outlet connection"への対処法

## 状況
UIImageViewのIBOutletをSubViewCOntroller.swiftに追加しようと、controlキーを押しながらドラッグ&ドロップをしようとしたら、うまく接続できないという問題が生じた。


## エラー文

```
Could not insert new outlet connection: Could not find any information 
for the class named <class name>
```

- 要するに、classの情報が見つからないらしい。


## 原因
- 古いプロジェクトのデータが邪魔している様子。

## 対処法

- 以下のコマンドを叩いたら直った。

```
rm  -rf ~/Library/Developer/Xcode/DerivedData/<old project name>
```
- \<old project name>には、次のような条件を満たしたものを入れてやると良い。
  * 現在編集中のプロジェクトと同じような名前のプロジェクト
  * 現在編集中のプロジェクトよりも更新日時が古いプロジェクト

## 参考URL
[ エラー "Could not insert new outlet connection and deleting DerivedData doesnt work" への対処 - うちのいぬ Tech Blog](http://uchinoinu.hatenablog.jp/entry/2016/09/03/234351)
