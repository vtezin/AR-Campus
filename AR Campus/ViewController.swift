//
//  ViewController.swift
//  AR Campus
//
//  Created by test on 22/05/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private var campusIsAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Enable plane detection
        configuration.planeDetection = [.horizontal]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard !campusIsAdded else { return }
        
        let campus = createCampus(planeAnchor: planeAnchor)
        node.addChildNode(campus)
        
        campusIsAdded = true
        
    }
    
}

extension ViewController {
    
    /// Creating campus scene with adding tree
    func createCampus(planeAnchor: ARPlaneAnchor) -> SCNNode {
        // Create a new scene
        let node = SCNScene(named: "art.scnassets/campus.scn")!.rootNode.clone()
        node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        
        let tree = getTreeNode()
        let treeGeometry = tree.geometry as! SCNCylinder
        
        tree.position = SCNVector3(0, treeGeometry.height/2, 0)
        tree.eulerAngles.x = .pi
        
        // Adding tree on the floor
        node.addChildNode(tree)
        
        return node
    }
    
    /// Placing the campus
    func placeCampusByCode() {
        
        let floor = getFloorNode()
        floor.position = SCNVector3(0, -1, -2)
        
        let tree = getTreeNode()
        tree.position = SCNVector3(0, 0, 0.25)
        
        // Adding tree on the floor
        floor.addChildNode(tree)
        
        // Adding floor to the campus
        let campus = SCNNode()
        campus.addChildNode(floor)
        
        // Adding campus to the scene
        sceneView.scene.rootNode.addChildNode(campus)
        
    }
    
    /// Getting floor
    ///
    /// - Returns: SCNNode of the floor
    func getFloorNode() -> SCNNode {
        
        let plane = SCNPlane(width: 3, height: 3)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/textureGrass.jpeg")
        
        let material = plane.materials.first
        let width = plane.width
        let height = plane.height
        
        material!.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material!.diffuse.wrapS = SCNWrapMode.repeat
        material!.diffuse.wrapT = SCNWrapMode.repeat
        
        let grassNode = SCNNode(geometry: plane)
        grassNode.eulerAngles.x = -.pi / 2
        
        return grassNode
        
    }
    
    /// Getting a tree
    ///
    /// - Returns: SCNNode of the tree
    func getTreeNode() -> SCNNode {
        
        // making stall
        let stallHeight:CGFloat = 1
        let stallRadius:CGFloat = stallHeight/20
        
        let cylinder = SCNCylinder(radius: stallRadius, height: stallHeight)
        
        let materialOfStall = SCNMaterial()
        materialOfStall.diffuse.contents = UIImage(named: "art.scnassets/textureBark.jpg")
        
        cylinder.materials = [materialOfStall]
        
        let stallNode = SCNNode()
        stallNode.geometry = cylinder
        stallNode.eulerAngles.x = -.pi / 2
        
        // making crown
        let sphere = SCNSphere(radius: cylinder.radius * 5)

        let materialOfCrown = SCNMaterial()
        materialOfCrown.diffuse.contents = UIImage(named: "art.scnassets/textureFoliage.jpg")

        sphere.materials = [materialOfCrown]
        
        let crownNode = SCNNode(geometry: sphere)
        crownNode.position.y = -Float(cylinder.height/2) // moving crown to the top of the stall
        
        // adding crown on stall
        stallNode.addChildNode(crownNode)
        
        return stallNode
    }
}
