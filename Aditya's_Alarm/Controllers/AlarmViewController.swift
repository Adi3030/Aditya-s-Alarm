//
//  AlarmViewController.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 04/02/25.
//
import CoreData
import UIKit
import UserNotifications


class AlarmViewController: UIViewController, TimePickerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath: IndexPath? // Store selected cell index
    var times: [TimeModel] = []  // Array to store selected times
    let soundName = "alarm_sound.mp3"
    @IBOutlet weak var setAlarmButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchDataAndReloadTable()
        requestNotificationPermission()
        // Do any additional setup after loading the view.
    }
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied: \(String(describing: error))")
            }
        }
    }
    func didSelectTime(hour: String, minutes: String, amPm: String, isActive: Bool) {
        let newTime = TimeModel(hour: hour, minute: minutes, amPm: amPm, isActive: isActive)
        times.append(newTime)
        tableView.reloadData()
        
        // Save to Core Data
        saveTimeToCoreData(hour: hour, minute: minutes, amPm: amPm, isActive: isActive)
        
        // Schedule notification for alarm if active
        if isActive {
            scheduleNotification(hour: hour, minute: minutes, amPm: amPm)
        }
    }

    
    
    func didCancelSelection() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setAlarm(_ sender: UIButton) {
        let timePicker = TimePickerView(frame: view.bounds)
        timePicker.delegate = self
        view.addSubview(timePicker)
    }
    
}
//      MARK: Table View delegate
/* In Swift, UITableView has two main delegate protocols:
 
 UITableViewDelegate – Handles user interactions, like selection, row height, swipe actions, etc.
 
 */
extension AlarmViewController: UITableViewDelegate {
    // 1️⃣ Detect row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Determine whether to expand or collapse
        let previouslySelectedIndex = selectedIndexPath
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil // Collapse if already selected
        } else {
            selectedIndexPath = indexPath // Expand new selection
        }
        
        // Reload previously selected row to collapse it
        var indexPathsToReload: [IndexPath] = []
        if let previous = previouslySelectedIndex {
            indexPathsToReload.append(previous)
        }
        indexPathsToReload.append(indexPath)
        
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    // 2️⃣ Set row height (optional)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath == selectedIndexPath ? 260 : 150
    }
    /*
     // 3️⃣ Set header & footer titles (optional)
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return "Section \(section)"
     }
     
     func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
     return "End of Section \(section)"
     }
     
     // 4️⃣ Provide a custom header view (optional)
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     let headerView = UIView()
     headerView.backgroundColor = .lightGray
     return headerView
     }
     */
    
    // 5️⃣ Enable swipe actions (optional)
    // Swipe Left Action (Trailing - Right Side)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = createDeleteAction(for: indexPath)
        deleteAction.image = UIImage(systemName: "trash") // Optional trash icon
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // Swipe Right Action (Leading - Left Side)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = createDeleteAction(for: indexPath)
        deleteAction.image = UIImage(systemName: "trash.fill") // Optional filled trash icon
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

//      MARK:  Table View dataSource methods
/* UITableViewDataSource – Manages the data, like providing cells and handling insertions/deletions. */
extension AlarmViewController: UITableViewDataSource {
    // 1️⃣ Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 2️⃣ Number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
        // technican git check
    }
    
    // 3️⃣ Provide a cell for a row (required)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as! AlarmTableViewCell
        
        cell.selectionStyle = .none
        cell.delegate = self
        cell.containerView.layer.cornerRadius = 15
        cell.containerView.layer.shadowOpacity = 0.5
        cell.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.containerView.layer.shadowRadius = 7
        cell.containerView.layer.shadowColor = UIColor.darkGray.cgColor
        cell.containerView.layer.masksToBounds = false
        let isExpanded = indexPath == selectedIndexPath
        cell.updateUI(isExpanded: isExpanded)
        cell.configureCell(at: indexPath)
        let time = times[indexPath.row]
        cell.timeLabel.text = "\(time.hour):\(time.minute)"
        cell.amPmLabel.text = "\(time.amPm)"
        cell.OnOFFButton.isOn = time.isActive
        return cell
    }
    
    // 4️⃣ Support reordering (optional)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
extension AlarmViewController: AlarmCellDelegate {
    func alarmSwitchToggled(isOn: Bool, at indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AlarmTime> = AlarmTime.fetchRequest()
        
        do {
            let alarmTimes = try context.fetch(fetchRequest)
            if indexPath.row < alarmTimes.count {
                let alarmToUpdate = alarmTimes[indexPath.row]
                alarmToUpdate.isActive = isOn  // Update the isActive status
                try context.save()  // Save the changes to Core Data
                
                // If the alarm is turned on, schedule the notification
                if isOn {
                    scheduleAlarm(for: TimeModel(hour: alarmToUpdate.hour!, minute: alarmToUpdate.minute!, amPm: alarmToUpdate.amPm!, isActive: isOn), indexPath: indexPath)
                } else {
                    cancelAlarm(for: TimeModel(hour: alarmToUpdate.hour!, minute: alarmToUpdate.minute!, amPm: alarmToUpdate.amPm!, isActive: isOn), indexPath: indexPath)
                }
            }
        } catch {
            print("Failed to update Core Data: \(error)")
        }
    }
    
    func verifyAlarmState(indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AlarmTime> = AlarmTime.fetchRequest()
        
        do {
            let alarmTimes = try context.fetch(fetchRequest)
            if indexPath.row < alarmTimes.count {
                let alarm = alarmTimes[indexPath.row]
                print("Alarm at index \(indexPath.row) is active: \(alarm.isActive)")  // Check if isActive is updated
            }
        } catch {
            print("Error fetching alarms: \(error)")
        }
    }
    
    func scheduleAlarm(for time: TimeModel, indexPath: IndexPath) {
        // Ensure the alarm is active before scheduling
        if time.isActive {
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "It's time to wake up!"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
            
            var hourInt = Int(time.hour) ?? 0
            let minuteInt = Int(time.minute) ?? 0
            if time.amPm.lowercased() == "pm" && hourInt != 12 {
                hourInt += 12
            } else if time.amPm.lowercased() == "am" && hourInt == 12 {
                hourInt = 0
            }
            
            var dateComponents = DateComponents()
            dateComponents.hour = hourInt
            dateComponents.minute = minuteInt
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "alarm_\(indexPath.row)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                } else {
                    print("Alarm set for \(time.hour):\(time.minute) \(time.amPm)")
                }
            }
        }
    }
    
    func cancelAlarm(for time: TimeModel, indexPath: IndexPath) {
        // If the alarm is turned off, remove the notification
        if !time.isActive {
            let identifier = "alarm_\(indexPath.row)"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            print("Cancelled alarm for \(time.hour):\(time.minute) \(time.amPm)")
        }
    }
    
    func didTapDeleteButton(_ cell: AlarmTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            deleteAlarm(at: indexPath)
        }
    }
    
    func deleteAlarm(at indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AlarmTime> = AlarmTime.fetchRequest()
        
        do {
            let alarmTimes = try context.fetch(fetchRequest)
            
            if indexPath.row < alarmTimes.count {
                let alarmToDelete = alarmTimes[indexPath.row]
                
                // Remove from Core Data
                context.delete(alarmToDelete)
                
                // Save changes
                try context.save()
                
                // Remove from local array
                let deletedTime = times.remove(at: indexPath.row)
                
                // Cancel the notification for the deleted alarm
                let identifier = "\(deletedTime.hour):\(deletedTime.minute)"
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                
                // Reset selected index to collapse all expanded cells
                selectedIndexPath = nil
                
                // Reload the table view
                tableView.reloadData()
            }
        } catch {
            print("Failed to delete from Core Data: \(error)")
        }
    }
    
    
    
    // Create a common delete action
    func createDeleteAction(for indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
            self.deleteAlarm(at: indexPath)
            completionHandler(true) // Complete action
        }
    }
    
    func fetchDataAndReloadTable() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AlarmTime> = AlarmTime.fetchRequest()
        
        do {
            let alarmTimes = try context.fetch(fetchRequest)
            // Convert to array of TimeModel, including isActive status
            times = alarmTimes.map { TimeModel(hour: $0.hour!, minute: $0.minute!, amPm: $0.amPm!, isActive: $0.isActive) }
            tableView.reloadData()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    
}
//      MARK: Core Data Functions
extension AlarmViewController {
    func saveTimeToCoreData(hour: String, minute: String, amPm: String, isActive: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Create a new AlarmTime object
        let newAlarmTime = AlarmTime(context: context)
        newAlarmTime.hour = hour
        newAlarmTime.minute = minute
        newAlarmTime.amPm = amPm
        newAlarmTime.isActive = isActive  // Store the dynamic active state
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    
    func scheduleNotification(hour: String, minute: String, amPm: String) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Your alarm is ringing!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        
        // Convert `hour`, `minute`, `amPm` to 24-hour format
        var hourInt = Int(hour) ?? 0
        let minuteInt = Int(minute) ?? 0
        if amPm.lowercased() == "pm" && hourInt != 12 {
            hourInt += 12
        } else if amPm.lowercased() == "am" && hourInt == 12 {
            hourInt = 0
        }
        
        // Set notification trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hourInt
        dateComponents.minute = minuteInt
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Alarm set for \(hour):\(minute) \(amPm)")
            }
        }
    }
    
}

