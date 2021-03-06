import Cocoa

class PlaybackPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnPrimarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnPrimarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var primarySeekLengthPicker: IntervalPicker!
    @IBOutlet weak var lblPrimarySeekLength: FormattedIntervalLabel!
    
    @IBOutlet weak var primarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblPrimarySeekLengthPerc: NSTextField!
    
    private var primarySeekLengthConstantFields: [NSControl] = []
    
    @IBOutlet weak var btnSecondarySeekLengthConstant: NSButton!
    @IBOutlet weak var btnSecondarySeekLengthPerc: NSButton!
    
    @IBOutlet weak var secondarySeekLengthPicker: IntervalPicker!
    @IBOutlet weak var lblSecondarySeekLength: FormattedIntervalLabel!
    
    @IBOutlet weak var secondarySeekLengthPercStepper: NSStepper!
    @IBOutlet weak var lblSecondarySeekLengthPerc: NSTextField!
    
    private var secondarySeekLengthConstantFields: [NSControl] = []
    
    @IBOutlet weak var btnAutoplayOnStartup: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: NSButton!
    @IBOutlet weak var btnAutoplayIfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAlways: NSButton!
    
    @IBOutlet weak var btnShowNewTrack: NSButton!
    
    @IBOutlet weak var btnRememberPosition: NSButton!
    @IBOutlet weak var btnRememberPosition_allTracks: NSButton!
    @IBOutlet weak var btnRememberPosition_individualTracks: NSButton!
    
    @IBOutlet weak var btnGapBetweenTracks: NSButton!
    @IBOutlet weak var gapDurationPicker: IntervalPicker!
    @IBOutlet weak var lblGapDuration: FormattedIntervalLabel!
    
    @IBOutlet weak var btnInfo_primarySeekLength: NSButton!
    @IBOutlet weak var btnInfo_secondarySeekLength: NSButton!
    
    override var nibName: String? {return "PlaybackPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        primarySeekLengthConstantFields = [primarySeekLengthPicker]
        secondarySeekLengthConstantFields = [secondarySeekLengthPicker]
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let playbackPrefs = preferences.playbackPreferences
        
        // Primary seek length
        
        let primarySeekLength = playbackPrefs.primarySeekLengthConstant
        primarySeekLengthPicker.setInterval(Double(primarySeekLength))
        primarySeekLengthAction(self)
        
        let primarySeekLengthPerc = playbackPrefs.primarySeekLengthPercentage
        primarySeekLengthPercStepper.integerValue = primarySeekLengthPerc
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPerc)
        
        if playbackPrefs.primarySeekLengthOption == .constant {
            btnPrimarySeekLengthConstant.state = UIConstants.buttonState_1
        } else {
            btnPrimarySeekLengthPerc.state = UIConstants.buttonState_1
        }
        
        primarySeekLengthConstantFields.forEach({$0.isEnabled = playbackPrefs.primarySeekLengthOption == .constant})
        primarySeekLengthPercStepper.isEnabled = playbackPrefs.primarySeekLengthOption == .percentage
        
        // Secondary seek length
        
        let secondarySeekLength = playbackPrefs.secondarySeekLengthConstant
        secondarySeekLengthPicker.setInterval(Double(secondarySeekLength))
        secondarySeekLengthAction(self)
        
        let secondarySeekLengthPerc = playbackPrefs.secondarySeekLengthPercentage
        secondarySeekLengthPercStepper.integerValue = secondarySeekLengthPerc
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPerc)
        
        if playbackPrefs.secondarySeekLengthOption == .constant {
            btnSecondarySeekLengthConstant.state = UIConstants.buttonState_1
        } else {
            btnSecondarySeekLengthPerc.state = UIConstants.buttonState_1
        }
        
        secondarySeekLengthConstantFields.forEach({$0.isEnabled = playbackPrefs.secondarySeekLengthOption == .constant})
        secondarySeekLengthPercStepper.isEnabled = playbackPrefs.secondarySeekLengthOption == .percentage
        
        // Autoplay
        
        btnAutoplayOnStartup.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayOnStartup ? 1 : 0)
        
        btnAutoplayAfterAddingTracks.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingTracks ? 1 : 0)
        
        btnAutoplayIfNotPlaying.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingOption == .ifNotPlaying ? 1 : 0)
        
        btnAutoplayAlways.isEnabled = playbackPrefs.autoplayAfterAddingTracks
        btnAutoplayAlways.state = NSControl.StateValue(rawValue: playbackPrefs.autoplayAfterAddingOption == .always ? 1 : 0)
        
        // Show new track
        
        btnShowNewTrack.state = NSControl.StateValue(rawValue: playbackPrefs.showNewTrackInPlaylist ? 1 : 0)
        
        // Remember last track position
        
        btnRememberPosition.state = NSControl.StateValue(rawValue: playbackPrefs.rememberLastPosition ? 1 : 0)
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = Bool(btnRememberPosition.state.rawValue)})
        
        if playbackPrefs.rememberLastPositionOption == .individualTracks {
            btnRememberPosition_individualTracks.state = UIConstants.buttonState_1
        } else {
            btnRememberPosition_allTracks.state = UIConstants.buttonState_1
        }
        
        // Gap between tracks
        
        btnGapBetweenTracks.state = playbackPrefs.gapBetweenTracks ? UIConstants.buttonState_1 : UIConstants.buttonState_0
        [lblGapDuration, gapDurationPicker].forEach({$0?.isEnabled = btnGapBetweenTracks.state == UIConstants.buttonState_1})
        gapDurationPicker.setInterval(Double(playbackPrefs.gapBetweenTracksDuration))
        gapDurationPickerAction(self)
    }
    
    @IBAction func primarySeekLengthRadioButtonAction(_ sender: Any) {
        primarySeekLengthConstantFields.forEach({$0.isEnabled = btnPrimarySeekLengthConstant.state.rawValue == 1})
        primarySeekLengthPercStepper.isEnabled = btnPrimarySeekLengthPerc.state.rawValue == 1
    }
    
    @IBAction func secondarySeekLengthRadioButtonAction(_ sender: Any) {
        secondarySeekLengthConstantFields.forEach({$0.isEnabled = btnSecondarySeekLengthConstant.state.rawValue == 1})
        secondarySeekLengthPercStepper.isEnabled = btnSecondarySeekLengthPerc.state.rawValue == 1
    }
    
    @IBAction func primarySeekLengthAction(_ sender: Any) {
        lblPrimarySeekLength.interval = primarySeekLengthPicker.interval
    }
    
    @IBAction func secondarySeekLengthAction(_ sender: Any) {
        lblSecondarySeekLength.interval = secondarySeekLengthPicker.interval
    }
    
    @IBAction func primarySeekLengthPercAction(_ sender: Any) {
        lblPrimarySeekLengthPerc.stringValue = String(format: "%d%%", primarySeekLengthPercStepper.integerValue)
    }
    
    @IBAction func secondarySeekLengthPercAction(_ sender: Any) {
        lblSecondarySeekLengthPerc.stringValue = String(format: "%d%%", secondarySeekLengthPercStepper.integerValue)
    }
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
        [btnAutoplayIfNotPlaying, btnAutoplayAlways].forEach({$0!.isEnabled = Bool(btnAutoplayAfterAddingTracks.state.rawValue)})
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func rememberLastPositionAction(_ sender: Any) {
        [btnRememberPosition_individualTracks, btnRememberPosition_allTracks].forEach({$0?.isEnabled = Bool(btnRememberPosition.state.rawValue)})
    }
    
    @IBAction func rememberLastPositionRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func gapDurationAction(_ sender: NSButton) {
        [lblGapDuration, gapDurationPicker].forEach({$0?.isEnabled = btnGapBetweenTracks.state == UIConstants.buttonState_1})
    }
    
    @IBAction func gapDurationPickerAction(_ sender: Any) {
        lblGapDuration.interval = gapDurationPicker.interval
    }
    
    @IBAction func seekLengthPrimary_infoAction(_ sender: Any) {
        showInfo(Strings.info_seekLengthPrimary)
    }
    
    @IBAction func seekLengthSecondary_infoAction(_ sender: Any) {
        showInfo(Strings.info_seekLengthSecondary)
    }
    
    private func showInfo(_ text: String) {
        
        let helpManager = NSHelpManager.shared
        let textFontAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.helpInfoTextFont
            ])
        
        helpManager.setContextHelp(NSAttributedString(string: text, attributes: textFontAttributes), for: btnInfo_primarySeekLength)
        helpManager.showContextHelp(for: btnInfo_primarySeekLength, locationHint: NSEvent.mouseLocation)
    }
    
    func save(_ preferences: Preferences) throws {
        
        let playbackPrefs = preferences.playbackPreferences
        
        playbackPrefs.primarySeekLengthOption = btnPrimarySeekLengthConstant.state.rawValue == 1 ? .constant : .percentage
        playbackPrefs.primarySeekLengthConstant = Int(round(primarySeekLengthPicker.interval))
        playbackPrefs.primarySeekLengthPercentage = primarySeekLengthPercStepper.integerValue
        
        playbackPrefs.secondarySeekLengthOption = btnSecondarySeekLengthConstant.state.rawValue == 1 ? .constant : .percentage
        playbackPrefs.secondarySeekLengthConstant = Int(round(secondarySeekLengthPicker.interval))
        playbackPrefs.secondarySeekLengthPercentage = secondarySeekLengthPercStepper.integerValue
        
        playbackPrefs.autoplayOnStartup = Bool(btnAutoplayOnStartup.state.rawValue)
        
        playbackPrefs.autoplayAfterAddingTracks = Bool(btnAutoplayAfterAddingTracks.state.rawValue)
        playbackPrefs.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.state.rawValue == 1 ? .ifNotPlaying : .always
     
        playbackPrefs.showNewTrackInPlaylist = Bool(btnShowNewTrack.state.rawValue)
        
        playbackPrefs.rememberLastPosition = Bool(btnRememberPosition.state.rawValue)
        
        let wasAllTracks: Bool = playbackPrefs.rememberLastPositionOption == .allTracks
        
        playbackPrefs.rememberLastPositionOption = btnRememberPosition_individualTracks.state == UIConstants.buttonState_1 ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = playbackPrefs.rememberLastPositionOption == .individualTracks
        
        if !playbackPrefs.rememberLastPosition || (wasAllTracks && isNowIndividualTracks) {
            PlaybackProfiles.removeAll()
        }
        
        playbackPrefs.gapBetweenTracks = btnGapBetweenTracks.state == UIConstants.buttonState_1
        playbackPrefs.gapBetweenTracksDuration = Int(round(gapDurationPicker.interval))
    }
}

fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
