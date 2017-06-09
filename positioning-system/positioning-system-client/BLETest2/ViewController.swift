// created by Kartik Singh on 15/06/2016

import UIKit
import CoreBluetooth

let defaults = UserDefaults.standard
var readerId = defaults.integer(forKey: "readerId") ?? 0
var ipAddr = defaults.string(forKey: "serverIpAddrField") ?? "192.168.43.71"
let port = 10000
let threshold = -60
let timeThreshold = 2.0

class ViewController: UIViewController, CBCentralManagerDelegate, UIApplicationDelegate, CBPeripheralDelegate {
    @IBOutlet weak var deviceIdField: UITextField!
    @IBOutlet weak var serverIpAddrField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    var timeStamp = [String:Double]()
    var centralM:CBCentralManager?
    var peripherals = Array<CBPeripheral>();
//    let services = [CBUUID(string: "81E7")]
    let services = [NSUUID(uuidString: "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6")]
    @IBAction func configSetButtonPressed(_ sender: AnyObject) {
        guard let readerIdText = deviceIdField.text, let readerIdRaw = Int(readerIdText), let ipAddrRaw = serverIpAddrField.text else {
            return
        }
        readerId = readerIdRaw
        ipAddr = ipAddrRaw
        deviceIdField.resignFirstResponder()
        serverIpAddrField.resignFirstResponder()
        defaults.set(readerId, forKey: "readerId")
        defaults.set(ipAddr, forKey: "serverIpAddrField")
        print("readerId: \(readerId), ipAddr:\(ipAddr)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeStamp["NONE"] = 0
        let queue = DispatchQueue(label: "com.uievolution.BLETest2", attributes: [])
        centralM = CBCentralManager(delegate:self,queue:queue)
        deviceIdField.text = "\(readerId)"
        serverIpAddrField.text = "\(ipAddr)"
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == CBCentralManagerState.poweredOn {
            print("Bluetooth is on!");
//            self.centralM?.scanForPeripherals(withServices: services , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
//        }
//        else {
//            print("Bluetooth is off!");
//        }
 
    }
    
    func uniqueIDFromAdvertisementDictionary(_ dictionary: NSDictionary) -> String {
        var ret = "unknown"
        if let serviceDict = dictionary["kCBAdvDataServiceData"] {
            let sDict = serviceDict as! NSDictionary
            let firstVal = sDict.allValues.first as! Data
//            let uniqueIdData = firstVal.subdata(in: Range)
//            ret = uniqueIdData.hexadecimalString as String
        }
//        return ret
        return "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6"
  
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let time = Date().timeIntervalSince1970
        print (time)
        let url = URL(string: "http://\(ipAddr):\(port)/rec/\(readerId)/\(uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary))/\(RSSI)")!
        print(url)
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        if Int(RSSI) < 0 {
            print(RSSI)
            print(uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary))
            if Int(RSSI) > threshold {
                timeStamp["NONE"] = 0;
                let value = timeStamp[uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary)]
                if value != nil {
                    if (time >= (value!+timeThreshold)) {
                        let oldVal = timeStamp.updateValue(time, forKey: uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary))
                        print("Old val : \(oldVal)");
                        let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
                            print("done, \((Int(RSSI))) error: \(error) ")
                        } as! (Data?, URLResponse?, Error?) -> Void) 
                        dataTask.resume()
                    }
                }
                else {
                    timeStamp[uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary)] = time;
                    print(timeStamp[uniqueIDFromAdvertisementDictionary(advertisementData as NSDictionary)])
                    let dataTask = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
                        print("done, \((Int(RSSI))) error: \(error) ")
                    } as! (Data?, URLResponse?, Error?) -> Void) 
                    dataTask.resume()
                }
            }
        }
    }
}

extension Data {
//    (kdj_hexadecimalString)
    public var hexadecimalString: NSString {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        return NSString(string: hexString)
    }
}


