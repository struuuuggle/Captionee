# [Swift]if-letにて変数の命名に悩んだ時の対処法





## そもそも"if let"とは

Optional型の変数はnilが入ることが許されている。
変数にnilが入っていないかチェックした上で次の処理に進みたいときには

```
let numA: Int? = 20

// do something

if let numB = numA {
	print(numA)		// Optional
	print(numB)		// 非 optional
}
```

こうすると、変数の型は次のようになる。

| 変数名    | 型        |
|:---------|----------:|
| numA     |      Int? |
| numB     |       Int |

- `numB`はアンラップされるため非オプショナル型となる。
- `numA`はオプショナル型のまま。







## 対処

### パターン1

if-let文中で新たに変数を宣言したが(上記コードでは`numB`)、その変数は使わないってとき。
そんなときは、下記の`_ = numA`のように新しい変数を宣言しないという手もある。

```
let numA: Int? = 20

// do something

if let _ = numA {
	// do something
}
```


### パターン2

安全性を優先すれば、Optional型の変数と同じ名前で宣言するのが良い。
どのような面で安全かというと、Optionalな変数にアクセスすることを避けられるってこと。
\"**unexpectedly found nil while unwrapping an Optional value**"のエラーを出してしまうとデバッグに時間がかかることが多いので、変数名は同じものを使うのが良い。将来の自分のためにも。

```
let numA: Int?

// do something

if let numA = numA {
	print(numA)	// numAは非optional
	// Optional型のnumAにはアクセスできなくなる
}
```






## 参考URL

[if let の変数名](http://www.toyship.org/archives/2229)
[SwiftのOptional(オプショナル)が少しややこしいのでまとめてみた - Qiita](https://qiita.com/ToraDady/items/6079b9f07bebece672eb#if-let文は何が便利なの)

[Optional - Swift Standard Library | Apple Developer Documentation](https://developer.apple.com/documentation/swift/optional)
