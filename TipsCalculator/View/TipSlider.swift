//
//  TipSlider.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/5/17.
//
//

import UIKit

public extension UIColor {
    public convenience init(rgb: (r: CGFloat, g: CGFloat, b: CGFloat)) {
        self.init(red: rgb.r/255, green: rgb.g/255, blue: rgb.b/255, alpha: 1.0)
    }
}

@objc protocol TipSliderDelegate: class {
    func tipSlider(_ slider: TipSlider, value changedTo: Float)
}

@IBDesignable
class TipSlider: UIControl {
    
    @IBInspectable
    var fraction: CGFloat = 0.0 {
        didSet {
            self.slider.value = Float(fraction)
            self.valueChanged(sender: self.slider)
        }
    }
    
    @IBInspectable
    var minimum: CGFloat = 0.0 {
        didSet {
            slider.minimumValue = Float(minimum)
            slider.setNeedsDisplay(slider.frame)
        }
    }
    
    @IBInspectable
    var maximum: CGFloat = 1.0 {
        didSet {
            slider.maximumValue = Float(maximum)
            slider.setNeedsDisplay(slider.frame)
        }
    }
    
    @IBInspectable
    var fillColor: UIColor = UIColor.white {
        didSet {
            slider.tintColor = fillColor
        }
    }
    
    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
    
    let singleCoinImage = UIImage(named: "single_coin")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    let doubleCoinImage = UIImage(named: "double_coin")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    let tripleCoinImage = UIImage(named: "triple_coins")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    var slider: UISlider!
    
    let arrowShape = CAShapeLayer()
    
    var displaylink: CADisplayLink? // for animation
    
    let animColors: [UIColor] = [
        UIColor(rgb: (255, 255, 153)),
        UIColor(rgb: (255, 204, 204)),
        UIColor(rgb: (153, 102, 153)),
        UIColor(rgb: (255, 102, 102)),
        UIColor(rgb: (255, 255, 102)),
        UIColor(rgb: (244, 67, 54)),
        UIColor(rgb: (102, 102, 102)),
        UIColor(rgb: (204, 204, 0)),
        UIColor(rgb: (102, 102, 102)),
        UIColor(rgb: (153, 153, 51))
    ]
    
    weak var delegate: TipSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        slider = UISlider(frame: CGRect.zero)
        slider.clipsToBounds = true
        slider.addTarget(self, action: #selector(self.valueChanged(sender:)), for: UIControlEvents.valueChanged)
        addSubview(slider)
        addSubview(arrowLabelView)
    }
    
    deinit {
        slider = nil
        label.removeFromSuperview()
        arrowLabelView.removeFromSuperview()
    }
    
    // MARK: adjust the position on x-axis for the arrowLabelView
    fileprivate func deltaXForArrowLabelView(sliderValue curValue: Float) -> Float {
        
        if curValue == 0 {
            return curValue + 0.035
        } else if curValue == 1 {
            return curValue - 0.035
        }
        
        return curValue
    }
    
    override func layoutSubviews() {

        slider.frame = CGRect(x: 0, y: arrowLabelView.bounds.height, width: self.bounds.width, height: self.bounds.height/2)
        
        slider.maximumTrackTintColor = UIColor.red

        let curX = deltaXForArrowLabelView(sliderValue: slider.value)
        arrowLabelView.center = CGPoint(x: CGFloat(curX) * self.slider.bounds.size.width, y: self.slider.bounds.size.height/2.0)
    }
    
    @objc func valueChanged(sender: UISlider) {
        
        let curValue = self.slider.value
        var curX = curValue
        let text = curValue > 0 ? "\(Double(curValue * 100).roundTo(places: 1))%" : "Tips?"
        self.label.text = text // update label
        
        switch curValue {

        case 0..<0.2:
            slider.setThumbImage(singleCoinImage, for: [.normal])
            slider.setThumbImage(singleCoinImage, for: [.highlighted])
            curX = deltaXForArrowLabelView(sliderValue: curValue)
            stopAnimation()
            
        case 0.2..<0.5:
            slider.setThumbImage(doubleCoinImage, for: .normal)
            slider.setThumbImage(doubleCoinImage, for: .highlighted)
            stopAnimation()
            
        case 0.5..<1.1:
            slider.setThumbImage(tripleCoinImage, for: [.normal])
            slider.setThumbImage(tripleCoinImage, for: [.highlighted])
            curX = deltaXForArrowLabelView(sliderValue: curValue)
            startAnimation()
            
        default:
            curX = curValue
            stopAnimation()
        }
        arrowLabelView.center = CGPoint(x: CGFloat(curX) * self.slider.bounds.size.width, y: self.slider.bounds.size.height/2.0)
        
        delegate?.tipSlider(self, value: curValue) // notify delegate of the changed value
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let textLabel = UILabel()
        textLabel.text = "TipSlider View!"
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 20)
        self.addSubview(textLabel)
        textLabel.frame = CGRect(x: 0, y: 0, width: (self.superview?.bounds.width)!, height: 40)
        
    }
    
    fileprivate func stopAnimation() {
        arrowShape.removeAllAnimations()
        displaylink?.remove(from: RunLoop.current, forMode: .commonModes)
        displaylink?.invalidate()
        displaylink = nil
        arrowShape.fillColor = self.fillColor.cgColor
        arrowShape.strokeColor = self.tintColor.cgColor
    }
    
    // MARK: add animation when slider goes beyong 50% as a warning
    fileprivate func startAnimation() {
        self.arrowShape.removeAllAnimations()
        
        arrowShape.fillColor = UIColor.yellow.withAlphaComponent(0.8).cgColor
        
        let bgColorAnimation: CAAnimation = { [weak self]  in
            let animation = CABasicAnimation(keyPath: "backgroundColor")
            animation.delegate = self
            //            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.fromValue = self?.arrowShape.fillColor
            animation.toValue = UIColor.red.withAlphaComponent(0.7).cgColor
            animation.duration = 1.0
            return animation
            }()
        
        let xScaleAnimation = { Void -> CAAnimation in
            let animation = CABasicAnimation(keyPath: "transform.scale.x")
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.fromValue = NSNumber(value: 1 as Float)
            animation.toValue = NSNumber(value: 0.9 as Float)
            animation.duration = 1.0
            return animation
        }()
        
        let group = CAAnimationGroup()
        group.delegate = self
        group.animations = [xScaleAnimation, bgColorAnimation]
        group.repeatCount = HUGE
        group.duration = 1.0
        
        arrowShape.add(group, forKey: "ring_animation")
        
        startFlash()
    }
    
    fileprivate func startFlash() {
        displaylink = CADisplayLink(target: self, selector: #selector(flashAction))
        if #available(iOS 10.0, *) {
            displaylink?.preferredFramesPerSecond = 6
        }else {
            displaylink?.frameInterval = 10
        }
        displaylink?.add(to: .current, forMode: .commonModes)
    }
    
    @objc fileprivate func flashAction() {
        arrowShape.strokeColor = animColors[Int(arc4random())%animColors.count].cgColor
    }
    
    lazy var label: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .black
        lbl.backgroundColor = .clear
        lbl.textAlignment = .center
        
        return lbl
    }()
    
    lazy var arrowLabelView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        let arrowWidth : CGFloat = 8
        let arrowHeight : CGFloat = 10
        let radius: CGFloat = 6.0
        let arrowPoint = CGPoint(x: view.bounds.width/2.0, y: view.bounds.maxY)
        
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        path.move(to: CGPoint(x: arrowPoint.x - arrowWidth, y: view.bounds.size.height - arrowHeight))
        path.addLine(to: CGPoint(x: arrowPoint.x, y: view.bounds.size.height))
        path.addLine(to: CGPoint(x: arrowPoint.x + arrowWidth, y: view.bounds.size.height - arrowHeight))
        path.addLine(to: CGPoint(x: view.bounds.size.width - radius, y: view.bounds.size.height - arrowHeight))
        path.addArc(withCenter: CGPoint(x: view.bounds.size.width - radius, y: view.bounds.size.height - arrowHeight - radius),
                    radius: radius,
                    startAngle: CGFloat(M_PI_2),
                    endAngle: 0,
                    clockwise: false)
        path.addLine(to: CGPoint(x: view.bounds.size.width, y: radius))
        path.addArc(withCenter: CGPoint(x: view.bounds.size.width - radius, y: radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat(M_PI_2*3),
                    clockwise: false)
        path.addLine(to: CGPoint(x: radius, y: 0))
        path.addArc(withCenter: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: CGFloat(M_PI_2*3),
                    endAngle: CGFloat(M_PI),
                    clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: view.bounds.size.height - arrowHeight - radius))
        path.addArc(withCenter: CGPoint(x: radius, y: view.bounds.size.height - arrowHeight - radius),
                    radius: radius,
                    startAngle: CGFloat(M_PI),
                    endAngle: CGFloat(M_PI_2),
                    clockwise: false)
        path.close()
        
        self.arrowShape.path = path.cgPath
        self.arrowShape.fillColor = self.fillColor.cgColor
        self.arrowShape.strokeColor = self.borderColor.cgColor
        self.arrowShape.lineWidth = 1.0
        
        view.layer.insertSublayer(self.arrowShape, at: 0)
        
        // add the label
        view.addSubview(self.label)
        
        return view
    }()
}

extension TipSlider: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print("did stop animationst")
            displaylink?.remove(from: RunLoop.current, forMode: .commonModes)
            displaylink?.invalidate()
            displaylink = nil
            self.arrowShape.removeAllAnimations()
            self.arrowShape.fillColor = self.fillColor.cgColor
            self.arrowShape.strokeColor = self.borderColor.cgColor
        }
    }
}
