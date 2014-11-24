//
//  ViewController.swift
//  SwiftUIPickerFormatted
//
//  Created by Steven Lipton on 10/20/14.
//  Copyright (c) 2014 MakeAppPie.Com. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var myLabel: UILabel!
    var pickerData = Array(45...1000).filter { (number) in number % 5 == 0 }
    var plates = [45.0,35.0,25.0,10.0,5.0,2.5]
    var barWeight = 45.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel.text = "0"
        myPicker.delegate = self
        myPicker.dataSource = self
        
    }
    
    //MARK: - Delegates and datasources
    //MARK: Data Sources
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(pickerData[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var platesNeeded = [Double]()
        var weightRemaining = Double(pickerData[row]) - barWeight
        while (weightRemaining > 0) {
            println(weightRemaining)
            for weight in plates {
                if (weight * 2.0 <= weightRemaining) {
                    platesNeeded.append(weight)
                    weightRemaining -= weight * 2
                    break
                }
            }
        }
        
        myLabel.text = platesNeeded.description
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = String(pickerData[row])
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            pickerLabel.textAlignment = .Center
            
        }
        let titleData = String(pickerData[row])
        let myTitle = NSAttributedString(string: titleData)
        pickerLabel!.attributedText = myTitle
        
        return pickerLabel
        
    }
    
}