//
//  MyTripsViewController.swift
//  appTest
//
//  Created by Valentin Camara on 20/07/2018.
//  Copyright © 2018 Valentin Camara. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MyTripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataArray: [Trip] = []
    let context = PersistenceService.context
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 100
        dataArray = DataController.requestData()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        let duration = newTripViewController.calculateTime(startingTime: dataArray[indexPath.row].startingTime! as Date, endingTime: dataArray[indexPath.row].endingTime! as Date)
        
        cell.name.text = dataArray[indexPath.row].name!
        cell.date.text = MyTripsViewController.dateToString(date: dataArray[indexPath.row].startingTime! as Date)
        cell.distance.text = "Distance: " + String(format: "%.3f", dataArray[indexPath.row].distance)
        cell.duration.text = "Duration: " + String(format: "%d' %d\"", duration/60, duration%60)
        cell.speed.text = "Speed: " + String(format: "%.1f", dataArray[indexPath.row].averageSpeed) + " km/h "
        cell.location = dataArray[indexPath.row].location!
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let trip = dataArray[indexPath.row]
            context.delete(trip)
            do {
                try context.save()
            } catch {
                print("Error deleting")
            }
            dataArray = DataController.requestData()
            tableView.reloadData()
        }
        if editingStyle == .insert {
            let trip = dataArray[indexPath.row]
            context.delete(trip)
            do {
                try context.save()
            } catch {
                print("Error deleting")
            }
            dataArray = DataController.requestData()
            tableView.reloadData()
        }
    }

    static func dateToString(date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        return "Time: \(day)-\(month) at \(hour)"
    }
    
    @IBAction func goBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func goToSavedMap() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "savedMap") as! SavedMapViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
 
}

var globalLocation: [CLLocation] = []

class CustomCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var distance: UILabel!
    var location: [CLLocation] = []
    
    @IBAction func makePDF(_ sender: Any) {
        // 1. Create Print Formatter with input text.

        var text =  name.text! + "\n---------------\n"
        text = text + date.text! + "\n---------------\n"
        text = text + duration.text! + "\n---------------\n"
        text = text + speed.text! + "\n---------------\n"
        text = text + distance.text! + "\n---------------\n"
        
        let formatter = UIMarkupTextPrintFormatter(markupText: text)
        // 2. Add formatter with pageRender
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        // 4. Create PDF context and draw
        let rect = CGRect.zero
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, rect, nil)
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        UIGraphicsEndPDFContext();
        // 5. Save PDF file
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        pdfData.write(toFile: "\(documentsPath)/new.pdf", atomically: true)
        print("saved success")
    }
    
    
    @IBAction func printMap(_ sender: Any) {
        globalLocation = location
        if let myViewController = parentViewController as? MyTripsViewController {
            myViewController.goToSavedMap()
        }
        
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
