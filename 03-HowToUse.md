# Captionee の使い方

## 導入方法

### プロジェクトの導入

ターミナルから以下のコマンドを実行し、プロジェクトを導入してください。

```
$ git clone https://github.com/enpit2su-ics/team-E.git
```  

### CocoaPods の設定

Captionee では CocoaPods を使ってフレームワークを導入しています。  
以下の手順に沿って導入してください。

#### Step.1 CocoaPods のインストール
詳しい手順は[こちら](https://qiita.com/ShinokiRyosei/items/3090290cb72434852460)の記事を参考にしてください。

#### Step.2 フレームワークの導入
ターミナルから以下のコマンドを実行し、フレームワークを導入してください。

```
$ cd team-E
$ pod install
```

CocoaPods の設定は以上です。

## 事前準備

### IBM Cloud の設定

Captionee を使用するには IBM Cloud の設定が必要になります。  
以下の手順に沿って設定を行ってください。

#### Step.1 IBM Cloud にログインする
詳しい手順は[こちら](http://ibm.biz/litecloud)の記事を参考にしてください。

#### Step.2 Speech To Text のインスタンスを作成する
ダッシュボードで「リソースの作成」を押します。  
左のカテゴリから「Watson」を選択し、「Speech To Text」を押します。  
適当な「サービス名」を入力し、「デプロイする地域/ロケーション」、「組織」、「スペース」を選択します。  
希望の「価格プラン」を選択し、「作成」を押します。

#### Step.3 Speech To Text の API キーを取得する
Step.2 で作成した Speech To Text のインスタンスを開き、「サービス資格情報」を選択します。  
その中の「新規資格情報」を押し、そのまま「追加」を押します。（名前の変更は任意です）  
追加した資格情報の「資格情報の表示」を開きます。  
表示された JSON スニペットから、 `"username"` の値と `"password"` の値をメモしておきます。

#### Step.4 Credential.swift を作成する
enPiTSUProduct 内に **Credential.swift** という名前のファイルを作成し、次の内容をコピーします。

```swift
struct Credentials {
    static let SpeechToTextUsername = "username"
    static let SpeechToTextPassword = "password"
}
```
`"username"` と `"password"` は、Step.3 でメモした値にそれぞれ置き換えてください。
  
IBM Cloud の設定は以上です。


### Google Cloud Platform の設定

Captioneeの字幕翻訳機能は、Cloud Translation APIを利用しています。
以下の手順に沿って設定を行ってください。

#### Step1. 新しいプロジェクトを作成し、Cloud Translation APIを有効化する

[こちら](https://cloud.google.com/translate/docs/getting-started?hl=ja#set_up_your_project)の記事を参考にして、「プロジェクトを設定する」の**手順1〜5**を行なってください。

#### Step2. Cloud Translation API のキーを発行する

[コンソール](https://console.cloud.google.com)をひらき、画面左上の「≡」ボタンを押して[「APIとサービス」>「認証情報」](https://console.cloud.google.com/apis/credentials)を押します。    
「作成(または認証情報を作成)」ボタンを押し、「APIキー」を選びます。    
「API キーを作成しました」というダイアログが出ます。作成したAPIキーをメモし、「キーを制限」ボタンを押します。    
APIキーの設定画面では、名前を適当に入力します。（"Key for Captionee""などが良いでしょう)    
「キーの制限」は「iOSアプリ」をチェックをし、APIキーを保存します。    
「リクエストを受け入れるiOSアプリのバンドルID」 の入力は任意です。

#### Step3. Credentials.swift にAPIキーを追記する

IBM Cloudの設定時に作成した**Credentials.swift**に`static let CloudTranslationApiKey = "API-KEY" `を追記します。
追記した結果、**Credentials.swift**の内容は次のようになります。

```swift
struct Credentials {
    static let SpeechToTextUsername = "username"  
    static let SpeechToTextPassword = "password"
    static let CloudTranslationApiKey = "API-KEY"  // 追記する行
}
```

`API-KEY`にはStep2でメモした値を入力してください。

Google Cloud Platform の設定は以上です。

## Captioneeの使用方法

### Chapter.1  アプリ起動〜動画のアップロード

- Captioneeへようこそ！
- 右下にあるボタンを押して字幕を表示したい動画を選択して、アプリ内にアップロードします。
- 初めにアクセス許可の表示が出るので、「許可する」を選択しましょう。
- アップロード時に、翻訳したい言語を設定しましょう。
- 左上のメニューバーを押すと、アプリの設定やチュートリアルの閲覧ができます。

### Chapter.2  動画リストの編集

- 動画をアップロード後、続けて別の動画をアップロードすることもできます。
- アップロードした動画の名前を変更したい場合は、動画の右方にある３つの点のボタンを押して編集します。
- アップロードした動画を削除したい場合は、削除したい動画を左にスワイプすることで削除ができます。
- 削除された動画は、ゴミ箱に移動されます。ゴミ箱は、メニューバーを押すと選択できます。
- 視聴したい動画を選択しましょう。

### Chapter.3  動画を視聴する

- 左下の三角マーク(以下、再生ボタンと呼ぶ)を押すことで動画の再生が始まります。
- 動画を一時停止したいときは、動画再生中に再生ボタンを押すことで一時停止します。
- 下方部のスライダーを操作することで、動画を途中から再生させることができます。
- -ボタン・+ボタンを押すことで、字幕のサイズが調整できます。
- 右上の３つの点のボタンを押すことで字幕の編集や、字幕の別な言語に翻訳することができます。
