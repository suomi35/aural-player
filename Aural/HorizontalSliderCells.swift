/*
    Customizes the look and feel of all non-ticked horizontal sliders
*/

import Cocoa

// Base class for all horizontal slider cells
class HorizontalSliderCell: NSSliderCell {
    
    var barRadius: CGFloat {return 1}
    var barPlainGradient: NSGradient {return Colors.sliderBarPlainGradient}
    var barColoredGradient: NSGradient {return Colors.sliderBarColoredGradient}
    var gradientDegrees: CGFloat {return UIConstants.horizontalGradientDegrees}
    var barInsetX: CGFloat {return 0}
    var barInsetY: CGFloat {return 0}
    
    var knobWidth: CGFloat {return 10}
    var knobHeightOutsideBar: CGFloat {return 2}
    var knobRadius: CGFloat {return 1}
    var knobColor: NSColor {return Colors.sliderKnobColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)

        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        barColoredGradient.draw(in: drawPath, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: gradientDegrees)
    }
    
    override internal func drawKnob(_ knobRect: NSRect) {
        
        let rectWidth = knobRect.width
        let bar = barRect(flipped: true)
        let xCenter = knobRect.minX + (rectWidth / 2)
        
        let knobHeight: CGFloat = bar.height + knobHeightOutsideBar
        let knobMinX = xCenter - (knobWidth / 2)
        let rect = NSRect(x: knobMinX, y: bar.minY - ((knobHeight - bar.height) / 2), width: knobWidth, height: knobHeight)
        
        let knobPath = NSBezierPath(roundedRect: rect, xRadius: knobRadius, yRadius: knobRadius)
        knobColor.setFill()
        knobPath.fill()
    }
    
    override func barRect(flipped: Bool) -> NSRect {
        return super.barRect(flipped: flipped).insetBy(dx: barInsetX, dy: barInsetY)
    }
}

// Cell for volume slider
class VolumeSliderCell: HorizontalSliderCell {
    
    override var barInsetY: CGFloat {return 0.25}
    override var knobWidth: CGFloat {return 6}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 0.5}
}

// Defines the range (start and end points) used to render a track segment playback loop
struct PlaybackLoopRange {
    
    // Both are X co-ordinates
    
    var start: CGFloat
    var end: CGFloat?
}

// Cell for seek position slider
class SeekSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return 1.5}
    
    override var knobRadius: CGFloat {return 0}
    override var knobColor: NSColor {return NSColor(white: 0.8, alpha: 1.0)}
    override var knobWidth: CGFloat {return 7}
    override var knobHeightOutsideBar: CGFloat {return 2}
    
    override var barPlainGradient: NSGradient {return Colors.seekBarPlainGradient}
    override var barColoredGradient: NSGradient {return Colors.seekBarColoredGradient}
    
    var loop: PlaybackLoopRange?
    
    // Returns the center of the current knob frame
    var knobCenter: CGFloat {
        return knobRect(flipped: false).centerX
    }
    
    // Marks the rendering start point for a segment playback loop. The start argument is the X co-ordinate of the center of the knob frame at the loop start point
    func markLoopStart(_ start: CGFloat) {
        self.loop = PlaybackLoopRange(start: start, end: nil)
    }
    
    // Marks the rendering end point for a segment playback loop. The end argument is the X co-ordinate of the center of the knob frame at the loop end point
    func markLoopEnd(_ end: CGFloat) {
        self.loop?.end = end
    }
    
    // Invalidates the track segment playback loop
    func removeLoop() {
        self.loop = nil
    }
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)
        
        var drawPath = NSBezierPath.init(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        barColoredGradient.draw(in: drawPath, angle: gradientDegrees)
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        
        drawPath = NSBezierPath.init(roundedRect: rightRect, xRadius: barRadius, yRadius: barRadius)
        barPlainGradient.draw(in: drawPath, angle: gradientDegrees)

        // Render segment playback loop, if one is defined
        if let loop = self.loop {

            // Start and end points for the loop
            let startX = loop.start
            let endX = loop.end ?? max(startX + 1, knobFrame.minX + halfKnobWidth)
            
            // Loop bar
            let loopRect = NSRect(x: startX, y: aRect.minY, width: (endX - startX + 1), height: aRect.height)
            var drawPath = NSBezierPath.init(roundedRect: loopRect, xRadius: barRadius, yRadius: barRadius)
            Colors.playbackLoopGradient.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
            
            let markerMinY = barRect(flipped: false).minY - 2
            let markerHeight: CGFloat = aRect.height + 3
            let markerRadius: CGFloat = 0
            
            // Loop start marker
            let loopStartMarker = NSRect(x: startX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
            drawPath = NSBezierPath.init(roundedRect: loopStartMarker, xRadius: markerRadius, yRadius: markerRadius)
            Colors.playbackLoopGradient.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
            
            // Loop end marker
            if (loop.end != nil) {
            
                let loopEndMarker = NSRect(x: endX - (knobWidth / 2), y: markerMinY, width: knobWidth, height: markerHeight)
                drawPath = NSBezierPath.init(roundedRect: loopEndMarker, xRadius: markerRadius, yRadius: markerRadius)
                Colors.playbackLoopGradient.draw(in: drawPath, angle: UIConstants.verticalGradientDegrees)
            }
        }
    }
}

class BarModeSeekSliderCell: SeekSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var barInsetY: CGFloat {return 0.5}
    
    override var knobRadius: CGFloat {return 0}
    override var knobColor: NSColor {return NSColor(white: 0.8, alpha: 1.0)}
    override var knobWidth: CGFloat {return 5}
    override var knobHeightOutsideBar: CGFloat {return 1}
    
    override var barPlainGradient: NSGradient {return Colors.seekBarPlainGradient}
    override var barColoredGradient: NSGradient {return Colors.seekBarColoredGradient}
}


// Cell for sliders on the Preferences panel
class PreferencesSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return 0.5}
}

// Cell for sliders on the effects panel
class EffectsSliderCell: HorizontalSliderCell {

    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return 0.5}
    
    override var knobWidth: CGFloat {return 8}
    override var knobRadius: CGFloat {return 1}
    override var knobHeightOutsideBar: CGFloat {return 1}
}

extension NSRect {
    
    var centerX: CGFloat {
        return self.minX + (self.width / 2)
    }
}
