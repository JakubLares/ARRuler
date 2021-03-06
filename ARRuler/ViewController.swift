//
//  ViewController.swift
//  ARRuler
//
//  Created by Jakub Lares on 05.09.18.
//  Copyright © 2018 Jakub Lares. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    var dotNodes = [SCNNode]()
    var textNode = SCNNode()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(ARWorldTrackingConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    //MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            restartMeasure()
        }
        guard let touchLocation = touches.first?.location(in: sceneView),
        let hitResult = sceneView.hitTest(touchLocation, types: .featurePoint).first else { return }
        addDot(at: hitResult)
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        restartMeasure()
    }

    //MARK: - Private methods

    private func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]

        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }

    private func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]

        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2))

        updateText("\(String(format: "%.2f", distance * 100))cm", atPosition: end.position)
    }

    private func updateText(_ text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode.geometry = textGeometry
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }

    private func restartMeasure() {
        dotNodes.forEach {
            $0.removeFromParentNode()
        }
        dotNodes.removeAll()
        textNode.removeFromParentNode()
    }
}
