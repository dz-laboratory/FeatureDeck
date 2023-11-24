// copy from https://nonateck.com/?p=37

import AVFoundation
import Cocoa
import CoreBluetooth
import AppKit

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var pp: CBPeripheral? = nil
    //セントラルの振る舞いは全てcentralManagerで操作します
    private var centralManager:CBCentralManager!
    //接続したペリフェラルを保持するために使います
    private var cbPeripheral:CBPeripheral? = nil
    //以下は今回のサンプルで便宜上使うものです。信号の送信・読み出しに使います。
    //必要に応じて追加・変更が必要です。
    private var writeCharacteristic: CBCharacteristic? = nil
    private var readCharacteristic: CBCharacteristic? = nil
    
    private var keepCharacteristic: CBCharacteristic?
    
    private var deviceDictionary: Dictionary<String, CBUUID> = Dictionary<String, CBUUID>()
    
    @IBOutlet weak var table: NSTableView!
    
    @IBAction
    func getData(sender: AnyObject) {
        print("to get data")
        if let pp = pp, let keepCharacteristic = keepCharacteristic {
            print("get Data!")
            pp.readValue(for: keepCharacteristic)
        }
    }
    
    
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
    
//    var
}

extension ViewController {
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return deviceDictionary.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor
        tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        print(#function + " column:" +
            tableColumn!.identifier.rawValue + " row:" + String(row))
        var result: NSTextField? =
            tableView.makeView(withIdentifier:NSUserInterfaceItemIdentifier(rawValue:
                "MyView"), owner: self) as? NSTextField
        if result == nil {
            result = NSTextField(frame: NSZeroRect)
            result?.identifier =
                NSUserInterfaceItemIdentifier(rawValue: "MyView")
        }
        if let view = result {
            print("view:" + view.identifier!.rawValue + " row:" + String(row))
            let key = deviceDictionary.keys.sorted()[row]
            if let column = tableColumn {
                if column.title == "C1" {
                    view.stringValue = key
                } else if column.title == "C2" {
                    view.stringValue = deviceDictionary[key]?.className ?? "nil"
                } else if column.title == "C3" {
                    let data = deviceDictionary[key]!.data
                    view.stringValue = String(decoding: data, as: UTF8.self)
                } else if column.title == "C4" {
                    view.stringValue = deviceDictionary[key].debugDescription
                }
            }
        }
        return result
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
        print("liu: data: " + advertisementData.debugDescription)
        peripheral.discoverServices([CBUUID(data: Data([0x18,0x0A]))])
        let services = peripheral.services
        for s in services ?? [] {
            print("liu: uuid: " + s.uuid.uuidString )
        }
        
        central.connect(peripheral, options: nil)
        print("liu: name: " + (peripheral.name ?? "nil"))
        print("liu: services: " + peripheral.services.debugDescription)
        peripheral.delegate = self
        
        if let uuid = advertisementData["kCBAdvDataServiceUUIDs"] {
            let id = (uuid as! NSArray)[0] as! CBUUID
            let idStr = id.uuidString
            print("liu: real-name: " + (peripheral.name ?? "nil"))
            print("liu: real-class: " + (peripheral.className))
            print("liu: real-uuid:" + peripheral.identifier.uuidString)
//            if idStr == "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE" {
//                print("find!!")
//                central.connect(peripheral, options: nil)
//                pp = peripheral
//                centralManager.stopScan()
//            } else {
//                print(idStr)
//            }
            deviceDictionary[idStr] = id
            table.reloadData()
            print("liu:reload")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("A")
        print("liu: A")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
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
    
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        NSLog("E")
//    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //全てのサービスのキャラクタリスティックの検索
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("AAA")
        print("送信元のCharacteristic:",characteristic.uuid.uuidString)
        if let error = error {
            print("情報受信失敗...error:",error.localizedDescription)
        } else {
            print("受信成功")
            let receivedData = String(bytes: characteristic.value!, encoding: String.Encoding.ascii)
            print("受信データ",receivedData)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("BBB")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("liu: uuid: " + service.uuid.uuidString)
        for s in service.includedServices ?? [] {
            print("liu: uuid: include: " + s.uuid.uuidString )
        }
        for characteristic in service.characteristics!{
            print("発見したキャラクタリスティック",characteristic.uuid.uuidString)
            
            if characteristic.uuid.uuidString == "AAAAAAAA-DDDD-BBBB-BBBB-BBBBBBBBBBBB" {
                print("keep!")
                keepCharacteristic = characteristic
                pp?.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
