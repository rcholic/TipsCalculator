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
    
    @IBInspectable var fontSize: CGFloat = 30
    
    @IBInspectable var number: CGFloat = 0 {
        didSet {
            guard number > 0 else {
                self.numberLabel.text = ""
                self.isHidden = true
                return
            }
            self.isHidden = false
            let tempNum = Double(number).roundTo(places: 2)
            let formattedNum = NumberFormatter.localizedString(from: NSNumber(value: tempNum), number: NumberFormatter.Style.decimal)
            let symbol = DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as! String? ?? LOCAL_CURRENCY_SYMBOL
            self.numberLabel.text = " Total = \(symbol)\(formattedNum)"
            self.step = number / 1000 // dynamic step size
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                self.highlightBorder(color: UIColor.orange)
            default:
                self.layer.borderWidth = 0
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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        self.addSubview(numberLabel)
        addGesture()
    }
    
    override func layoutSubviews() {
        numberLabel.frame = self.bounds
        self.layoutIfNeeded()
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
        removeGestureRecognizer(panGesture)
        panGesture = nil
    }
    
    fileprivate func highlightBorder(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 2.0
    }
    
    @objc func tapped(_ sender: UIPanGestureRecognizer) {
        
        var beginPoint: CGPoint = CGPoint.zero
        switch sender.state {
        case .began:
            beginPoint = sender.velocity(in: self)
            highlightBorder(color: UIColor.orange)
        case .changed:
            let curPanPoint =  sender.velocity(in: self) // sender.translation(in: self)
            
            //            if curPanPoint.x <= self.bounds.minX || curPanPoint.x >= self.bounds.maxX {
            //                return
            //            }
            
            //            guard curPanPoint.x >= self.bounds.minX && curPanPoint.x <= self.bounds.maxX else { return }
            let dx: CGFloat = curPanPoint.x - beginPoint.x
            let n = dx.truncatingRemainder(dividingBy: 10.0)
            
            guard number > 0 else {
                return
            }
            
            self.number = number + n * step
            delegate?.scratchLabel(self, number: self.number) // notify the changes
            highlightBorder(color: UIColor.orange)
            
        default:
            beginPoint = CGPoint.zero
            self.layer.borderWidth = 0
        }
    }
    
    lazy var numberLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.sizeToFit()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: self.fontSize)
        label.textAlignment = .center
        label.clipsToBounds = true
        
        return label
    }()
}
