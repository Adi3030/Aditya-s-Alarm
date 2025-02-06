//
//  AlarmTableViewCell.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 04/02/25.
//

import UIKit
protocol AlarmCellDelegate: AnyObject {
    func didTapDeleteButton(_ cell: AlarmTableViewCell)
    func alarmSwitchToggled(isOn: Bool, at indexPath: IndexPath)
}


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
    
    weak var delegate: AlarmCellDelegate?
    var indexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteLabelTapped))
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configureCell(at indexPath: IndexPath) {
            self.indexPath = indexPath
        }
    func updateUI(isExpanded: Bool) {
        stackView.isHidden = !isExpanded
        ringToneLabel.isHidden = !isExpanded
        bellImgView.isHidden = !isExpanded
        binImg.isHidden = !isExpanded
        deleteLabel.isHidden = !isExpanded
    }
    
    @IBAction func ofOff(_ sender: UISwitch) {
        if let indexPath = indexPath {
            delegate?.alarmSwitchToggled(isOn: sender.isOn, at: indexPath)
        }
    }
    @IBAction func swipeDownBtn(_ sender: UIButton) {
    }
    @objc func deleteLabelTapped() {
        delegate?.didTapDeleteButton(self)
    }
}
