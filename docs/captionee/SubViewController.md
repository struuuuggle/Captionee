# SubViewController

SubViewController.swift は、[MainViewController](https://github.com/enpit2su-ics/team-E/blob/dev/docs/captionee/MainViewController.md) で選択された動画を再生し、字幕を表示するクラスである。

- `receivedVideoInfo: VideoInfo!`  
[MainViewController](https://github.com/enpit2su-ics/team-E/blob/dev/docs/captionee/MainViewController.md) から渡された動画の情報。
- `receivedCaption: String!`  
[MainViewController](https://github.com/enpit2su-ics/team-E/blob/dev/docs/captionee/MainViewController.md) から渡された字幕の文字列。
- `imageView: UIImageView!`  
receivedVideoInfo のサムネイル画像を表示する。
- `caption: UILabel!`  
動画の下に表示する字幕。

## Method

- `playVideo(_ name: String) -> Void`  
receivedVideoInfo の動画を再生する。
- `imageTapped(_ sender: AnyObject) -> Void`  
imageView がタップされた時に呼ばれる。
