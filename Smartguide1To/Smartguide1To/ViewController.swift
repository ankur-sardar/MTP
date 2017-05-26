

import UIKit

class ViewController: UIViewController, ProximityContentManagerDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var proximityContentManager: ProximityContentManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.startAnimating()

        self.proximityContentManager = ProximityContentManager(
            beaconIDs: [
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 6918, minor: 13717),
                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 23851, minor: 30246),
//                BeaconID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", major: 63237, minor: 25166)
            ],
            beaconContentFactory: CachingContentFactory(beaconContentFactory: BeaconDetailsCloudFactory()))
        self.proximityContentManager.delegate = self
        self.proximityContentManager.startContentUpdates()
    }

    func proximityContentManager(_ proximityContentManager: ProximityContentManager, didUpdateContent content: AnyObject?) {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()

        if let beaconDetails = content as? BeaconDetails {
//            self.view.backgroundColor = beaconDetails.backgroundColor
            if (beaconDetails.beaconName == "beetroot"){ self.view.backgroundColor = UIColor(patternImage: UIImage(named:"poster")!) }
            if (beaconDetails.beaconName == "candy"){ self.view.backgroundColor = UIColor(patternImage: UIImage(named:"details")!) }
            self.label.text = "Project Bluetooth Low Energy!"

//            self.label.text = "You're in \(beaconDetails.beaconName)'s range!"
            self.image.isHidden = true
        } else {
            self.view.backgroundColor = BeaconDetails.neutralColor
            self.label.text = "No beacons in range."
            self.image.isHidden = true
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
