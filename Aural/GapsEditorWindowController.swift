import Cocoa

class GapsEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var btnGapBeforeTrack: NSButton!
    
    @IBOutlet weak var btnGapType_oneTime_1: NSButton!
    @IBOutlet weak var btnGapType_tillAppExits_1: NSButton!
    @IBOutlet weak var btnGapType_persistent_1: NSButton!
    
    @IBOutlet weak var timePicker_1: IntervalPicker!
    @IBOutlet weak var lblDuration_1: FormattedIntervalLabel!
    
    @IBOutlet weak var btnGapAfterTrack: NSButton!
    
    @IBOutlet weak var btnGapType_oneTime_2: NSButton!
    @IBOutlet weak var btnGapType_tillAppExits_2: NSButton!
    @IBOutlet weak var btnGapType_persistent_2: NSButton!
    
    @IBOutlet weak var timePicker_2: IntervalPicker!
    @IBOutlet weak var lblDuration_2: FormattedIntervalLabel!
    
    private var gaps: (hasGaps: Bool, beforeTrack: PlaybackGap?, afterTrack: PlaybackGap?)?
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "GapsEditorDialog"}
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
        super.windowDidLoad()
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetFields()
        
        UIUtils.showModalDialog(self.window!)
        return modalDialogResponse
    }
    
    func setDataForKey(_ key: String, _ value: Any?) {
        
        if key == "gaps" {
            
            if let val = value as? (hasGaps: Bool, beforeTrack: PlaybackGap?, afterTrack: PlaybackGap?)? {
                self.gaps = val
            }
        }
    }
    
    func resetFields() {
        
        // Initial values will depend on whether the dialog is in "create" mode or "edit" mode
        
        if let gapB = gaps?.beforeTrack {
        
            btnGapBeforeTrack.state = UIConstants.buttonState_1
            timePicker_1.setInterval(gapB.duration)
            
            switch gapB.type {
                
            case .oneTime:
                
                btnGapType_oneTime_1.state = UIConstants.buttonState_1
                
            case .tillAppExits:
                
                btnGapType_tillAppExits_1.state = UIConstants.buttonState_1
                
            case .persistent:
                
                btnGapType_persistent_1.state = UIConstants.buttonState_1
                
            default: NSLog("Gap type (before track) is implicit. This should be impossible !")
                
            }
            
        } else {
            
            btnGapBeforeTrack.state = UIConstants.buttonState_0
            timePicker_1.setInterval(5)
            btnGapType_persistent_1.state = UIConstants.buttonState_1
        }
        
        if let gapA = gaps?.afterTrack {
            
            btnGapAfterTrack.state = UIConstants.buttonState_1
            timePicker_2.setInterval(gapA.duration)
            
            switch gapA.type {
                
            case .oneTime:
                
                btnGapType_oneTime_2.state = UIConstants.buttonState_1
                
            case .tillAppExits:
                
                btnGapType_tillAppExits_2.state = UIConstants.buttonState_1
                
            case .persistent:
                
                btnGapType_persistent_2.state = UIConstants.buttonState_1
                
            default: NSLog("Gap type (after track) is implicit. This should be impossible !")
                
            }
            
        } else {
            
            btnGapAfterTrack.state = UIConstants.buttonState_0
            timePicker_2.setInterval(5)
            btnGapType_persistent_2.state = UIConstants.buttonState_1
        }
        
        timePickerAction_1(self)
        timePickerAction_2(self)
        gapBeforeTrackAction(self)
        gapAfterTrackAction(self)
    }
    
    @IBAction func gapBeforeTrackAction(_ sender: Any) {
        
        [timePicker_1, btnGapType_oneTime_1, btnGapType_persistent_1, btnGapType_tillAppExits_1].forEach({$0?.isEnabled = btnGapBeforeTrack.state == UIConstants.buttonState_1})
    }
    
    @IBAction func gapTypeAction_1(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func timePickerAction_1(_ sender: Any) {
        lblDuration_1.interval = timePicker_1.interval
    }
    
    @IBAction func gapAfterTrackAction(_ sender: Any) {
        
        [timePicker_2, btnGapType_oneTime_2, btnGapType_persistent_2, btnGapType_tillAppExits_2].forEach({$0?.isEnabled = btnGapAfterTrack.state == UIConstants.buttonState_1})
    }
    
    @IBAction func gapTypeAction_2(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func timePickerAction_2(_ sender: Any) {
        lblDuration_2.interval = timePicker_2.interval
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        var gapBeforeTrack: PlaybackGap? = nil
        var gapAfterTrack: PlaybackGap? = nil
        
        if btnGapBeforeTrack.state == UIConstants.buttonState_1 {
        
            let duration1 = timePicker_1.interval
            var type1: PlaybackGapType = .tillAppExits
            
            if btnGapType_oneTime_1.state == UIConstants.buttonState_1 {
                type1 = .oneTime
            } else if btnGapType_persistent_1.state == UIConstants.buttonState_1 {
                type1 = .persistent
            }
            
            gapBeforeTrack = PlaybackGap(duration1, .beforeTrack, type1)
        }
        
        if btnGapAfterTrack.state == UIConstants.buttonState_1 {
            
            let duration2 = timePicker_2.interval
            var type2: PlaybackGapType = .tillAppExits
            
            if btnGapType_oneTime_2.state == UIConstants.buttonState_1 {
                type2 = .oneTime
            } else if btnGapType_persistent_2.state == UIConstants.buttonState_1 {
                type2 = .persistent
            }
            
            gapAfterTrack = PlaybackGap(duration2, .afterTrack, type2)
        }
        
        SyncMessenger.publishActionMessage(InsertPlaybackGapsActionMessage(gapBeforeTrack, gapAfterTrack, PlaylistViewState.current))
        
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        modalDialogResponse = .cancel
        UIUtils.dismissModalDialog()
    }
}
