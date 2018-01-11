//
//  TrashViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2018/01/12.
//  Copyright © 2018年 enPiT2SU. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MaterialComponents

class TrashViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var tableView = UITableView()
    
    var selectedVideoInfo: VideoInfo?
    
    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    /*
    /* 編集モードの変更 */
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
    */
    
    /*
    /* 編集可能なCellを設定 */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    
    /*
    /* SnackBarが表示・非表示するときに呼ばれる */
    @objc func handleOverlayTransition(transition: MDCOverlayTransitioning) {
        if fabOffset == 0 {
            print("SnackBarを表示")
        } else {
            print("SnackBarを非表示")
        }
        
        let bounds = view.bounds
        let coveredRect = transition.compositeFrame(in: view)
        
        let boundedRect = bounds.intersection(coveredRect)
        
        var fabVerticalShift: CGFloat = 0
        var distanceFromBottom: CGFloat = 0
        
        if !boundedRect.isEmpty {
            distanceFromBottom = bounds.maxY - boundedRect.minY
        }
        
        fabVerticalShift = fabOffset - distanceFromBottom
        fabOffset = distanceFromBottom
        
        transition.animate(alongsideTransition: {
            self.selectImageButton.center = CGPoint(x: self.selectImageButton.center.x, y: self.selectImageButton.center.y+fabVerticalShift)
        })
    }
    */
    
    /* 移動可能なCellを設定 */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* Cellの個数を指定 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.trashVideos.count
    }
    
    /* Cellに値を設定 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellの指定
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        // Cellのサムネイル画像を設定
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = appDelegate.trashVideos[indexPath.row].image
        imageView.contentMode = .scaleAspectFit
        
        // Cellの説明を設定
        let label = cell.viewWithTag(2) as! UILabel
        label.text = appDelegate.trashVideos[indexPath.row].label
        label.font = MDCTypography.captionFont()
        label.alpha = MDCTypography.captionFontOpacity()
        
        return cell
    }
    
    /* Cellの高さを設定 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 画面の縦サイズ
        let screenHeight = UIScreen.main.bounds.size.height
        
        // StatusBarの縦サイズ
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        // NavigationBarの縦サイズ
        let navBarHeight = navigationController!.navigationBar.frame.size.height
        
        // 表示するCellの個数
        let cellNumber: CGFloat = 5
        
        // Cellの高さ
        let cellHeight = (screenHeight - statusBarHeight - navBarHeight) / cellNumber
        
        return cellHeight
    }
    
    /* Cellが選択されたとき */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("---> VideoName")
        print(appDelegate.trashVideos[indexPath.row].name)
        print("<--- VideoName")
        
        // 選択されたセルの動画情報をprepareメソッドに渡すためにselectedVideoInfoに一時保管
        selectedVideoInfo = appDelegate.trashVideos[indexPath.row]
        
        // SubViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "toSubViewController", sender: nil)
        
        // Cellの選択状態を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* Segueの準備 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            // 遷移先のViewControllerを設定
            let subVC = segue.destination as! SubViewController
            
            // 値の受け渡し
            subVC.receivedVideoInfo = selectedVideoInfo
        }
    }
    
    /* TableViewが空のときに表示する内容のタイトルを設定 */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        // TableViewの背景色を設定
        scrollView.backgroundColor = MDCPalette.grey.tint100
        
        // テキストを設定
        let text = "No movie uploaded."
        
        // フォントを設定
        let font = MDCTypography.titleFont()
        
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: font])
    }
    
    /* TableViewが空のときに表示する内容の詳細を設定 */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        // テキストを設定
        let text = "Let's upload your movies and\n watch them with caption!"
        
        // フォントを設定
        let font = MDCTypography.body1Font()
        
        // パラグラフを設定
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.center
        paragraph.lineSpacing = 6.0
        
        return NSAttributedString(
            string: text,
            attributes:  [
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("MainViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MainViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("MainViewController/viewWillDisappear/別の画面に遷移する直前")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("MainViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MainViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
