import UIKit
import SceneKit

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,SCNSceneRendererDelegate {
    
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myScene: SCNView!
    @IBOutlet var myPan: UIPanGestureRecognizer!
    @IBAction func handleGesture(sender: AnyObject) {
        println("Panning?")
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
        cameraNode.position = SCNVector3(x: 0, y: -30, z: 130)
        cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI_2))
        myScene.scene?.rootNode.addChildNode(cameraNode)
    }

    func drawBar() {
        // IWF spec(ish) @see: http://en.wikipedia.org/wiki/Barbell
        let barWidth = CGFloat(2.8)
        let barHeight = CGFloat(131)
        let collarHeight = CGFloat(44.5)
        let color = UIColor.lightGrayColor()
        let bumperSize:CGFloat = 3
        let collarInner = collarWidth/2 - 0.5
        let collarLength = collarHeight - bumperSize
        let rotationVector = SCNVector4(x: 0, y: 0, z: 0, w: 0)

        let barGeometry = SCNCylinder(radius: barWidth/2, height: barHeight)
        barGeometry.firstMaterial?.diffuse.contents = color
        let barNode = SCNNode(geometry: barGeometry)
        barNode.rotation = rotationVector
        let barX = Float(barHeight/2)
        barNode.position = SCNVector3(x: 0, y: barX, z: 0.0)

        let bumperGeometry = SCNCylinder(radius: collarWidth/2 + 1, height: bumperSize)
        bumperGeometry.firstMaterial?.diffuse.contents = color
        let bumperNode = SCNNode(geometry: bumperGeometry)
        bumperNode.rotation = rotationVector
        let bumperX = -0.5 * Float(bumperSize)
        bumperNode.position = SCNVector3(x: 0, y: bumperX, z: 0.0)
        weightOffsetX -= Float(bumperSize)

        let collarGeometry = SCNTube(innerRadius: collarInner, outerRadius: collarWidth/2, height: collarLength)
        collarGeometry.firstMaterial?.diffuse.contents = color
        let collarNode = SCNNode(geometry: collarGeometry)
        collarNode.rotation = rotationVector
        let collarX = -0.5 * Float(collarHeight - bumperSize) - Float(bumperSize)
        collarNode.position = SCNVector3(x: 0, y: collarX, z: 0.0)

        let collarInnerGeometry = SCNCylinder(radius: collarInner, height: collarLength - 1)
        collarInnerGeometry.firstMaterial?.diffuse.contents = UIColor.darkGrayColor()
        let collarInnerNode = SCNNode(geometry: collarInnerGeometry)
        collarInnerNode.rotation = rotationVector
        collarInnerNode.position = SCNVector3(x: 0, y: collarX, z: 0.0)

        let collarBadgeHeight:CGFloat = 0.75
        let collarBadgeGeometry = SCNCylinder(radius: collarInner - 0.5, height: collarBadgeHeight)
        collarBadgeGeometry.firstMaterial?.diffuse.contents = UIColor.lightGrayColor()
        let collarBadgeNode = SCNNode(geometry: collarBadgeGeometry)
        collarBadgeNode.rotation = rotationVector
        collarBadgeNode.position = SCNVector3(x: 0, y: collarX - Float(collarLength)/2 + 0.5, z: 0.0)

        myScene.scene?.rootNode.addChildNode(barNode)
        myScene.scene?.rootNode.addChildNode(bumperNode)
        myScene.scene?.rootNode.addChildNode(collarNode)
        myScene.scene?.rootNode.addChildNode(collarInnerNode)
        myScene.scene?.rootNode.addChildNode(collarBadgeNode)
    }

    func drawPlate(weight: Double) {
        let size = Float(plates.count - (find(plates, weight)!))
        let plateHeight = CGFloat((size / 6 + 0.5) / 2 * 45)
        let plateWidth = plateHeight * 0.125
        let color = UIColor.darkGrayColor()
        let innerHeight = collarWidth/2 + 4
        let outerHeight = plateHeight - 1
        let rotationVector = SCNVector4(x: 0, y: 0, z: 0, w: 0)
        weightOffsetX -= Float(plateWidth/2)
        let positionVector = SCNVector3(x: 0, y: weightOffsetX, z: 0.0)
        let thickness = plateWidth / 4

        let innerGeometry = SCNTube(innerRadius: collarWidth/2 + 0.2, outerRadius: innerHeight, height: plateWidth)
        innerGeometry.firstMaterial?.diffuse.contents = color
        let innerNode = SCNNode(geometry: innerGeometry)
        innerNode.rotation = rotationVector
        innerNode.position = positionVector

        let outerGeometry = SCNTube(innerRadius: outerHeight, outerRadius: plateHeight, height: plateWidth)
        outerGeometry.firstMaterial?.diffuse.contents = color
        let outerNode = SCNNode(geometry: outerGeometry)
        outerNode.rotation = rotationVector
        outerNode.position = positionVector

        let connectorGeometry = SCNTube(innerRadius: innerHeight, outerRadius: outerHeight, height: thickness)
        connectorGeometry.firstMaterial?.diffuse.contents = color
        let connectorNode = SCNNode(geometry: connectorGeometry)
        connectorNode.rotation = rotationVector
        connectorNode.position = positionVector

        let weightFormatter = NSNumberFormatter()
        weightFormatter.maximumFractionDigits = 1
        weightFormatter.minimumFractionDigits = 0
        var fontSize:CGFloat
        if (weight < 5) {
            fontSize = 2
        } else {
            fontSize = 3
        }
        let textGeometry = SCNText(string: weightFormatter.stringFromNumber(weight)!, extrusionDepth: thickness)
        //textGeometry.containerFrame = CGRect(x: 0, y: 0, width:plateHeight, height:plateHeight * 0.75)
        textGeometry.font = UIFont (name: "Courier", size: fontSize)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.lightGrayColor()
        //BUG: textGeometry.alignmentMode = kCAAlignmentCenter

        for r in 1...3 {
            let textNode = SCNNode(geometry: textGeometry)
            let offset = Float(weightOffsetX) + Float(-1) * Float(thickness) / 2
            //Float(r)
            //textNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI_2))
            textNode.eulerAngles = SCNVector3(x: Float(DegreesToRadians(90)), y: Float(DegreesToRadians(360.0/3 * Double(r))), z: 0.0)
            textNode.position = SCNVector3(x: 0, y: offset, z: 0.0)
            // When SCNText.alignmentMode is fixed, don't do this
            if (weight < 10) {
                textNode.pivot = SCNMatrix4MakeTranslation(1.5, Float(plateHeight)*0.75, 0) // One character
            } else {
                textNode.pivot = SCNMatrix4MakeTranslation(3, Float(plateHeight)*0.75, 0) // Two characters
            }
            myScene.scene?.rootNode.addChildNode(textNode)
        }

        weightOffsetX -= Float(plateWidth/2 + 1)
        myScene.scene?.rootNode.addChildNode(innerNode)
        myScene.scene?.rootNode.addChildNode(outerNode)
        myScene.scene?.rootNode.addChildNode(connectorNode)
    }

    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }

    func clearPlates() {
        let nodes = myScene.scene?.rootNode.childNodes
        for node in nodes ?? [] {
            node.removeFromParentNode()
        }
        weightOffsetX = 0
        drawCamera()
        drawBar()
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
        for (index, weight) in enumerate(platesNeeded) {
            drawPlate(weight)
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