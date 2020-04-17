//
//  CircleRatingView.swift
//  CircleRatingView
//
//  Created by KISHAN_RAJA on 26/08/19.
//  Copyright © 2019 KISHAN_RAJA. All rights reserved.
//

import UIKit

public class CircleRatingView: UIView {
    
    //MRAK: Open variable
    public var emptyImage: UIImage = #imageLiteral(resourceName: "Empty_start")
    public var fullImage: UIImage = #imageLiteral(resourceName: "Full_start")
    public var duration: Double = 0.5
    public var defaultRate: Int = 1
    public var lineColor: UIColor = .yellow
    public var rate: Int {
        return self.arrButton.filter({$0.isSelected}).count
    }
    public var isLineView: Bool = false
    public var isEditable: Bool = true
    public var iconSize: CGSize = CGSize(width: 50, height: 50)
    
    //MRAK: Non Open variable
    private var arrButton: [UIButton] = []
    private var arrShapeLayer: [CAShapeLayer] = []
    private var arrBazierPath: [UIBezierPath] = []
    private var angle: CGFloat = 180 - 30
    private var numberOfStar: Int = 5
    
    //MARK: Life cycle
    override public func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = .purple
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        //for circuler view
        let radius = (self.frame.size.height / 2)
        
        //for line view
        let distance = self.frame.size.width / CGFloat(self.numberOfStar)
        var xPosition: CGFloat = (distance / 2)
        
        for i in 0..<numberOfStar {
            let btnStar = UIButton(frame: CGRect(x: 0, y: 0, width: iconSize.width, height: iconSize.height))
            btnStar.isUserInteractionEnabled = isEditable
            btnStar.tag = i
            btnStar.setImage(emptyImage, for: .normal)
            btnStar.setImage(fullImage, for: .selected)
            
            if isLineView {
                //create line bezier path
                let path = UIBezierPath()
                path.move(to: CGPoint(x: xPosition, y: self.frame.size.height / 2))
                path.addLine(to: CGPoint(x: (xPosition + distance), y: self.frame.size.height / 2))
                self.arrBazierPath.append(path)
                
                xPosition += distance
                
            } else {
                //create circuler bezier path
                let path = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height/2) - iconSize.height / 2),
                                        radius: radius,
                                        startAngle: CGFloat(angle).toRadians(),
                                        endAngle: CGFloat(angle - 30).toRadians(),
                                        clockwise: false)
                self.arrBazierPath.append(path)
                self.angle -= 30
            }
            
            //create shape layer
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = self.arrBazierPath[i].cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.lineWidth = iconSize.height - 11
            self.arrShapeLayer.append(shapeLayer)
            
            btnStar.center = self.arrBazierPath[i].firstPoint() ?? .zero
            btnStar.frame = btnStar.frame.offsetBy(dx: 0, dy: 1.5)
            self.arrButton.append(btnStar)
            self.addSubview(btnStar)
            
            //add action of button
            btnStar.addAction(for: .touchUpInside) {
                self.fillStar(btnIndex: btnStar.tag)
            }
        }
        
        self.fillStar(btnIndex: defaultRate - 1)
    }
    
    //MARK: Custom method
    //Fill start
    private func fillStar(btnIndex : Int) {
        var timeOffset: Double = 0
        
        for (index, btn) in self.arrButton.enumerated() {
            
            if btn.tag <= btnIndex {//btnStar.tag {
                if btn.isSelected {
                    
                } else {
                    self.arrButton[index].isSelected = true
                    if index != 0 {
                        
                        self.layer.insertSublayer(self.arrShapeLayer[index - 1], at: 0)
                        
                        //add animation
                        let animation = CABasicAnimation(keyPath: "strokeEnd")
                        animation.isRemovedOnCompletion = true
                        animation.beginTime = CACurrentMediaTime() + timeOffset
                        animation.fromValue = 0
                        animation.duration = self.duration
                        animation.fillMode = CAMediaTimingFillMode.backwards
                        self.arrShapeLayer[index - 1].add(animation, forKey: "layerAnimation")
                        timeOffset += animation.duration
                    }
                }
                
            } else {
                if index != 0 {
                    self.arrShapeLayer[index - 1].removeFromSuperlayer()
                }
                
                self.arrButton[index].isSelected = false
            }
        }
    }
}

//MARK: Extension
extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}

extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback as CGPathApplierFunction)
    }
}

// Finds the first point in a path
extension UIBezierPath {
    func firstPoint() -> CGPoint? {
        var firstPoint: CGPoint? = nil
        
        self.cgPath.forEach { element in
            // Just want the first one, but we have to look at everything
            guard firstPoint == nil else { return }
            assert(element.type == .moveToPoint, "Expected the first point to be a move")
            firstPoint = element.points.pointee
        }
        return firstPoint
    }
}

var AssociatedObjectHandle: UInt8 = 0

class ClosureSleeve {
    let closure: () -> ()
    
    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, &AssociatedObjectHandle, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}
