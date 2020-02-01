//
//  ViewController.swift
//  Final Project
//
//  Created by Jeff Chien on 10/31/19.
//  Copyright © 2019 Jeff Chien. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    enum CardsType: String {
        case RedPaper = "RedPaper"
        case RedScissors = "RedScissors"
        case RedRock = "RedRock"
        case BluePaper = "BluePaper"
        case BlueScissors = "BlueScissors"
        case BlueRock = "BlueRock"
    }
    
    @IBOutlet var sceneView: ARSCNView!
    
    var idle = true
    var redPaperNode: SCNNode?
    var redScissorsNode: SCNNode?
    var redRockNode: SCNNode?
    var bluePaperNode: SCNNode?
    var blueScissorsNode: SCNNode?
    var blueRockNode: SCNNode?
    
    let keyPaperTaunt = "PaperTaunt"
    let keyPaperAttack = "PaperAttack"
    let keyPaperDying = "PaperDying"
    let keyScissorsTaunt = "ScissorsTaunt"
    let keyScissorsAttack = "ScissorsAttack"
    let keyScissorsDying = "ScissorsDying"
    let keyRockTaunt = "RockTaunt"
    let keyRockAttack = "RockAttack"
    let keyRockDying = "RockDying"
    
    var nodeDict = [String: SCNNode]()
    var animationDict = [String: CAAnimation]()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        initNode()
        loadAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        
        if let trackImages = ARReferenceImage.referenceImages(inGroupNamed: "Cards", bundle: Bundle.main) {
            configuration.trackingImages = trackImages
            configuration.maximumNumberOfTrackedImages = 3
        }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func initNode() {
        redPaperNode = SCNScene(named: "art.scnassets/Paper/Idle.scn")?.rootNode
        redScissorsNode = SCNScene(named: "art.scnassets/Scissors/Idle.scn")?.rootNode
        redRockNode = SCNScene(named: "art.scnassets/Rock/Idle.scn")?.rootNode
        bluePaperNode = SCNScene(named: "art.scnassets/Paper/Idle.scn")?.rootNode
        blueScissorsNode = SCNScene(named: "art.scnassets/Scissors/Idle.scn")?.rootNode
        blueRockNode = SCNScene(named: "art.scnassets/Rock/Idle.scn")?.rootNode
    }
    
    private func loadAnimations() {
        loadAnimation(withKey: keyPaperTaunt,
                      scenePath: "art.scnassets/Paper/Taunt.scn")
        loadAnimation(withKey: keyPaperAttack,
                      scenePath: "art.scnassets/Paper/Attack.scn")
        loadAnimation(withKey: keyPaperDying,
                      scenePath: "art.scnassets/Paper/Dying.scn")
        loadAnimation(withKey: keyScissorsTaunt,
                      scenePath: "art.scnassets/Scissors/Taunt.scn")
        loadAnimation(withKey: keyScissorsAttack,
                      scenePath: "art.scnassets/Scissors/Attack.scn")
        loadAnimation(withKey: keyScissorsDying,
                      scenePath: "art.scnassets/Scissors/Dying.scn")
        loadAnimation(withKey: keyRockTaunt,
                      scenePath: "art.scnassets/Rock/Taunt.scn")
        loadAnimation(withKey: keyRockAttack,
                      scenePath: "art.scnassets/Rock/Attack.scn")
        loadAnimation(withKey: keyRockDying,
                      scenePath: "art.scnassets/Rock/Dying.scn")
    }

    private func loadAnimation(withKey key: String, scenePath path: String) {
        
        guard let player = playerFromScenePath(path: path) else { return }
        
        let animationObject = CAAnimation(scnAnimation: player.animation)
        animationObject.repeatCount = .greatestFiniteMagnitude
        // To create smooth transitions between animations
        animationObject.fadeInDuration = CGFloat(1)
        animationObject.fadeOutDuration = CGFloat(0.5)
                                  
        animationDict[key] = animationObject
    }
    
    private func playerFromScenePath(path: String) -> SCNAnimationPlayer? {
        let scene = SCNScene(named: path)
        var animationPlayer: SCNAnimationPlayer?
        scene?.rootNode.enumerateChildNodes { (child, stop) in
            if let animKey = child.animationKeys.first {
                animationPlayer = child.animationPlayer(forKey: animKey)
                stop.pointee = true
            }
        }
        
        return animationPlayer
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            node.addChildNode(planeNode)
            
            var characterNode: SCNNode?
            switch imageAnchor.referenceImage.name {
                case CardsType.RedPaper.rawValue:
                    characterNode = redPaperNode
                case CardsType.RedScissors.rawValue:
                    characterNode = redScissorsNode
                case CardsType.RedRock.rawValue:
                    characterNode = redRockNode
                case CardsType.BluePaper.rawValue:
                    characterNode = bluePaperNode
                case CardsType.BlueScissors.rawValue:
                    characterNode = blueScissorsNode
                case CardsType.BlueRock.rawValue:
                    characterNode = blueRockNode
                default:
                    break
            }
            
            guard characterNode != nil else { return nil }
            node.addChildNode(characterNode!)
            node.name = imageAnchor.referenceImage.name
        }

        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            switch imageAnchor.referenceImage.name {
                case CardsType.RedPaper.rawValue:
                    nodeDict[CardsType.RedPaper.rawValue] = node
                case CardsType.RedScissors.rawValue:
                    nodeDict[CardsType.RedScissors.rawValue] = node
                case CardsType.RedRock.rawValue:
                    nodeDict[CardsType.RedRock.rawValue] = node
                case CardsType.BluePaper.rawValue:
                    nodeDict[CardsType.BluePaper.rawValue] = node
                case CardsType.BlueScissors.rawValue:
                    nodeDict[CardsType.BlueScissors.rawValue] = node
                case CardsType.BlueRock.rawValue:
                    nodeDict[CardsType.BlueRock.rawValue] = node
                default:
                    break
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
                                
        var visibleNodes = [SCNNode]()
        if let pointOfView = sceneView.pointOfView {
            for (_, value) in nodeDict {
                if (sceneView.isNode(value, insideFrustumOf: pointOfView)) {
                    visibleNodes.append(value)
                }
            }
        }
            
        print(visibleNodes.count)
        if (visibleNodes.count == 2) {
            
            let first = SCNVector3ToGLKVector3(visibleNodes[0].position)
            let second = SCNVector3ToGLKVector3(visibleNodes[1].position)
            let distance = GLKVector3Distance(first, second)
//            print(distance)
            var firstKey = ""
            var secondKey = ""
            
            if (visibleNodes[0].name == CardsType.BluePaper.rawValue) {
                if (visibleNodes[1].name == CardsType.RedPaper.rawValue) {
                    firstKey = keyPaperTaunt
                    secondKey = keyPaperTaunt
                }
                else if (visibleNodes[1].name == CardsType.RedScissors.rawValue) {
                    firstKey = keyPaperDying
                    secondKey = keyScissorsAttack
                }
                else if (visibleNodes[1].name == CardsType.RedRock.rawValue) {
                    firstKey = keyPaperAttack
                    secondKey = keyRockDying
                }
            }
            else if (visibleNodes[0].name == CardsType.BlueScissors.rawValue) {
                if (visibleNodes[1].name == CardsType.RedPaper.rawValue) {
                    firstKey = keyScissorsAttack
                    secondKey = keyPaperDying
                }
                else if (visibleNodes[1].name == CardsType.RedScissors.rawValue) {
                    firstKey = keyScissorsTaunt
                    secondKey = keyScissorsTaunt
                }
                else if (visibleNodes[1].name == CardsType.RedRock.rawValue) {
                    firstKey = keyScissorsDying
                    secondKey = keyRockAttack
                }
            }
            else if (visibleNodes[0].name == CardsType.BlueRock.rawValue) {
                if (visibleNodes[1].name == CardsType.RedPaper.rawValue) {
                    firstKey = keyRockDying
                    secondKey = keyPaperAttack
                }
                else if (visibleNodes[1].name == CardsType.RedScissors.rawValue) {
                    firstKey = keyRockAttack
                    secondKey = keyScissorsDying
                }
                else if (visibleNodes[1].name == CardsType.RedRock.rawValue) {
                    firstKey = keyRockTaunt
                    secondKey = keyRockTaunt
                }
            }
            else if (visibleNodes[0].name == CardsType.RedPaper.rawValue) {
                if (visibleNodes[1].name == CardsType.BluePaper.rawValue) {
                    firstKey = keyPaperTaunt
                    secondKey = keyPaperTaunt
                }
                else if (visibleNodes[1].name == CardsType.BlueScissors.rawValue) {
                    firstKey = keyPaperDying
                    secondKey = keyScissorsAttack
                }
                else if (visibleNodes[1].name == CardsType.BlueRock.rawValue) {
                    firstKey = keyPaperAttack
                    secondKey = keyRockDying
                }
            }
            else if (visibleNodes[0].name == CardsType.RedScissors.rawValue) {
                if (visibleNodes[1].name == CardsType.BluePaper.rawValue) {
                    firstKey = keyScissorsAttack
                    secondKey = keyPaperDying
                }
                else if (visibleNodes[1].name == CardsType.BlueScissors.rawValue) {
                    firstKey = keyScissorsTaunt
                    secondKey = keyScissorsTaunt
                }
                else if (visibleNodes[1].name == CardsType.BlueRock.rawValue) {
                    firstKey = keyScissorsDying
                    secondKey = keyRockAttack
                }
            }
            else if (visibleNodes[0].name == CardsType.RedRock.rawValue) {
                if (visibleNodes[1].name == CardsType.BluePaper.rawValue) {
                    firstKey = keyRockDying
                    secondKey = keyPaperAttack
                }
                else if (visibleNodes[1].name == CardsType.BlueScissors.rawValue) {
                    firstKey = keyRockAttack
                    secondKey = keyScissorsDying
                }
                else if (visibleNodes[1].name == CardsType.BlueRock.rawValue) {
                    firstKey = keyRockTaunt
                    secondKey = keyRockTaunt
                }
            }
            
            if distance < 2.0 {
                guard let firstAnimation = animationDict[firstKey],
                    let secondAnimation = animationDict[secondKey] else {
                    return
                }
                if (idle) {
                    visibleNodes[0].addAnimation(firstAnimation, forKey: firstKey)
                    visibleNodes[1].addAnimation(secondAnimation, forKey: secondKey)
                    idle = false
                }
            }
            else {
                if (!idle) {
                    visibleNodes[0].removeAnimation(forKey: firstKey, blendOutDuration: CGFloat(0.5))
                    visibleNodes[1].removeAnimation(forKey: secondKey,  blendOutDuration: CGFloat(0.5))
                }
                idle = true
            }
        }
    }
}

