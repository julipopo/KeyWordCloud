//
//  ViewController.swift
//  t411Anim
//
//  Created by Julien Simmer  on 16/04/2017.
//  Copyright © 2017 Julien Simmer . All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    var words = ["Swift", "UIView", "Layer", "Bezier", "UIKit", "Path", "Debug", "CAShape", "Darwin", "Anim", "Stack", "RxSwift", "Github", "Xcode", "Frame", "Bounds", "Core", "Cocoa", "Native", "GLKit", "Graphics", "UX/UI", "OpenGL", "Layout", "Spring", "KeyFrame", "Mask", "Stroke", "3D", "Obj-C", "Design", "iOS SDK"]
    
    var words2 = ["Peinture", "Art", "Design", "Brode", "Fil", "Color", "Motif", "Forme", "Star", "Seins", "Sun", "Sea", "Ocean", "Boat", "Friends", "Family", "Music", "Party", "Shot", "Dance", "Festival", "Breizh", "UB40", "Caen", "Bédée", "Marcel", "Zoé", "Eliot", "Chat", "Lapin", "Rose", "Cocon"]
    
    var labels : [UIButton] = [], wayBools : [Bool] = [true], randoms_1to1 : [CGFloat] = [-1.0]
    var count = 0, difX: CGFloat = 0.0, difY: CGFloat = 0.0, kWidth: CGFloat = 0.0, kHeight : CGFloat = 0.0
    var scaleOffset: Double = 0.0, radius: Double = 0.0, randomRadius:Double = 0, min : Double = 500
    
    var labels2 : [UIButton] = [], wayBools2 : [Bool] = [true], randoms_1to12 : [CGFloat] = [-1.0]
    
    let speed:CGFloat = 0.025, scaleGap: CGFloat = 0.3, moyenneAlpha:CGFloat = 0.6, maxCountToRestarTheDraw: Int = 40
    var firstTime = true, firstTime2 = true, firstCloud = true
    
    var timer : Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kWidth = self.view.frame.width
        kHeight = self.view.frame.height
        radius = Double(kWidth/2 - 40)
        count = words.count
        scaleOffset = Double(kWidth)-10.0
        
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(ViewController.anim), userInfo: nil, repeats: true)
        
        self.constructPoint(inView: self.view, firstOne:true)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
        longGesture.minimumPressDuration = 0.1
        self.view.addGestureRecognizer(longGesture)
        
    }
    
    func gestureAction(_ recognizer: UIGestureRecognizer){
        if recognizer.state == .ended {
            let vX = recognizer.location(in: self.view).x - self.difX
            let vY = recognizer.location(in: self.view).y - self.difY
            print("\n")
            print("\(recognizer.location(in: self.view).x)-\(recognizer.location(in: self.view).y)")
            print("\(vX)-\(vY)")
        }
        self.difX = recognizer.location(in: self.view).x
        self.difY = recognizer.location(in: self.view).y
        
    }
    
    func buttonAction(sender:UIButton!){
        print(sender.titleLabel?.text ?? "No title for button tapped")
        self.view.isUserInteractionEnabled = false;
        self.timer.invalidate()
        
        MappingWebService.getWordsMapping(word: (sender.titleLabel?.text!)!, success: { array in
            self.words = array as! [String]
            self.count = self.words.count
            
            
            DispatchQueue.main.async {
                self.splitCloud()
                self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(ViewController.anim), userInfo: nil, repeats: true)
                self.view.isUserInteractionEnabled = true;
            }
            
            
        }, failure: { error in
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(ViewController.anim), userInfo: nil, repeats: true)
                self.view.isUserInteractionEnabled = true;
            }
        })
        
    }
    
    func constructPoint(inView: UIView, firstOne:Bool){
        self.firstCloud = firstOne
        let spacingMinimun : Double = 70/147*radius
        let sizeForLabel = 80/147*radius
        
        inView.bounds = CGRect(x: -kWidth/2, y: -kHeight/2, width: kWidth, height: kHeight)
        var cgpoints : [CGPoint] = [CGPoint(x : 0, y: 0)]
        var restart = false
        repeat {
            if firstOne {for view in self.labels{view.removeFromSuperview()}}
            else {for view in self.labels2{view.removeFromSuperview()}}
            firstOne ? labels.removeAll() : labels2.removeAll()
            for i in 0..<count {
                let label = UIButton()
                
                label.frame = CGRect(x: -sizeForLabel/2, y: -sizeForLabel/2, width: sizeForLabel, height: sizeForLabel)
                //Place the button
                if i != 0 {
                    let randomAngle = Double(i)*2*M_PI/Double(count)
                    var random_1to1:CGFloat = 0
                    var countToRestart = 0
                    repeat { //re-set it randomly while it doesn't conform to the minimum spacing between labels
                        min = 2*radius
                        random_1to1 = CGFloat(Int(arc4random_uniform(201)) - 100)/100.0
                        randomRadius = radius*sqrt( Double(1 - random_1to1 * random_1to1))
                        let newX = CGFloat(cos(Double(randomAngle)) * randomRadius)
                        let newY = CGFloat(sin(Double(randomAngle)) * randomRadius)
                        for j in 0..<i{
                            let oldX = cgpoints[j].x
                            let oldY = cgpoints[j].y
                            let d1 = Double(sqrt((oldX-newX)*(oldX-newX) + (oldY-newY)*(oldY-newY)))
                            let oldRandom = firstOne ? randoms_1to1[j] : randoms_1to12[j]
                            let d2 = Double(abs(oldRandom-random_1to1))*radius
                            let distance:Double = sqrt(d1*d1 + d2*d2)
                            if distance < min { min = distance}
                        }
                        countToRestart += 1
                        restart = countToRestart > maxCountToRestarTheDraw
                        if restart {print("ONCE")}
                    } while min < spacingMinimun && !restart
                    firstOne ? randoms_1to1.append(random_1to1) : randoms_1to12.append(random_1to1)
                    cgpoints.append(CGPoint(x: cos(Double(randomAngle)) * randomRadius , y: sin(Double(randomAngle)) * randomRadius))
                    firstOne ? wayBools.append(random_1to1 < 0) : wayBools2.append(random_1to1 < 0)
                }
                
                //Construct the button title and target
                label.setTitle(words[i],for: .normal) //firstOne ? words[i] : words2[i],for: .normal)
                label.setTitleColor(UIColor.black, for: .normal)
                label.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                label.contentHorizontalAlignment = .center;
                label.contentVerticalAlignment = .center;
                label.titleLabel?.adjustsFontSizeToFitWidth = true
                
                firstOne ? labels.append(label) : labels2.append(label)
                inView.addSubview(label)
            }
        } while restart
        UIView.animate(withDuration: 1, animations: {
            for i in 0..<self.count {
                if firstOne {
                    self.labels[i].center = cgpoints[i]
                } else {
                    self.labels2[i].center = cgpoints[i]
                }
            }
        }, completion: { (finished) in
            print("end ")
        })
    }
    
    func splitCloud(){
        var cgpoints : [CGPoint] = []
        for i in 0..<count {
            let oldX = firstCloud ? labels[i].center.x : labels2[i].center.x
            let oldY = firstCloud ? labels[i].center.y : labels2[i].center.y
            let oldAngle = oldY < 0 ? acos(oldX/CGFloat(radius)) + CGFloat(M_PI_2) : -acos(oldX/CGFloat(radius)) + CGFloat(M_PI_2)
            let newX : CGFloat = cos(oldAngle)*(CGFloat(radius)+kHeight/2)
            let newY : CGFloat = sin(oldAngle)*(CGFloat(radius)+kWidth/2)
            cgpoints.append(CGPoint(x: newY, y: newX))
        }
        self.constructPoint(inView: self.view, firstOne:!firstCloud)
        UIView.animate(withDuration: 2, animations: {
            for i in 0..<self.count {
                if !self.firstCloud {
                    self.labels[i].center = cgpoints[i]
                    
                } else {
                    self.labels2[i].center = cgpoints[i]
                    
                }
            }
        }, completion: { (finished) in
            if !self.firstCloud {
                self.labels = []
                self.wayBools = [true]
                self.randoms_1to1 = [-1.0]
            } else {
                self.labels2 = []
                self.wayBools2 = [true]
                self.randoms_1to12 = [-1.0]
            }
        })
    }
    
    func anim(){
        for i in 0..<count {
            var newCenter = firstCloud ? labels[i].center : labels2[i].center
            let distanceFromCenter = sqrt(Double(newCenter.x * newCenter.x + newCenter.y * newCenter.y))
            if distanceFromCenter >= radius{
                if(firstCloud){
                    wayBools[i] = !wayBools[i]
                    if wayBools[i] { self.view.bringSubview(toFront: labels[i])
                    } else { self.view.sendSubview(toBack: labels[i]) }
                } else {
                    wayBools2[i] = !wayBools2[i]
                    if wayBools2[i] { self.view.bringSubview(toFront: labels2[i])
                    } else { self.view.sendSubview(toBack: labels2[i]) }
                }
            }
            let nearBorder = CGFloat(sqrt(abs(radius*radius-distanceFromCenter*distanceFromCenter))/radius)
            var brake : CGFloat = 0
            if firstCloud {
                brake = (wayBools[i] ? nearBorder*speed : -nearBorder*speed)
            } else {
                brake = (wayBools2[i] ? nearBorder*speed : -nearBorder*speed)
            }
            newCenter.x += self.difX * brake
            newCenter.y += self.difY * brake
            if firstCloud {
                let transformFactor = wayBools[i] ? scaleGap * abs(nearBorder) : -scaleGap * abs(nearBorder)
                labels[i].transform = CGAffineTransform(scaleX: CGFloat(1.0)+transformFactor, y: CGFloat(1)+transformFactor)
                let alphafactor = wayBools[i] ? (1-moyenneAlpha) * nearBorder : -(1-moyenneAlpha) * nearBorder
                labels[i].alpha = moyenneAlpha + alphafactor
                if !firstTime {
                    self.labels[i].center = newCenter
                }
            } else {
                let transformFactor = wayBools2[i] ? scaleGap * abs(nearBorder) : -scaleGap * abs(nearBorder)
                labels2[i].transform = CGAffineTransform(scaleX: CGFloat(1.0)+transformFactor, y: CGFloat(1)+transformFactor)
                let alphafactor = wayBools2[i] ? (1-moyenneAlpha) * nearBorder : -(1-moyenneAlpha) * nearBorder
                labels2[i].alpha = moyenneAlpha + alphafactor
                if !firstTime2 {
                    self.labels2[i].center = newCenter
                }
            }
        }
        if firstCloud{ if firstTime { firstTime = false }}
        if !firstCloud{ if firstTime2 { firstTime2 = false }}
    }
}
