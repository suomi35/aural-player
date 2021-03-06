/*
    View controller for the popover that lets the user save an Equalizer preset
 */
import Cocoa

class StringInputPopoverViewController: NSViewController, NSPopoverDelegate {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    // Input fields
    @IBOutlet weak var lblPrompt: NSTextField!
    @IBOutlet weak var inputField: ColoredCursorTextField!
    
    // Error message fields
    @IBOutlet weak var errorBox: NSBox!
    @IBOutlet weak var lblError: NSTextField!
    
    // A callback object so that the string input can be validated without this class knowing the logic for doing so
    private var client: StringInputClient!
    
    override var nibName: String? {return "StringInputPopover"}
    
    static func create(_ client: StringInputClient) -> StringInputPopoverViewController {
        
        let controller = StringInputPopoverViewController()
        controller.client = client
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        popover.delegate = controller
        
        controller.popover = popover
        
        return controller
    }
    
    // Shows the popover
    func show(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if (!popover.isShown) {
            
            initFields()
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            initFields()
            
            errorBox.isHidden = true
        }
    }
    
    private func initFields() {
        
        // TODO: Resize/realign fields and popover per input text length !!!
        
        // Initialize the fields with information from the client
        lblPrompt?.stringValue = client.getInputPrompt()
        inputField?.stringValue = client.getDefaultValue() ?? ""
        inputField?.currentEditor()?.selectedRange = NSMakeRange(0, 0)
    }
    
    // Closes the popover
    func close() {
        
        if (popover.isShown) {
            popover.performClose(self)
        }
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
        // Validate input by calling back to the client
        let validation = client.validate(inputField.stringValue)
        
        if !validation.valid {
            
            lblError.stringValue = validation.errorMsg ?? ""
            errorBox.isHidden = false
            
        } else {
            
            client.acceptInput(inputField.stringValue)
            self.close()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.close()
    }
    
    // MARK: Popover Delegate functions
    
    func popoverDidShow(_ notification: Notification) {
        WindowState.showingPopover = true
    }
    
    func popoverDidClose(_ notification: Notification) {
        WindowState.showingPopover = false
    }
    
    func isShown() -> Bool {
        return popover.isShown
    }
}
