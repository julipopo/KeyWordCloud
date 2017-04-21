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
    
    var labels : [UIButton] = [], wayBools : [Bool] = [true], randoms_1to1 : [CGFloat] = [-1.0]
    var count = 0, difX: CGFloat = 0.0, difY: CGFloat = 0.0, kWidth: CGFloat = 0.0, kHeight : CGFloat = 0.0
    var scaleOffset: Double = 0.0, radius: Double = 0.0, randomRadius:Double = 0, min : Double = 500
    let speed:CGFloat = 0.025, scaleGap: CGFloat = 0.3, moyenneAlpha:CGFloat = 0.6
    var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kWidth = self.view.frame.width
        kHeight = self.view.frame.height
        radius = Double(kWidth/2 - 40)
        count = words.count
        scaleOffset = Double(kWidth)-10.0
        let spacingMinimun : Double = 70/147*radius
        let sizeForLabel = 80/147*radius
        
        self.view.bounds = CGRect(x: -kWidth/2, y: -kHeight/2, width: kWidth, height: kHeight)
        for i in 0..<count {
            let label = UIButton()
            //label.text = words[i]
            label.setTitle(words[i],for: .normal)
            label.setTitleColor(UIColor.black, for: .normal)
            label.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            label.frame = CGRect(x: -sizeForLabel/2, y: -sizeForLabel/2, width: sizeForLabel, height: sizeForLabel)
            if i != 0 {
                let randomAngle = Double(i)*2*M_PI/Double(count)
                var random_1to1:CGFloat = 0
                repeat { //re-set it randomly while it doesn't conform to the minimum spacing between labels
                    min = 2*radius
                    random_1to1 = CGFloat(Int(arc4random_uniform(201)) - 100)/100.0
                    randomRadius = radius*sqrt( Double(1 - random_1to1 * random_1to1))
                    let newX = CGFloat(cos(Double(randomAngle)) * randomRadius)
                    let newY = CGFloat(sin(Double(randomAngle)) * randomRadius)
                    for j in 0..<i{
                        let oldX = labels[j].center.x
                        let oldY = labels[j].center.y
                        let d1 = Double(sqrt((oldX-newX)*(oldX-newX) + (oldY-newY)*(oldY-newY)))
                        let oldRandom = randoms_1to1[j]
                        let d2 = Double(abs(oldRandom-random_1to1))*radius
                        let distance:Double = sqrt(d1*d1 + d2*d2)
                        if distance < min { min = distance}
                    }
                    print("\(i) : \(min)")
                } while min < spacingMinimun
                randoms_1to1.append(random_1to1)
                label.center = CGPoint(x: cos(Double(randomAngle)) * randomRadius , y: sin(Double(randomAngle)) * randomRadius)
                wayBools.append(random_1to1 < 0)
            }
            label.contentHorizontalAlignment = .center;
            label.contentVerticalAlignment = .center;
            label.titleLabel?.adjustsFontSizeToFitWidth = true
            labels.append(label)
            self.view.addSubview(label)
        }
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
        longGesture.minimumPressDuration = 0.3
        self.view.addGestureRecognizer(longGesture)
        _ = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(ViewController.anim), userInfo: nil, repeats: true)
    }
    
    func gestureAction(_ recognizer: UIGestureRecognizer){
        self.difX = recognizer.location(in: self.view).x
        self.difY = recognizer.location(in: self.view).y
    }
    
    func buttonAction(sender:UIButton!){
        print(sender.titleLabel?.text)
    }
    
    func anim(){
        for i in 0..<count {
            var newCenter = labels[i].center
            let distanceFromCenter = sqrt(Double(newCenter.x * newCenter.x + newCenter.y * newCenter.y))
            if distanceFromCenter >= radius {
                wayBools[i] = !wayBools[i]
                if wayBools[i] { self.view.bringSubview(toFront: labels[i])
                } else { self.view.sendSubview(toBack: labels[i]) }
            }
            let nearBorder = CGFloat(sqrt(abs(radius*radius-distanceFromCenter*distanceFromCenter))/radius)
            let brake = wayBools[i] ? nearBorder*speed : -nearBorder*speed
            newCenter.x += self.difX * brake
            newCenter.y += self.difY * brake
            let transformFactor = wayBools[i] ? scaleGap * abs(nearBorder) : -scaleGap * abs(nearBorder)
            labels[i].transform = CGAffineTransform(scaleX: CGFloat(1.0)+transformFactor, y: CGFloat(1)+transformFactor)
            let alphafactor = wayBools[i] ? (1-moyenneAlpha) * nearBorder : -(1-moyenneAlpha) * nearBorder
            labels[i].alpha = moyenneAlpha + alphafactor
            if !firstTime { labels[i].center = newCenter }
        }
        if firstTime { firstTime = false }
    }
}
