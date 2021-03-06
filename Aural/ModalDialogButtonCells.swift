/*
    Customizes the look n feel of buttons on modal dialogs
 */

import Cocoa

// Base class for all modal dialog button cells
class ModalDialogButtonCell: NSButtonCell {
    
    var cellInsetX: CGFloat {return 0}
    var cellInsetY: CGFloat {return 0}
    
    var backgroundFillGradient: NSGradient {return Colors.modalDialogButtonGradient}
    var backgroundFillGradient_disabled: NSGradient {return Colors.modalDialogButtonGradient_disabled}
    var borderRadius: CGFloat {return 2}
    
    var textColor: NSColor {return Colors.modalDialogButtonTextColor}
    var textColor_disabled: NSColor {return Colors.modalDialogButtonTextColor_disabled}
    
    var textFont: NSFont {return Fonts.modalDialogButtonFont}
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let drawRect = cellFrame.insetBy(dx: cellInsetX, dy: cellInsetY)
        
        // Background
        let borderPath = NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius)
        
        if isEnabled {
            backgroundFillGradient.draw(in: borderPath, angle: -UIConstants.verticalGradientDegrees)
        } else {
            backgroundFillGradient_disabled.draw(in: borderPath, angle: -UIConstants.verticalGradientDegrees)
        }
        
        // Title
        GraphicsUtils.drawCenteredTextInRect(cellFrame, title, isEnabled ? textColor : textColor_disabled, textFont)
    }
}

// Cell for all response buttons (Save/Cancel, etc)
class ModalDialogResponseButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 1}
    
    override var borderRadius: CGFloat {return 2.5}
}

// Cell for all response buttons (Save/Cancel, etc)
class ModalDialogControlButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 2}
    
    override var textFont: NSFont {return Fonts.modalDialogControlButtonFont}
}

class ModalDialogSmallControlButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 2}
    
    override var textFont: NSFont {return Fonts.gillSans10Font}
}

// Cell for search results navigation buttons (next/previous)
class ColoredNavigationButtonCell: ModalDialogButtonCell {
    
    override var cellInsetX: CGFloat {return 1}
    override var cellInsetY: CGFloat {return 1}
    
    override var borderRadius: CGFloat {return 3}
    
    override var textColor: NSColor {return Colors.modalDialogNavButtonTextColor}
    override var textFont: NSFont {return Fonts.modalDialogNavButtonFont}
}
