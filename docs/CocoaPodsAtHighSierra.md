# macOSをHigh Sierraにアップグレードした際にCocoaPodsが動かなくなることの原因と対処法

## 概要

macOSをHigh Sierraにアップグレードした後、CocoaPodsを動かそうとしたら、以下のようなエラーが出た。  
```
$ pod  
$ -bash: /usr/local/bin/pod: /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby: bad interpreter: No such file or directory
```  

## 原因

macOS High Sierra に同梱されている ruby のバージョンが上がったことが原因らしい。

## 対処法

ターミナルから以下のようにすることで解決できた。
```
$ sudo gem update --system
$ sudo gem install -n /usr/local/bin cocoapods
```

## 参考リンク
- [macOS High Sierra にアップグレードしたら、CocoaPods が動かなくなった](http://gootara.org/library/2017/10/macpods.html)
