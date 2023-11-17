// copy from https://nonateck.com/?p=37

import Cocoa
import CoreBluetooth

class ViewController: NSViewController {
    var pp: CBPeripheral? = nil
    //セントラルの振る舞いは全てcentralManagerで操作します
    private var centralManager:CBCentralManager!
    //接続したペリフェラルを保持するために使います
    private var cbPeripheral:CBPeripheral? = nil
    //以下は今回のサンプルで便宜上使うものです。信号の送信・読み出しに使います。
    //必要に応じて追加・変更が必要です。
    private var writeCharacteristic: CBCharacteristic? = nil
    private var readCharacteristic: CBCharacteristic? = nil
    
    
    @IBAction
    func scan(sender: AnyObject){
        //Bluetoothの状態がONになっていることを確認
        if centralManager.state == .poweredOn{
            //Service指定せず周囲の全てのPeripheralをスキャンする
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
            //Serviceを指定してスキャンをする
            //デリゲートメソッドが指定のサービス以外で呼ばれなく、効率的であるため、こちらがベストプラクティス
            //let services: [CBUUID] = [CBUUID(string: "サービスのUUID")]
            //centralManager.scanForPeripherals(withServices: services, options: nil)
            
            //タイマーなど設けずスキャンをしているが、この場合は所望のペリフェラルが見つかるまでスキャンし続けてしまうので、
            //実際に使う場合はタイマーでスキャンを停止する、スキャン停止ボタンを設けるなどの配慮が必要
            //            scanTimer = Timer.scheduledTimer(timeInterval: TimeInterval(10),
            //                                                  target: self,
            //                                                  selector: #selector(self.timeOutScanning),
            //                                                  userInfo: nil,
            //                                                  repeats: false)
            //            ///スキャンタイムアウト
            //            @objc func timeOutScanning() {
            //                centralManager.stopScan()
            //            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //セントラルマネージャーを初期化：初期化した時点でPermissionの許諾のpopupが出て、Bluetoothの電源がONになる。
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


extension ViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            //②:セントラル側BLEの電源ONを待つ
            //BLEが使用可能な状態：電源がONになっている
        case CBManagerState.poweredOn:
            print("Bluetooth PowerON")
            break
            //BLEが使用出来ない状態：電源がONになっていない
        case CBManagerState.poweredOff:
            print("Bluetooth PoweredOff")
            break
            //BLEが使用出来ない状態：リセット中
        case CBManagerState.resetting:
            print("Bluetooth resetting")
            break
            //BLEが使用出来ない状態：Permissionの許諾が得られていない
        case CBManagerState.unauthorized:
            print("Bluetooth unauthorized")
            break
            //BLEが使用出来ない状態：不明な場外
        case CBManagerState.unknown:
            print("Bluetooth unknown")
            break
            //BLEが使用出来ない状態：BLEをサポートしていない
        case CBManagerState.unsupported:
            print("Bluetooth unsupported")
            break
        }
    }
    
    //④スキャンでPeripheralが見つかる毎に呼ばれるメソッド
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
  
        if let uuid = advertisementData["kCBAdvDataServiceUUIDs"] {
            let id = (uuid as! NSArray)[0] as! CBUUID
            let idStr = id.uuidString
            if idStr == "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE" {
                print("find!!")
                central.connect(peripheral, options: nil)
                pp = peripheral
                centralManager.stopScan()
            } else {
                print(idStr)
            }
        }
        
//        //peripheralのローカルネーム
//        print("name:\(peripheral.name)")
//        //advertiseの中身
//        print("advertisementData:\(advertisementData)")
//        //advertiseに入っているServiceUUID
//        print("advertisementServiceUUID:\(advertisementData["kCBAdvDataServiceUUIDs"])")
//        //advertiseの電波強度（RSSI）
//        print("rssi:\(RSSI.stringValue)")
//
//        //名称フィルターして接続する場合
//        if peripheral.name == "接続したいperipheralの名称"{
//            //見つけたペリフェラルを保持
//            self.cbPeripheral = peripheral
//            central.connect(peripheral, options: nil)
//            //スキャン停止
//            centralManager.stopScan()
//        }
            
            //アドバタイズに入っているService UUIDでフィルターして接続する場合
            //※実シーンではscanの時点でadvertisementDataを指定することでフィルターをかけるので使用シーンはほとんど無いと思われる
    //        let SERVICE_UUID:CBUUID = CBUUID(string: "接続したい機器がアドバタイズに乗っけているServiceUUID")
    //        if advertisementData["kCBAdvDataServiceUUIDs"] != nil {
    //            let UUID:[CBUUID] = advertisementData["kCBAdvDataServiceUUIDs"] as! [CBUUID]
    //            //アドバタイズに入っているUUIDは一つだけのため
    //            if UUID.first == SERVICE_UUID{
    //                central.connect(peripheral, options: nil)
    //            }
    //            //スキャン停止
    //            centralManager.stopScan()
    //        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("A")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("B")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("C")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: Error?) {
        NSLog("D")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        NSLog("E")
    }
    
}

