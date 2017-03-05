//
//  TipSlider.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/5/17.
//
//

import UIKit

@objc protocol TipSliderDelegate: class {
    func tipSlider(_ slider: TipSlider, value changedTo: Float)
}

@IBDesignable
class TipSlider: UIControl {
    
    @IBInspectable
    var fraction: CGFloat = 0.1 {
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
    
    var slider: UISlider!
    
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
        slider = UISlider(frame: CGRect.zero)
        slider.clipsToBounds = true
        slider.setThumbImage(UIImage(named: ""), for: UIControlState.highlighted)
        slider.addTarget(self, action: #selector(self.valueChanged(sender:)), for: UIControlEvents.valueChanged)
        self.fraction = 0
        addSubview(slider)
        addSubview(arrowLabelView)
    }
    
    deinit {
        slider = nil
        label.removeFromSuperview()
        arrowLabelView.removeFromSuperview()
    }
    
    
    override func layoutSubviews() {
        //        arrowLabelView.frame = CGRect(x: 0, y: 0, width: self.bounds.width/3, height: self.bounds.height / 2)
        arrowLabelView.frame.origin = CGPoint(x: -5, y: 0)
        slider.frame = CGRect(x: 0, y: arrowLabelView.bounds.height, width: self.bounds.width, height: self.bounds.height/2)
    }
    
    @objc func valueChanged(sender: UISlider) {
        
        let curValue = self.slider.value
        //        curValue += curValue > 0.5 ? -0.08 : 0.08 // slightly adjust the position (workaround)
        self.label.text = "\(Double(curValue * 100).roundTo(places: 1))%" // update label
        arrowLabelView.center = CGPoint(x: CGFloat(curValue) * self.slider.bounds.size.width, y: self.slider.bounds.size.height/2.0)
        
        delegate?.tipSlider(self, value: curValue) // notify delegate of the changed value
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let textLabel = UILabel()
        textLabel.text = "Slider View!"
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 20)
        self.addSubview(textLabel)
        textLabel.frame = CGRect(x: 0, y: 0, width: (self.superview?.bounds.width)!, height: 40)
        
    }
    
    lazy var label: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textColor = .black
        lbl.backgroundColor = .clear
        lbl.textAlignment = .center
        
        return lbl
    }()
    
    lazy var arrowLabelView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
        //        view.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).withAlphaComponent(0.4)
        
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
        
        let arrowShape = CAShapeLayer()
        arrowShape.path = path.cgPath
        arrowShape.fillColor = self.fillColor.cgColor
        arrowShape.strokeColor = self.borderColor.cgColor
        arrowShape.lineWidth = 1.0
        
        view.layer.insertSublayer(arrowShape, at: 0)
        
        // add the label
        view.addSubview(self.label)
        // initialize the fraction number
        //        self.fraction = CGFloat(self.slider.value)
        
        return view
    }()
}
