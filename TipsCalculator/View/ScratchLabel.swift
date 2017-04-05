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
                self.tipAmount = 0
                self.numberLabel.text = ""
                self.isHidden = true
                return
            }
            self.isHidden = false
            let tempNum = Double(number).roundTo(places: 2)
            let formattedNum = NumberFormatter.localizedString(from: NSNumber(value: tempNum), number: NumberFormatter.Style.decimal)
            let symbol = LOCAL_CURRENCY_SYMBOL ?? DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as! String
                // DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as? String ?? LOCAL_CURRENCY_SYMBOL
            self.numberLabel.text = "Total: \(symbol)\(formattedNum)"
            self.step = number / 1000 // dynamic step size
        }
    }
    
    internal var tipAmount: Double = 0.0 {
        didSet {
            guard tipAmount > 0 else {
                tipLabel.isHidden = true
                self.animateNumberLabel(isFullSize: true)
                return
            }
            tipLabel.isHidden = false
            self.animateNumberLabel(isFullSize: false)
            let symbol = LOCAL_CURRENCY_SYMBOL ?? DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as! String
                // DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as? String ?? LOCAL_CURRENCY_SYMBOL
            tipLabel.text = "\(symbol)\(tipAmount.roundTo(places: 2)) tips included"
        }
    }

    // FIXME: this needs to be eager fetch
//    var currencySymbol: String = {
//        return DataManager.shared.retrieve(for: CURRENCY_SYMBOL) as? String ?? LOCAL_CURRENCY_SYMBOL
//    }()
    
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
        self.addSubview(tipLabel)
        addGesture()
    }
    
    override func layoutSubviews() {
//        numberLabel.frame = numberLabelRect
    }
    
    fileprivate func addGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: change the frame size of the numberLabel using animation
    fileprivate func animateNumberLabel(isFullSize: Bool) {
        let numLblTargetRect = isFullSize ? self.bounds : self.numberLabelRect
        let tipLblTargetRect = isFullSize ? CGRect.zero : self.tipLabelRect
        
        UIView.animate(withDuration: 0.5) {
            self.numberLabel.frame = numLblTargetRect
            self.tipLabel.frame = tipLblTargetRect
        }
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
            let curPanPoint =  sender.velocity(in: self)

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
    
    private lazy var numberLabelRect: CGRect = {
        return CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height * 2/3)
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel(frame: self.numberLabelRect)
        label.sizeToFit()
        label.text = ""
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: self.fontSize)
        label.textAlignment = .center
//        label.clipsToBounds = true
        
        return label
    }()

    private lazy var tipLabelRect: CGRect = {
        
        return CGRect(origin: CGPoint(x: 0, y: self.bounds.height/3 + 12), size: CGSize(width: self.bounds.width, height: 30))
    }()
    private lazy var tipLabel: UILabel = {
        let label = UILabel(frame: self.tipLabelRect)
        label.text = ""
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        
        return label
    }()
}
