/*
    Container for colors used by the UI
*/

import Cocoa

struct Colors {
    
    // Color of text inside any of the container boxes
    static let boxTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    static let editorHeaderTextColor: NSColor = NSColor(calibratedWhite: 0.85, alpha: 1)
    
    // Color of text inside the playlist (non-selected items)
    static let playlistTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    
    // Color of selected item text inside the playlist
    static let playlistSelectedTextColor: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    
    static let playlistGapTextColor: NSColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
    static let playlistSelectedGapTextColor: NSColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
    
    // Color for playlist grouped views
    static let playlistGroupNameTextColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    static let playlistGroupNameSelectedTextColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    static let playlistGroupItemTextColor: NSColor = NSColor(calibratedWhite: 0.7, alpha: 1)
    static let playlistGroupItemSelectedTextColor: NSColor = NSColor(calibratedWhite: 1, alpha: 1)
    
    // Fill color of box drawn around selected playlist item
    static let playlistSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.15, alpha: 1)
    
    static let editorSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.55, alpha: 1)
    
    // Fill color of all slider knobs
    static let sliderKnobColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    // Outline color of buttons on modal dialogs
    static let modalDialogButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.575, alpha: 1)
    
    // Color used to fill tab view buttons
    static let tabViewButtonBackgroundColor: NSColor = NSColor(calibratedWhite: 0, alpha: 1)
    
    static let transparentColor: NSColor = NSColor(calibratedWhite: 1, alpha: 0)
    
    // Color used to outline tab view buttons
    static let tabViewButtonOutlineColor: NSColor = NSColor(calibratedWhite: 0.65, alpha: 1)
    
    // Color used for text in tab view buttons
    static let tabViewButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Color of the arrow drawn on popup menus
    static let popupMenuArrowColor: NSColor = NSColor(calibratedWhite: 0.2, alpha: 1)
    
    // A lighter version of popupMenuArrowColor
    static let lightPopupMenuArrowColor: NSColor = NSColor(calibratedWhite: 0.8, alpha: 1)
    
    // Color of the displayed text in popup menus
    static let popupMenuTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    static let sliderBarGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.7, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Gradient used to fill slider bars
    static let sliderBarPlainGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.7, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let sliderBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0.4, green: 0, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let playbackLoopGradient: NSGradient = {
        
        let backgroundStart = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
        let backgroundEnd =  NSColor(red: 0.7, green: 0, blue: 0, alpha: 1)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarPlainGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.3, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.3, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    static let seekBarColoredGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.8, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.6, alpha: 1.0)
        let barBackgroundGradient = NSGradient(starting: backgroundStart, ending: backgroundEnd)
        
        return barBackgroundGradient!
    }()
    
    // Color of the ticks/notches on sliders
    static let sliderNotchColor: NSColor = NSColor(calibratedWhite: 0.2, alpha: 1)
    
    // Pop up menu (reverb/EQ/recorder) color
    static let popupMenuColor: NSColor = NSColor(calibratedWhite: 0.6, alpha: 1)
    
    // Fill color of box drawn around selected tab view item
    static let tabViewSelectionBoxColor: NSColor = NSColor(calibratedWhite: 0.135, alpha: 1)
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    static let modalDialogButtonGradient: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.5, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.2, alpha: 1.0)
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Text color of modal dialog buttons
    static let modalDialogButtonTextColor_disabled: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    static let modalDialogButtonGradient_disabled: NSGradient = {
        
        let backgroundStart = NSColor(white: 0.25, alpha: 1.0)
        let backgroundEnd =  NSColor(white: 0.1, alpha: 1.0)
        return NSGradient(starting: backgroundStart, ending: backgroundEnd)!
    }()
    
    // Fill color of modal dialog navigation buttons (search)
    static let modalDialogNavButtonColor: NSColor = NSColor(calibratedWhite: 0.45, alpha: 1)
    
    // Fill color of text in modal dialog navigation buttons (search)
    static let modalDialogNavButtonTextColor: NSColor = NSColor(calibratedWhite: 0.9, alpha: 1)
    
    // Color of cursor inside text fields
    static let textFieldCursorColor: NSColor = NSColor(calibratedWhite: 0.5, alpha: 1)
    
    // Background color of the popover view
    static let popoverBackgroundColor: NSColor = NSColor(calibratedWhite: 0.1, alpha: 1)
}
