//
//  ViewController.swift
//  enPiT2SUProduct
//
//  Created by Jun Ohkubo on 2017/09/15.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var myXLabel: UILabel!
    @IBOutlet weak var myYLabel: UILabel!
    @IBOutlet weak var myZLabel: UILabel!
    
    var myMotionManager: CMMotionManager!
    let motionManager = CMMotionManager()
    
    var gyroX: Double = 0
    var gyroY: Double = 0
    var gyroZ: Double = 0
    
    var gyroCumX: Double = 0
    var gyroCumY: Double = 0
    var gyroCumZ: Double = 0
    
    var accelerationX: Double = 0
    var accelerationY: Double = 0
    var accelerationZ: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 加速度センサかジャイロセンサか，どちらかだけを利用して，
        // 利用しない方はコメントアウトすること！
        
        // 加速度センサの場合
        // ・単に積分して「加速度 -> 速度 -> 位置」にするのは難しい？
        // ・ローパスフィルタなどを使って，値を滑らかにする必要がある？
        // ・重力も検知するので傾きを検出できる？
        startAccelerometer()
        
        // ジャイロセンサの場合
        // 端末の回転速度に関する情報を検出．
        // ここではその時間積分にして，アプリ起動時からの端末の回転についての位置を検出する
        //startGyroscope()
        
        
        
    }
    
    // 加速度センサ取得を開始
    func startAccelerometer(){
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
            motionManager.accelerometerUpdateInterval = 0.1
            
            // センサ値の取得開始
            motionManager.startAccelerometerUpdates(
                to: OperationQueue.current!,
                withHandler: {(accelData: CMAccelerometerData?, errorOC: Error?) in
                    self.outputData(acceleration: accelData!.acceleration)
            })
            
        }
        
    }
    
    // 加速度センサの場合の出力
    func outputData(acceleration: CMAcceleration){
        myXLabel.text = String(format: "%+06f", acceleration.x)
        myYLabel.text = String(format: "%+06f", acceleration.y)
        myZLabel.text = String(format: "%+06f", acceleration.z)
        
    }
    
    // ジャイロセンサ取得を開始
    func startGyroscope(){
        if motionManager.isAccelerometerAvailable {
            // intervalの設定 [sec]
            motionManager.gyroUpdateInterval = 0.1
            
            // センサ値の取得開始
            motionManager.startGyroUpdates(
                to: OperationQueue.current!,
                withHandler: {(gyroData: CMGyroData?, errorOC: Error?) in
                    self.outputData(gyroData: gyroData!)
            })
            
        }
        
    }
    
    // ジャイロセンサの場合の出力
    func outputData(gyroData: CMGyroData){
        // 時間変化の累積を表示する
        gyroCumX = gyroCumX + gyroData.rotationRate.x
        gyroCumY = gyroCumY + gyroData.rotationRate.y
        gyroCumZ = gyroCumZ + gyroData.rotationRate.z
        
        myXLabel.text = String(format: "%+06f", gyroCumX)
        myYLabel.text = String(format: "%+06f", gyroCumY)
        myZLabel.text = String(format: "%+06f", gyroCumZ)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

