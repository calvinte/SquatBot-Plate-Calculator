import UIKit
import SceneKit

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,SCNSceneRendererDelegate {
    
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myScene: SCNView!
    @IBOutlet var myPan: UIPanGestureRecognizer!
    @IBAction func handleGesture(recognizer: UIPanGestureRecognizer!) {
        let translation = recognizer.translationInView(myScene).x
        let goalTranslation = myScene.frame.size.width / 2
        let panX = deltaPanX + recognizer.translationInView(myScene).y
        var progress = Float(translation / goalTranslation)
        if (progress > 1) { progress = 1 }

        if (progress > 0) {
            let deltaEuler = progress * Float(destCameraEulerY - originCameraEulerY)
            let deltaPosiY = progress * (destCameraPositionY - originCameraPositionY)
            let deltaPosiZ = progress * (destCameraPositionZ - originCameraPositionZ)

            cameraNode.eulerAngles.y = Float(DegreesToRadians(Double(Float(originCameraEulerY) + deltaEuler)))
            cameraNode.position.y = originCameraPositionY + deltaPosiY
            cameraNode.position.z = originCameraPositionZ + deltaPosiZ
            legendNode.opacity = CGFloat(progress)
        }
        platesNode.eulerAngles.y = Float(DegreesToRadians(Double(panX)))

        if (recognizer.state == UIGestureRecognizerState.Ended) {
            deltaPanX = panX
            let moveAction = SCNAction.moveTo(originCameraPosition, duration:0.3)
            let rotateAction = SCNAction.rotateToX(
                CGFloat(DegreesToRadians(0)),
                y:CGFloat(DegreesToRadians(originCameraEulerY)),
                z:CGFloat(DegreesToRadians(originCameraEulerZ)),
                duration:0.3
            )
            let opacityAction = SCNAction.fadeOpacityTo(0, duration:0.3)
            cameraNode.runAction(moveAction)
            cameraNode.runAction(rotateAction)
            legendNode.runAction(opacityAction)
        }
    }

    let pickerData = Array(45...1000).filter { (number) in number % 5 == 0 }
    let plates = [45.0,35.0,25.0,10.0,5.0,2.5]
    let barWeight = 45.0
    let collarWidth:CGFloat = 5
    var weightOffsetX:Float = 0

    let platesNode = SCNNode()
    let legendNode = SCNNode()
    let cameraNode = SCNNode()

    var deltaPanX:CGFloat = 0

    let originCameraEulerY:Double = 0
    let destCameraEulerY:Double = -60
    let originCameraEulerZ:Double = 90
    let originCameraPositionY:Float = -30
    let destCameraPositionY:Float = -200
    let originCameraPositionZ:Float = 130
    let destCameraPositionZ:Float = 0
    var originCameraPosition:SCNVector3!

    let weightFormatter = NSNumberFormatter()

    override func viewDidLoad() {
        weightFormatter.maximumFractionDigits = 1
        weightFormatter.minimumFractionDigits = 0
        super.viewDidLoad()
        myLabel.text = "0"
        myPicker.delegate = self
        myPicker.dataSource = self
        originCameraPosition = SCNVector3(x: 0, y: originCameraPositionY, z: originCameraPositionZ)

        myScene.scene = SCNScene()
        myScene.autoenablesDefaultLighting = true
        myScene.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        //myScene.allowsCameraControl = true

        drawCamera()
        drawBar()
        drawLegend([])
        legendNode.opacity = 0
        myScene.scene?.rootNode.addChildNode(legendNode)
        myScene.scene?.rootNode.addChildNode(platesNode)
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
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 1000
        cameraNode.position = originCameraPosition
        //cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(M_PI_2))
        cameraNode.eulerAngles = SCNVector3(x: 0, y: Float(DegreesToRadians(originCameraEulerY)), z: Float(DegreesToRadians(originCameraEulerZ)))

        myScene.scene?.rootNode.addChildNode(cameraNode)
    }

    func drawBar() {
        // IWF spec(ish) @see: http://en.wikipedia.org/wiki/Barbell
        let barNode = SCNNode()
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
        let handleNode = SCNNode(geometry: barGeometry)
        handleNode.rotation = rotationVector
        let barX = Float(barHeight/2)
        handleNode.position = SCNVector3(x: 0, y: barX, z: 0.0)

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

        barNode.addChildNode(handleNode)
        barNode.addChildNode(bumperNode)
        barNode.addChildNode(collarNode)
        barNode.addChildNode(collarInnerNode)
        barNode.addChildNode(collarBadgeNode)
        myScene.scene?.rootNode.addChildNode(barNode)
    }

    func drawPlate(weight: Double) {
        let plateNode = SCNNode()
        let size = Float(plates.count - find(plates, weight)!)
        let plateHeight = CGFloat((size / 6 + 0.35) / 2 * 45)
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

        let weightString = weightFormatter.stringFromNumber(weight)!
        var fontSize = CGFloat(1 + plates.count - find(plates, weight)!)
        let textGeometry = SCNText(string: weightString, extrusionDepth: thickness)
        //textGeometry.containerFrame = CGRect(x: 0, y: 0, width:plateHeight, height:plateHeight * 0.75)
        textGeometry.font = UIFont (name: "Courier", size: fontSize)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.lightGrayColor()
        //BUG: textGeometry.alignmentMode = kCAAlignmentCenter

        let rotationOffset = Double(arc4random_uniform(59))
        for r in 1...3 {
            let textNode = SCNNode(geometry: textGeometry)
            let offset = Float(weightOffsetX) + Float(-1) * Float(thickness) / 2
            //textNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI_2))
            textNode.eulerAngles = SCNVector3(x: Float(DegreesToRadians(90)), y: Float(DegreesToRadians(rotationOffset + 360.0/3 * Double(r))), z: 0.0)
            textNode.position = SCNVector3(x: 0, y: offset, z: 0.0)
            // When SCNText.alignmentMode is fixed, don't do this
            textNode.pivot = SCNMatrix4MakeTranslation(Float(Double(fontSize) / 2.75 * Double(weightString.utf16Count)), Float(plateHeight)*0.75, 0)
            plateNode.addChildNode(textNode)
        }

        weightOffsetX -= Float(plateWidth/2 + 1)
        plateNode.addChildNode(innerNode)
        plateNode.addChildNode(outerNode)
        plateNode.addChildNode(connectorNode)
        platesNode.addChildNode(plateNode)
    }

    func drawLegend(plates:[Double]) {
        let nodes = legendNode.childNodes
        for node in nodes ?? [] {  node.removeFromParentNode() }
        var quantityPlates =  Dictionary<Double, Int>()
        for plate in plates {
            if (quantityPlates[plate] == nil) { quantityPlates[plate] = 0 }
            quantityPlates[plate]! += 1
        }
        var i = 0
        for (weight, quantity) in quantityPlates {
            var line:String = weightFormatter.stringFromNumber(weight)! + " x " + String(quantity)
            let textGeometry = SCNText(string: line, extrusionDepth: 0)
            //textGeometry.containerFrame = CGRect(x: 0, y: 0, width:plateHeight, height:plateHeight * 0.75)
            textGeometry.font = UIFont.systemFontOfSize(12)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.darkTextColor()

            let rotationOffset = Double(arc4random_uniform(59))
            let textNode = SCNNode(geometry: textGeometry)
            textNode.eulerAngles = SCNVector3(x: Float(DegreesToRadians(90)), y: Float(DegreesToRadians(-90)), z: 0.0)
            //textNode.position = SCNVector3(x: 0, y: offset, z: 0.0)
            // When SCNText.alignmentMode is fixed, don't do this
            textNode.pivot = SCNMatrix4MakeTranslation(100, -50 + Float(i) * 12, 0)
            //plateNode.addChildNode(textNode)
            legendNode.addChildNode(textNode)
            i++
        }

    }

    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }

    func clearPlates() {
        let nodes = platesNode.childNodes
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
        for (index, weight) in enumerate(platesNeeded) {
            drawPlate(weight)
        }
        drawLegend(platesNeeded)

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
