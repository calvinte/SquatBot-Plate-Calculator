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

    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        println("panning?")
    }

    var pickerData = Array(45...1000).filter { (number) in number % 5 == 0 }
    var plates = [45.0,35.0,25.0,10.0,5.0,2.5]
    var barWeight = 45.0
    let collarWidth:CGFloat = 5
    var weightOffsetX:Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel.text = "0"
        myPicker.delegate = self
        myPicker.dataSource = self

        
        myScene.scene = SCNScene()
        myScene.autoenablesDefaultLighting = true
        myScene.antialiasingMode = SCNAntialiasingMode.Multisampling4X
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
        // IWF spec(ish) @see: http://en.wikipedia.org/wiki/Barbell
        let barWidth = CGFloat(2.8)
        let barHeight = CGFloat(131)
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

    func drawPlate(size: Float) {
        let plateHeight = CGFloat((size / 6 + 0.125) * 45)
        let plateWidth = plateHeight * 0.1
        let color = UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1.0)
        let innerHeight = collarWidth + 4
        let outerHeight = plateHeight - 2

        let innerGeometry = SCNTube(innerRadius: collarWidth + 0.2, outerRadius: innerHeight, height: plateWidth)
        innerGeometry.firstMaterial?.diffuse.contents = color
        let innerNode = SCNNode(geometry: innerGeometry)
        innerNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI / 2))
        innerNode.position = SCNVector3(x: weightOffsetX, y: 0.0, z: 0.0)

        let outerGeometry = SCNTube(innerRadius: outerHeight, outerRadius: plateHeight, height: plateWidth)
        outerGeometry.firstMaterial?.diffuse.contents = color
        let outerNode = SCNNode(geometry: outerGeometry)
        outerNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI / 2))
        outerNode.position = SCNVector3(x: weightOffsetX, y: 0.0, z: 0.0)

        let connectorGeometry = SCNTube(innerRadius: innerHeight, outerRadius: outerHeight, height: plateWidth / 8)
        connectorGeometry.firstMaterial?.diffuse.contents = color
        let connectorNode = SCNNode(geometry: connectorGeometry)
        connectorNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI / 2))
        connectorNode.position = SCNVector3(x: weightOffsetX, y: 0.0, z: 0.0)

        weightOffsetX -= Float(plateWidth + 1)
        myScene.scene?.rootNode.addChildNode(innerNode)
        myScene.scene?.rootNode.addChildNode(outerNode)
        myScene.scene?.rootNode.addChildNode(connectorNode)
    }

    func clearPlates() {
        let nodes = myScene.scene?.rootNode.childNodes
        for node in nodes ?? [] {
            node.removeFromParentNode()
        }
        weightOffsetX = 0
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
            drawPlate(size)
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