//
//  AlarmTableViewCell.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 04/02/25.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var swipedownButton: UIButton!
    
    @IBOutlet weak var OnOFFButton: UISwitch!
    
    @IBOutlet weak var scheduleLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bellImgView: UIImageView!
    @IBOutlet weak var ringToneLabel: UILabel!
    @IBOutlet weak var binImg: UIImageView!
    @IBOutlet weak var deleteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateUI(isExpanded: Bool) {
        stackView.isHidden = !isExpanded
        ringToneLabel.isHidden = !isExpanded
        bellImgView.isHidden = !isExpanded
        binImg.isHidden = !isExpanded
        deleteLabel.isHidden = !isExpanded
    }
    
    @IBAction func ofOff(_ sender: UISwitch) {
    }
    @IBAction func swipeDownBtn(_ sender: UIButton) {
    }
    
}
