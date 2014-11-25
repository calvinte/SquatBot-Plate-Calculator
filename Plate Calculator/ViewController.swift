//
//  ViewController.swift
//  SwiftUIPickerFormatted
//
//  Created by Steven Lipton on 10/20/14.
//  Copyright (c) 2014 MakeAppPie.Com. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,SCNSceneRendererDelegate {
    
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myScene: SCNView!

    var pickerData = Array(45...1000).filter { (number) in number % 5 == 0 }
    var plates = [45.0,35.0,25.0,10.0,5.0,2.5]
    var barWeight = 45.0

    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel.text = "0"
        myPicker.delegate = self
        myPicker.dataSource = self

        
        myScene.scene = SCNScene()
        myScene.autoenablesDefaultLighting = true
        //myScene.allowsCameraControl = true

        drawCamera()
        drawBar()
    }
    
    //MARK: - Delegates and datasources
    //MARK: Data Sources
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func drawCamera() {
        var cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3(x: -30, y: 0, z: 130)
        myScene.scene?.rootNode.addChildNode(cameraNode)
    }

    func drawBar() {
        // IWF spec @see: http://en.wikipedia.org/wiki/Barbell
        let barWidth = CGFloat(2.8)
        let barHeight = CGFloat(131)
        let collarWidth = CGFloat(5)
        let collarHeight = CGFloat(44.5)
        let color = UIColor(hue: 0, saturation: 0, brightness: 0.7, alpha: 1.0)

        let barGeometry = SCNCylinder(radius: barWidth, height: barHeight)
        barGeometry.firstMaterial?.diffuse.contents = color
        let barNode = SCNNode(geometry: barGeometry)
        barNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI / 2))
        let barX = Float(barHeight/2)
        barNode.position = SCNVector3(x: barX, y: 0.0, z: 0.0)

        let collarGeometry = SCNCylinder(radius: collarWidth, height: collarHeight)
        collarGeometry.firstMaterial?.diffuse.contents = color
        let collarNode = SCNNode(geometry: collarGeometry)
        collarNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI / 2))
        let collarX = -0.5 * Float(collarHeight)
        collarNode.position = SCNVector3(x: collarX, y: 0.0, z: 0.0)

        myScene.scene?.rootNode.addChildNode(barNode)
        myScene.scene?.rootNode.addChildNode(collarNode)
    }

    func drawPlate(position: Int, size: Float) {
        let plateHeight = CGFloat((size / 6 + 0.125) * 45)
        let plateWidth = plateHeight * 0.1
        let cylinderGeometry = SCNTube(innerRadius: 0.13, outerRadius: plateHeight, height: plateWidth)

        let color = UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1.0)
        cylinderGeometry.firstMaterial?.diffuse.contents = color

        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        cylinderNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI / 2))

        let x = Float(0.125 * 45) * Float(position)
        cylinderNode.position = SCNVector3(x: x, y: 0.0, z: 0.0)

        myScene.scene?.rootNode.addChildNode(cylinderNode)
    }

    func clearPlates() {
        let nodes = myScene.scene?.rootNode.childNodes
        for node in nodes ?? [] {
            node.removeFromParentNode()
        }
    }

    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(pickerData[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var platesNeeded = [Double]()
        var weightRemaining = Double(pickerData[row]) - barWeight
        while (weightRemaining > 0) {
            for weight in plates {
                if (weight * 2.0 <= weightRemaining) {
                    platesNeeded.append(weight)
                    weightRemaining -= weight * 2
                    break
                }
            }
        }
        
        clearPlates()
        drawCamera()
        drawBar()
        for (index, weight) in enumerate(platesNeeded) {
            let size = Float(plates.count - (find(plates, weight)!))
            drawPlate(-1 * (index + 1), size: size)
        }

        myLabel.text = platesNeeded.description
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