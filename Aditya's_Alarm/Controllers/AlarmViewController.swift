//
//  AlarmViewController.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 04/02/25.
//
import CoreData
import UIKit

class AlarmViewController: UIViewController, TimePickerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath: IndexPath? // Store selected cell index
    var times: [TimeModel] = []  // Array to store selected times
    
    @IBOutlet weak var setAlarmButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchDataAndReloadTable()
        // Do any additional setup after loading the view.
    }
    func didSelectTime(hour: String, minutes: String, amPm: String) {
        // Create new TimeModel object with the selected time
        let newTime = TimeModel(hour: hour, minute: minutes, amPm: amPm)
        
        // Add new time to the times array
        times.append(newTime)
        
        // Reload the table view to display the new time
        tableView.reloadData()
        
        // Optionally, you can dismiss the popup after adding the time
        self.dismiss(animated: true, completion: nil)
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
    }
    
    // 3️⃣ Provide a cell for a row (required)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as! AlarmTableViewCell
        
        cell.selectionStyle = .none
        cell.containerView.layer.cornerRadius = 15
        cell.containerView.layer.shadowOpacity = 0.5
        cell.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.containerView.layer.shadowRadius = 7
        cell.containerView.layer.shadowColor = UIColor.darkGray.cgColor
        cell.containerView.layer.masksToBounds = false
        let isExpanded = indexPath == selectedIndexPath
        cell.updateUI(isExpanded: isExpanded)
        
        let time = times[indexPath.row]
//        cell.textLabel?.text = "\(time.hour):\(time.minute)"
        cell.timeLabel.text = "\(time.hour):\(time.minute)"
        cell.amPmLabel.text = "\(time.amPm)"
        return cell
    }
    
    // 4️⃣ Support reordering (optional)
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
extension AlarmViewController {
    // Create a common delete action
       func createDeleteAction(for indexPath: IndexPath) -> UIContextualAction {
           return UIContextualAction(style: .destructive, title: "Delete") { _, _, completionHandler in
               
               // Remove data from array
               self.times.remove(at: indexPath.row)
               
               // Delete the row from the tableView
               self.tableView.deleteRows(at: [indexPath], with: .fade)
               
               // Reset selected index if needed
               if self.selectedIndexPath == indexPath {
                   self.selectedIndexPath = nil
               }
               
               completionHandler(true) // Complete action
           }
       }
    func fetchDataAndReloadTable() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AlarmTime> = AlarmTime.fetchRequest()
        
        do {
            let alarmTimes = try context.fetch(fetchRequest)
            // Convert to array of TimeModel
            times = alarmTimes.map { TimeModel(hour: $0.hour!, minute: $0.minute!, amPm: $0.amPm!) }
            tableView.reloadData()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
}
//      MARK: Core Data Functions
extension TimePickerView {
    func saveTimeToCoreData(hour: String, minute: String, amPm: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Create a new AlarmTime object
        let newAlarmTime = AlarmTime(context: context)
        newAlarmTime.hour = hour
        newAlarmTime.minute = minute
        newAlarmTime.amPm = amPm
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }


}

