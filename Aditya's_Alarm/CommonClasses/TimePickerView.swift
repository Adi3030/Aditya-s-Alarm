//
//  TimePickerView.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 04/02/25.
//

import UIKit

protocol TimePickerViewDelegate: AnyObject {
    func didSelectTime(hour: String, minutes: String, amPm: String)
    func didCancelSelection()
}

class TimePickerView: UIView, UITextFieldDelegate {
    
    weak var delegate: TimePickerViewDelegate?
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Time"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let hourTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "HH"
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let colonLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let minuteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "MM"
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let amPmSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["AM", "PM"])
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        hourTextField.delegate = self
        minuteTextField.delegate = self
        
        backgroundView.frame = UIScreen.main.bounds
        addSubview(backgroundView)
        addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [hourTextField, colonLabel, minuteTextField])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(amPmSegment)
        containerView.addSubview(okButton)
        containerView.addSubview(cancelButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        amPmSegment.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            hourTextField.widthAnchor.constraint(equalToConstant: 50),
            minuteTextField.widthAnchor.constraint(equalToConstant: 50),
            
            amPmSegment.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            amPmSegment.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            okButton.topAnchor.constraint(equalTo: amPmSegment.bottomAnchor, constant: 20),
            okButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            okButton.widthAnchor.constraint(equalToConstant: 100),
            
            cancelButton.topAnchor.constraint(equalTo: amPmSegment.bottomAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc private func okButtonTapped() {
        guard let hourText = hourTextField.text, let minuteText = minuteTextField.text,
              let hour = Int(hourText), let minutes = Int(minuteText),
              hour >= 1, hour <= 12, minutes >= 0, minutes <= 59 else {
            print("Invalid time entered")
            hourTextField.resignFirstResponder()
            minuteTextField.resignFirstResponder()
            showToast(message: "aPlease enter a valid time")
            
            return
        }
        
        let amPm = amPmSegment.selectedSegmentIndex == 0 ? "AM" : "PM"
        delegate?.didSelectTime(hour: hourText, minutes: minuteText, amPm: amPm)
        saveTimeToCoreData(hour: hourText, minute: minuteText, amPm: amPm)
        // Reload table view (you'll fetch the data again)
         
        self.removeFromSuperview()
    }
    
    
    @objc private func cancelButtonTapped() {
        delegate?.didCancelSelection()
        removeFromSuperview()
    }
    // Limit text fields to 2 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent more than 2 characters
        let maxLength = 2
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Allow only digits (0-9) and limit to 2 characters
        let allowedCharacterSet = CharacterSet.decimalDigits
        let isNumeric = string.rangeOfCharacter(from: allowedCharacterSet) != nil || string.isEmpty
        return isNumeric && newText.count <= maxLength
    }
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.frame.size.height - 100, width: self.frame.size.width - 40, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        self.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
    
}

