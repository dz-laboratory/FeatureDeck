//
//  ViewController.swift
//  HeathKit
//
//  Created by anz-ryu on 2023/11/21.
//

import UIKit
import HealthKit
import UserNotifications

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction
    func requsetPermission(_ sender: UIButton) {
        let allTypes: Set<HKSampleType> = Set([
                            HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
                            HKObjectType.quantityType(forIdentifier: .walkingStepLength)!,
                            HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
                            HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                            HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
                           ])
        // 許可要求を発行
        self.healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
            if success {
                print("health permission accepted.")
            } else {
                print("health permission denied.")
            }
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Allowed")
            } else {
                print("Didn't allowed")
            }
        }
    }
    
    @IBAction
    func listenChangeNotification(_ sender: UIButton) {
        // データの変更を監視する
        let objType = HKObjectType.quantityType(forIdentifier: .walkingSpeed)!
        // ヘルスケアデータの更新を検知するクエリ
        let query = HKObserverQuery(sampleType: objType, predicate: nil, updateHandler: {
            query, completionHandler, error in
            print("health data updated.")
            if error != nil {
                print("error: \(error.debugDescription)")
                return
            }
            // ヘルスケアデータの更新を検知したらローカル通知を送る
            let content = UNMutableNotificationContent()
            
            content.title = "ABC"
            content.body = "歩行速度が更新されました"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            completionHandler()
        })
        self.healthStore.execute(query)
        self.healthStore.enableBackgroundDelivery(for: objType, frequency: .immediate) { (success, error) in
            if success {
                print("health background delivery accepted.")
            } else {
                print("health background delivery denied.")
            }
        }
        print("button tapped.")
    }

}

