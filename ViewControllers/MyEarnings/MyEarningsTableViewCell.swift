//
//  MyEarningsTableViewCell.swift
//  TEGO-Driver
//
//  Created by EWW082 on 25/03/19.
//  Copyright © 2019 Excellent Webworld. All rights reserved.
//

import UIKit

class MyEarningsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblBookingIDTitle: UILabel!
    @IBOutlet weak var lblPassengerNameTitle: UILabel!
    @IBOutlet weak var lblPickupLocationTitle: UILabel!
    @IBOutlet weak var lblDropoffLocationTitle: UILabel!
    @IBOutlet weak var lblDateTimeTitle: UILabel!
    @IBOutlet weak var lblEarnTitle: UILabel!
    
    @IBOutlet weak var lblBookingID: UILabel!
    @IBOutlet weak var lblPassengerName: UILabel!
    @IBOutlet weak var lblPickupLocation: UILabel!
    @IBOutlet weak var lblDropoffLocation: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblEarn: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
