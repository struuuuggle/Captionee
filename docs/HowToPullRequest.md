# リポジトリ共有式のPull Requestを使ってチーム開発してみる

## PullRequestとは

- 一般的には、「他のGitHubユーザーのリポジトリをfork(自分のGitHub上にクローン(コピー)して、作業し、変更を加え、元のリポジトリに変更内容を反映してもらう」という目的で使用されているみたい。
   
## リポジトリ共有式のPull Requestとは
>ところが、このブログ元でもあるqnyp社内において、複数人での開発を行うGitHub上のプロジェクト（リポジトリ）に参加するようになって、Forkしないタイプの「同じリポジトリを共有して、その中だけで行うPull Request」というものがあることを知りました。（以降、この方式を「リポジトリ共有式」と呼びます。これらの呼称は筆者が便宜上付けたものです）
※GitHubには、Fork & Pull Model / Shared Repository Model と書かれています。

※[GitHub初心者はForkしない方のPull Requestから入門しよう | qnyp blog](http://blog.qnyp.com/2013/05/28/pull-request-for-github-beginners/)より引用

## Pull Requestを使うメリット
複数人が同一ファイルに変更を加えてコミットしようとすると、競合してうまくコミットできないことがある。Pull Requestを使えるようになれば、それがなくなる。


## まあやってみよう

### 作業用のブランチ(ここでは"Update-ReleaseNote")を作成し、作成したブランチへ移動

[![https://gyazo.com/6e45001896814d21d79e3be318380fd5](https://i.gyazo.com/6e45001896814d21d79e3be318380fd5.gif)](https://gyazo.com/6e45001896814d21d79e3be318380fd5)


### 作業する
今回は01-ReleaseNote.mdを更新する。

[![https://gyazo.com/a8971c10f7f2eed43f62ef4653ec515d](https://i.gyazo.com/a8971c10f7f2eed43f62ef4653ec515d.png)](https://gyazo.com/a8971c10f7f2eed43f62ef4653ec515d)
適当に8行目を追加してみた。
作業が完了したらコミットをするのを忘れずに。


### いざ、Pull　Request
一通り作業を終えたら、PullRequestページへ移動。

[![https://gyazo.com/0aa4173bbf82b3133f0a705bebbe20a8](https://i.gyazo.com/0aa4173bbf82b3133f0a705bebbe20a8.gif)](https://gyazo.com/0aa4173bbf82b3133f0a705bebbe20a8)
右上の緑のNew pull requestボタンを押す。

masterと比較するブランチ(ここでは"Update-ReleaseNote")を選択し、緑のCreate pull requestボタンを押す。

[![https://gyazo.com/fa1b9fa8975092226ff1ff3194d16c2a](https://i.gyazo.com/fa1b9fa8975092226ff1ff3194d16c2a.gif)](https://gyazo.com/fa1b9fa8975092226ff1ff3194d16c2a)
コメントを適当に書き(ここでは"2017年10月16日分の作業記録を追記しました。")、"Able to merge"が表示されていることを確認し、緑のCreate pull requestボタンを押す。

[![https://gyazo.com/9179a6dcad10b60636a4483bd44f79f2](https://i.gyazo.com/9179a6dcad10b60636a4483bd44f79f2.png)](https://gyazo.com/9179a6dcad10b60636a4483bd44f79f2)

競合を引き起こさなければ、真ん中あたりに"This branch has no conflicts with the base branch"とメッセージが出るので、緑のMerge pull requestボタンを押して、メッセージを確認した上で、緑のConfirm Mergeボタンを押す。
もし、競合を起こしたら、ちょちょいと手を加える必要アリ。

紫のアイコンとともに、"Pull request successfully merged and closed"と表示されれば成功。

[![https://gyazo.com/044636ae0222f17014d2f0544130b78b](https://i.gyazo.com/044636ae0222f17014d2f0544130b78b.png)](https://gyazo.com/044636ae0222f17014d2f0544130b78b)


### うまくPull Requestできたか確認
自分が変更を加えたファイル等を開いてみる。masterブランチの状態で自分が加えた変更が反映されていることを確認する。

[![https://gyazo.com/8a0d48364b4175d152128676f6bf5ace](https://i.gyazo.com/8a0d48364b4175d152128676f6bf5ace.png)](https://gyazo.com/8a0d48364b4175d152128676f6bf5ace)


## ひとこと
- 「mergeし終わった後に作業用ブランチをdeleteする？どうする？」 -> チームで決めよう
- ~~今後も、同じような作業をする場合には、deleteせずにとっておけば再びbranchを切る手間が省ける。~~
- バグとりのような作業の場合はdeleteしてもよいかな？



## 参考URL

[About pull requests - User Documentation](https://help.github.com/articles/about-pull-requests/)

[GitHub初心者はForkしない方のPull Requestから入門しよう | qnyp blog](http://blog.qnyp.com/2013/05/28/pull-request-for-github-beginners/)

[Github上(のみ)で自分自身にpull requestを送る方法 | Web Scratch](http://efcl.info/2014/0305/res3702/)
