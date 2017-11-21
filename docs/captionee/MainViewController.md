# MainViewController

**MainViewController.swift**はアプリのメイン画面を構成するクラスである。  

## Property

- `videoMovUrl: URL?`  
アップロードされた動画(.mov)のURL。
- `videoMp4Url: URL?`  
アップロードされた動画(.mp4)のURL。
- `audioM4aUrl: URL?`  
アップロードされた動画から抽出された音声(.m4a)のURL。
- `audioWavUrl: URL?`  
アップロードされた動画から抽出された音声(.wav)のURL。
- `videos: [VideoInfo]`  
[VideoInfo]()を管理する配列。
- `speechToText: SpeechToText`  
SpeechToText のインスタンス。
- `selectedVideoInfo: VideoInfo?`  
Table View で選択された動画の情報。
- `caption: String`  
音声認識の結果の文字列。
- `tableView: UITableView!`  
[VideoInfo]()を管理する Table View。

## Method
- `selectImage(_ sender: Any) -> Void`  
uploadButton を押した時に呼ばれる。
- `requestAuth() -> Void`  
ユーザに Photo Library の利用許可をとる。
- `imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) -> Void`  
Photo Library で動画を選択した時に呼ばれる。[VideoInfo]()の設定、MOV から WAV への変換、音声認識を行う。
- `previewImageFromVideo(_ url: URL) -> UIImage?`  
アップロードされた動画のサムネイル画像を生成する。
- `generateCaption() -> Void`  
Watson に音声ファイルを投げ、音声認識を行う。
- `success() -> Void`  
[KRProgressHUD]() の Success View を表示する。
- `failure() -> Void`  
[KRProgressHUD]() の Failure View を表示する。
- `tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int`  
Table View の Cell の個数を返す。
- `tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`  
Table View のそれぞれの Cell に値を設定する。
- `tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat`  
Table View の Cell の高さを返す。
- `tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void`  
Table View の Cell がタップされた時に呼ばれる。
- `prepare(for segue: UIStoryboardSegue, sender: Any!) -> Void`  
画面遷移の際に、遷移先の View Controller に値を渡す。
- `title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!`  
Table View が空の時に表示する Empty State のタイトルを設定する。
- `description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!`  
Table View が空の時に表示する Empty State の詳細を設定する。
- `getCurrentTime() -> String`  
現在の時刻を文字列として返す。
