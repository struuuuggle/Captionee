//
//  TrashViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2018/01/12.
//  Copyright © 2018年 enPiT2SU. All rights reserved.
//

import UIKit
import SafariServices
import DZNEmptyDataSet
import MaterialComponents

class TrashViewController: UIViewController, SideMenuDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var tableView = UITableView()
    var selectImageButton = MDCFloatingButton()
    let sideMenuController = SideMenuController()
    
    var fabOffset: CGFloat = 0
    
    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TrashViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        sideMenuController.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        // NavigationBarの左側にMenuButtonを設置
        let menuButton = UIBarButtonItem(image: UIImage(named: "Menu"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuButtonTapped))
        navigationItem.leftBarButtonItem = menuButton
        
        navigationItem.title = "ゴミ箱"
        
        navigationController?.view.addSubview(sideMenuController.view)
        
        // Viewの背景色を設定
        view.backgroundColor = MDCPalette.grey.tint100
        
        // CustomCellをTableViewに登録
        tableView.register(CustomCell.self, forCellReuseIdentifier: "CustomCell")
        // TableViewのSeparatorを消す
        tableView.tableFooterView = UIView(frame: .zero);
        // TableViewの背景色を設定
        tableView.backgroundColor = MDCPalette.grey.tint100
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // エッジのドラッグ認識
        let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture))
        edgePanGestureRecognizer.edges = .left
        view.addGestureRecognizer(edgePanGestureRecognizer)
        
        // StatusBarの高さ
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        // NavigationBarの高さ
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        
        // アップロードボタンのサイズ
        let fabSize: CGFloat = 56
        
        // アップロードボタンの設定
        selectImageButton = MDCFloatingButton(type: .roundedRect)
        selectImageButton.frame = CGRect(x: UIScreen.main.bounds.width-fabSize-16,
                                         y: UIScreen.main.bounds.height-statusBarHeight-navigationBarHeight!-fabSize-16,
                                         width: fabSize,
                                         height: fabSize)
        selectImageButton.setImage(UIImage(named: "Add"), for: .normal)
        selectImageButton.tintColor = UIColor.white
        selectImageButton.backgroundColor = MDCPalette.yellow.tint600
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        view.addSubview(selectImageButton)
        
        let manager = MDCOverlayObserver(for: nil)
        manager?.addTarget(self, action: #selector(handleOverlayTransition))
        
        //tableViewの更新
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.blue
        let attstr: NSAttributedString? = NSMutableAttributedString(string: NSLocalizedString("Loading", comment: ""), attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)])
        refreshControl.attributedTitle = attstr
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    /* MenuButtonが押されたとき */
    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
        print("Menu button tapped.")
        
        sideMenuController.open()
    }
    
    /* FABが押されたとき */
    @objc func selectImage() {
        print("FAB tapped.")
    }
    
    /* 画面の左端がドラッグされたとき */
    @objc func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer){
        sideMenuController.dragging(sender.state, sender.translation(in: view))
        
        //移動量をリセットする。
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    /* メインボタンが押されたとき */
    func mainButtonTapped() {
        print("メイン")
        
        let mainViewController = MainViewController()
        modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    /* ゴミ箱が押されたとき */
    func trashButtonTapped() {
        print("ゴミ箱")
    }
    
    /* 設定ボタンが押されたとき */
    func settingsButtonTapped() {
        print("設定")
        
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    /* チュートリアルボタンが押されたとき */
    func tutorialButtonTapped() {
        print("チュートリアル")
    }
    
    /* フィードバックボタンが押されたとき */
    func feedbackButtonTapped() {
        print("フィードバック")
        
        // AlertControllerを作成
        let alert = MDCAlertController(title: "どんなエラーが起きましたか？",
                                       message: "今起きた問題について簡単に説明してください。後ほど詳しいことをお聞きします。")
        
        // AlertActionを作成
        let send = MDCAlertAction(title: "SEND", handler: { (action) -> Void in
            print("フィードバックを送信")
        })
        let cancel = MDCAlertAction(title: "CANCEL", handler: nil)
        
        // 選択肢をAlertに追加
        alert.addAction(send)
        alert.addAction(cancel)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    /* ヘルプボタンが押されたとき */
    func helpButtonTapped() {
        print("ヘルプ")
        
        let url = URL(string: "https://struuuuggle.github.io/Captionee/")
        if let url = url {
            print("Open safari success!")
            
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
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
    
    /* TableViewを引っ張ったとき */
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        print("Refresh")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            sender.endRefreshing()
        })
        tableView.reloadData()
    }
    
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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        
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
        
        // SubViewに遷移
        let subViewController = SubViewController()
        subViewController.receivedVideoInfo = appDelegate.trashVideos[indexPath.row]
        navigationController?.pushViewController(subViewController, animated: true)
        
        // Cellの選択状態を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* TableViewが空のときに表示する画像を設定 */
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "")
    }
    
    /* TableViewが空のときに表示する内容のタイトルを設定 */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        // TableViewの背景色を設定
        scrollView.backgroundColor = MDCPalette.grey.tint100
        
        // テキストを設定
        let text = "ゴミ箱にはアイテムがありません"
        
        // フォントを設定
        let font = MDCTypography.titleFont()
        
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: font])
    }
    
    /* TableViewが空のときに表示する内容の詳細を設定 */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        // テキストを設定
        let text = ""
        
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
        print("TrashViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("TrashViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("TrashViewController/viewWillDisappear/別の画面に遷移する直前")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("TrashViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("TrashViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
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
