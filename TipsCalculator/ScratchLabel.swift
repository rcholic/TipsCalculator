//
//  ScratchLabel.swift
//  TipsCalculator
//
//  Created by Guoliang Wang on 3/1/17.
//
//

import UIKit

protocol ScratchLabelDelegate: class {
    
    func scratchLabel(_ scratchLabel: ScratchLabel, number: CGFloat)
}

@IBDesignable final class ScratchLabel: UIControl {
    
    @IBInspectable var panGesture: UIPanGestureRecognizer!
    
    @IBInspectable var step: CGFloat = 0.1
    
    @IBInspectable var number: CGFloat = 0 {
        didSet {
            guard number > 0 else {
                self.numberLabel.text = ""
                return
            }
            self.numberLabel.text = "$\(Double(number).roundTo(places: 1))"
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                self.backgroundColor = tintColor.withAlphaComponent(0.2)
            default:
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    weak var delegate: ScratchLabelDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        numberLabel.frame = self.bounds
        
        self.addSubview(numberLabel)
        addGesture()
    }
    
    fileprivate func addGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        addGestureRecognizer(panGesture)
    }
    
    internal override func prepareForInterfaceBuilder() {
        self.layer.borderColor = tintColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    deinit {
        panGesture = nil
    }
    
    @objc func tapped(_ sender: UIPanGestureRecognizer) {
        
        var beginPoint: CGPoint = CGPoint.zero
        switch sender.state {
        case .began:
            beginPoint = sender.velocity(in: self)
        case .changed:
            let curPanPoint =  sender.velocity(in: self) // sender.translation(in: self)
            
            //            if curPanPoint.x <= self.bounds.minX || curPanPoint.x >= self.bounds.maxX {
            //                return
            //            }
            
            //            guard curPanPoint.x >= self.bounds.minX && curPanPoint.x <= self.bounds.maxX else { return }
            let dx: CGFloat = curPanPoint.x - beginPoint.x
            let n = dx.truncatingRemainder(dividingBy: 10.0)
            print("remainder is: \(n)")
            
            guard number > 0 else {
                return
            }
            
            self.number = number + n * step
            
            delegate?.scratchLabel(self, number: self.number) // notify the changes
            
            print("moved dist: \(dx)")
            
        default:
            beginPoint = CGPoint.zero
        }
    }
    
    lazy var numberLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.sizeToFit()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.textAlignment = .center
        
        return label
    }()
}
