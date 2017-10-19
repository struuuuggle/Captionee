//
//  MainViewController.swift
//  
//
//  Created by 池崎雄介 on 2017/10/19.
//

import UIKit
import AVKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePickerController = UIImagePickerController()
    var videoURL: URL?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func selectImage(_ sender: Any) {
        print("UIBarButtonItem。カメラロールから動画を選択")
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        //imagePickerController.mediaTypes = ["public.image", "public.movie"]
        //動画だけ
        imagePickerController.mediaTypes = ["public.movie"]
        //画像だけ
        //imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        videoURL = info["UIImagePickerControllerReferenceURL"] as? URL
        print(videoURL!)
        imageView.image = previewImageFromVideo(videoURL!)!
        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
        
    }
    
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        
        print("動画からサムネイルを生成する")
        let asset = AVAsset(url:url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value,2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    
    @IBAction func playMovie(_ sender: Any) {
        
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }
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
