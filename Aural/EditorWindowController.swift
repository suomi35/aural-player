import Cocoa

class EditorWindowController: NSWindowController {
    
    private lazy var bookmarksEditorView: NSView = ViewFactory.getBookmarksEditorView()
    
    private lazy var favoritesEditorView: NSView = ViewFactory.getFavoritesEditorView()
    
    private lazy var layoutsEditorView: NSView = ViewFactory.getLayoutsEditorView()
    
    private lazy var effectsPresetsEditorView: NSView = ViewFactory.getEffectsPresetsEditorView()
    
    override var windowNibName: String? {return "EditorWindow"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        
        theWindow.contentView?.addSubview(bookmarksEditorView)
        theWindow.contentView?.addSubview(favoritesEditorView)
        theWindow.contentView?.addSubview(layoutsEditorView)
        theWindow.contentView?.addSubview(effectsPresetsEditorView)
        
        theWindow.isMovableByWindowBackground = true
    }
    
    func showBookmarksEditor() {
        
        bookmarksEditorView.isHidden = false
        
        favoritesEditorView.isHidden = true
        layoutsEditorView.isHidden = true
        effectsPresetsEditorView.isHidden = true
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showFavoritesEditor() {
        
        favoritesEditorView.isHidden = false
        
        bookmarksEditorView.isHidden = true
        layoutsEditorView.isHidden = true
        effectsPresetsEditorView.isHidden = true
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showLayoutsEditor() {
        
        layoutsEditorView.isHidden = false
        
        favoritesEditorView.isHidden = true
        bookmarksEditorView.isHidden = true
        effectsPresetsEditorView.isHidden = true
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showEffectsPresetsEditor() {
        
        effectsPresetsEditorView.isHidden = false
        
        layoutsEditorView.isHidden = true
        favoritesEditorView.isHidden = true
        bookmarksEditorView.isHidden = true
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
}
