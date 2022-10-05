//
//  GClass.swift


import Foundation
import UIKit

class PinkThemeButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.hexStringToUIColor(hex: "#B6116B")
        self.tintColor = UIColor.white
        self.titleLabel?.textColor = .black
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.height/2
        }
        
    }
}

class CustomTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.hexStringToUIColor(hex: "#FFFFFF").withAlphaComponent(0.20)
        self.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.themePlaceHolder]
        )
        self.textColor = .white
        self.layer.cornerRadius = 20.0
    }
}

//class ThemeTextField: TextFieldPedding {
//    private var padding: UIEdgeInsets = UIEdgeInsets()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        padding = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
//        self.layer.cornerRadius = 7
//        self.superview?.viewStyle()
//        self.textColor = #colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1)
//        self.font = UIFont(name: "semibold", size: 16.0)
//        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//    }
//}


class TextFieldPedding: UITextField {
    @IBInspectable var leftPadding : CGFloat = 25
    @IBInspectable var rightPadding : CGFloat = 25
    
    private var padding: UIEdgeInsets = UIEdgeInsets()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 30, y: 0, width: 20 , height: bounds.height)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 10, y: 0, width: 20 , height: bounds.height)
    }
}


class GradientLabel: UILabel {
    var gradientColors: [CGColor] = []

    override func drawText(in rect: CGRect) {
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }

    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint.zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
