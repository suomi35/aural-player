import Cocoa

/*
    Base view controller for the hierarchical/grouping ("Artists", "Albums", and "Genres") playlist views
 */
class GroupingPlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playlistView: AuralPlaylistOutlineView!
    
    private lazy var contextMenu: NSMenu! = WindowFactory.getPlaylistContextMenu()
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private lazy var layoutManager: LayoutManager = ObjectGraph.getLayoutManager()
    
    private let playbackPreferences: PlaybackPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().playbackPreferences
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    // Intended to be overriden by subclasses
    
    // Indicates the type of each parent group in this playlist view
    internal var groupType: GroupType {return .artist}
    
    // Indicates the type of playlist this view displays
    internal var playlistType: PlaylistType {return .artists}
    
    override func viewDidLoad() {
        
        // Enable drag n drop
        playlistView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([String(kUTTypeFileURL), "public.data"]))
        
        playlistView.menu = contextMenu
        
        initSubscriptions()
        SyncMessenger.subscribe(messageTypes: [.appModeChangedNotification, .gapUpdatedNotification], subscriber: self)
        
        // Register for key press and gesture events
        PlaylistInputEventHandler.registerViewForPlaylistType(self.playlistType, playlistView)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to various message notifications
        AsyncMessenger.subscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .searchResultSelectionRequest, .gapUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.removeTracks, .moveTracksUp, .moveTracksToTop, .moveTracksDown, .moveTracksToBottom, .invertSelection, .cropSelection, .scrollToTop, .scrollToBottom, .refresh, .showPlayingTrack, .playSelectedItem, .playSelectedItemWithDelay, .showTrackInFinder, .insertGaps, .removeGaps], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .gapStarted], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.trackChangedNotification, .searchResultSelectionRequest, .gapUpdatedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.removeTracks, .moveTracksUp, .moveTracksToTop, .moveTracksDown, .moveTracksToBottom, .invertSelection, .cropSelection, .scrollToTop, .scrollToBottom, .refresh, .showPlayingTrack, .playSelectedItem, .playSelectedItemWithDelay, .showTrackInFinder, .insertGaps, .removeGaps], subscriber: self)
    }
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        
        PlaylistViewState.current = self.playlistType
        PlaylistViewState.currentView = playlistView
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: self.playlistType))
    }
    
    // Plays the track/group selected within the playlist, if there is one. If multiple items are selected, the first one will be chosen.
    @IBAction func playSelectedItemAction(_ sender: AnyObject) {
        playSelectedItemWithDelay(nil)
    }
    
    private func playSelectedItemWithDelay(_ delay: Double?) {
        
        let selRowIndexes = playlistView.selectedRowIndexes
        
        if (!selRowIndexes.isEmpty) {
            
            let item = playlistView.item(atRow: selRowIndexes.min()!)
            
            // The selected item is either a track or a group
            var request: PlaybackRequest = item is Track ? PlaybackRequest(track: item as! Track) : PlaybackRequest(group: item as! Group)
            request.delay = delay
            
            _ = SyncMessenger.publishRequest(request)
        }
    }
    
    private func clearPlaylist() {
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
    }
    
    // Helper function that gathers all selected playlist items as tracks and groups
    private func collectTracksAndGroups() -> (tracks: [Track], groups: [Group]) {
        return doCollectTracksAndGroups(playlistView.selectedRowIndexes)
    }
    
    private func doCollectTracksAndGroups(_ indexes: IndexSet) -> (tracks: [Track], groups: [Group]) {
        
        var tracks = [Track]()
        var groups = [Group]()
        
        indexes.forEach({
            
            let item = playlistView.item(atRow: $0)
            
            if let track = item as? Track {
                tracks.append(track)
            } else {
                // Group
                groups.append(item as! Group)
            }
        })
        
        return (tracks, groups)
    }
    
    private func removeTracks() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        if (groups.isEmpty && tracks.isEmpty) {
            
            // Nothing selected, nothing to do
            return
        }
        
        // If all groups are selected, this is the same as clearing the playlist
        if (groups.count == playlist.numberOfGroups(self.groupType)) {
            clearPlaylist()
            return
        }
        
        playlist.removeTracksAndGroups(tracks, groups, groupType)
    }
    
    private func selectTrack(_ track: Track?) {
        
        if (playlistView.numberOfRows > 0) {
            
            if let _track = track {
                
                let group = playlist.groupingInfoForTrack(self.groupType, _track).group
                
                // Need to expand the parent group to make the child track visible
                playlistView.expandItem(group)
                
                let trackRowIndex = playlistView.row(forItem: _track)
                
                playlistView.selectRowIndexes(IndexSet(integer: trackRowIndex), byExtendingSelection: false)
                playlistView.scrollRowToVisible(trackRowIndex)
            }
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ track: GroupedTrack?) {
        
        if (playlistView.numberOfRows > 0) {
            
            if let _track = track?.track {
                
                // Need to expand the parent group to make the child track visible
                playlistView.expandItem(track?.group)
                
                let trackRowIndex = playlistView.row(forItem: _track)
                
                playlistView.selectRowIndexes(IndexSet(integer: trackRowIndex), byExtendingSelection: false)
                playlistView.scrollRowToVisible(trackRowIndex)
            }
        }
    }
    
    private func refresh() {
        playlistView.reloadData()
    }
    
    private func moveTracksUp() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (!tracks.isEmpty && !groups.isEmpty) {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = playlist.moveTracksAndGroupsUp(tracks, groups, self.groupType)
        moveItems(results)
        
        // Re-select all the items that were moved
        var allItems: [PlaylistItem] = [PlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    private func moveTracksToTop() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (!tracks.isEmpty && !groups.isEmpty) {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = playlist.moveTracksAndGroupsToTop(tracks, groups, self.groupType)
        removeAndInsertItems(results)
        
        // Re-select all the items that were moved
        var allItems: [PlaylistItem] = [PlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: ItemMoveResults) {
        
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.removeItems(at: IndexSet([trackMovedResult.oldTrackIndex]), inParent: trackMovedResult.parentGroup, withAnimation: trackMovedResult.movedUp ? .slideUp : .slideDown)
                
                playlistView.insertItems(at: IndexSet([trackMovedResult.newTrackIndex]), inParent: trackMovedResult.parentGroup, withAnimation: trackMovedResult.movedUp ? .slideDown : .slideUp)
                
            } else {
                
                let groupMovedResult = result as! GroupMoveResult
                
                playlistView.removeItems(at: IndexSet([groupMovedResult.oldGroupIndex]), inParent: nil, withAnimation: groupMovedResult.movedUp ? .slideUp : .slideDown)
                
                playlistView.insertItems(at: IndexSet([groupMovedResult.newGroupIndex]), inParent: nil, withAnimation: groupMovedResult.movedUp ? .slideDown : .slideUp)
            }
        }
    }
    
    private func moveTracksToBottom() {
        
        // TODO: Code duplication with moveTracksToTop
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (!tracks.isEmpty && !groups.isEmpty) {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = playlist.moveTracksAndGroupsToBottom(tracks, groups, self.groupType)
        removeAndInsertItems(results)
        
        // Re-select all the items that were moved
        var allItems: [PlaylistItem] = [PlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func moveItems(_ results: ItemMoveResults) {
        
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.moveItem(at: trackMovedResult.oldTrackIndex, inParent: trackMovedResult.parentGroup, to: trackMovedResult.newTrackIndex, inParent: trackMovedResult.parentGroup)
                
            } else {
                
                let groupMovedResult = result as! GroupMoveResult
                playlistView.moveItem(at: groupMovedResult.oldGroupIndex, inParent: nil, to: groupMovedResult.newGroupIndex, inParent: nil)
            }
        }
    }
    
    // Selects all the specified items within the playlist view
    private func selectAllItems(_ items: [PlaylistItem]) {
        
        // Determine the row indexes for the items
        var selIndexes = [Int]()
        items.forEach({selIndexes.append(playlistView.row(forItem: $0))})
        
        // Select the item indexes
        playlistView.selectRowIndexes(IndexSet(selIndexes), byExtendingSelection: false)
    }
    
    private func moveTracksDown() {
        
        // TODO: Code duplication with moveTracksUp
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (tracks.count > 0 && groups.count > 0) {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = playlist.moveTracksAndGroupsDown(tracks, groups, self.groupType)
        moveItems(results)
        
        // Re-select all the items that were moved
        var allItems: [PlaylistItem] = [PlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    private func invertSelection() {
        playlistView.selectRowIndexes(getInvertedSelection(), byExtendingSelection: false)
    }
    
    private func getInvertedSelection() -> IndexSet {
        
        let selRows = playlistView.selectedRowIndexes
        
        var curIndex: Int = 0
        var itemsInspected: Int = 0
        
        let playlistSize = playlist.size()
        var targetSelRows = IndexSet()

        // Iterate through items, till all items have been inspected
        while itemsInspected < playlistSize {
            
            let item = playlistView.item(atRow: curIndex)
            
            if let group = item as? Group {
             
                let selected: Bool = selRows.contains(curIndex)
                let expanded: Bool = playlistView.isItemExpanded(group)
                
                if selected {
                    
                    // Ignore this group as it is selected
                    if expanded {
                        curIndex += group.size()
                    }
                    
                } else {
                    
                    // Group not selected
                    
                    if expanded {
                        
                        // Check for selected children
                        
                        let childIndexes = selRows.filter({$0 > curIndex && $0 <= curIndex + group.size()})
                        if childIndexes.isEmpty {
                            
                            // No children selected, add group index
                            targetSelRows.insert(curIndex)
                            
                        } else {
                            
                            // Check each child track
                            for index in 1...group.size() {
                                
                                if !selRows.contains(curIndex + index) {
                                    targetSelRows.insert(curIndex + index)
                                }
                            }
                        }
                        
                        curIndex += group.size()
                        
                    } else {
                        
                        // Group (and children) not selected, add this group to inverted selection
                        targetSelRows.insert(curIndex)
                    }
                }
                
                curIndex += 1
                itemsInspected += group.size()
            }
        }
        
        return targetSelRows
    }
    
    private func clearSelection() {
        
        let selItems = collectTracksAndGroups()
        
        // Clear the selection
        playlistView.deselectAll(self)
        selItems.groups.forEach({playlistView.reloadItem($0)})
        selItems.tracks.forEach({playlistView.reloadItem($0)})
    }
    
    private func cropSelection() {
        
        let tracksToDelete = getInvertedSelection()
        clearSelection()
        
        if (tracksToDelete.count > 0) {
            
            let tracksAndGroups = doCollectTracksAndGroups(tracksToDelete)
            let tracks = tracksAndGroups.tracks
            let groups = tracksAndGroups.groups
            
            if (groups.isEmpty && tracks.isEmpty) {
                
                // Nothing selected, nothing to do
                return
            }
            
            // If all groups are selected, this is the same as clearing the playlist
            if (groups.count == playlist.numberOfGroups(self.groupType)) {
                clearPlaylist()
                return
            }
            
            playlist.removeTracksAndGroups(tracks, groups, groupType)
        }
    }
    
    // Scrolls the playlist view to the very top
    private func scrollToTop() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    private func scrollToBottom() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
        }
    }
    
    // Selects the currently playing track, within the playlist view
    private func showPlayingTrack() {
        selectTrack(playbackInfo.getPlayingTrackGroupInfo(self.groupType))
    }
 
    // Refreshes the playlist view in response to a new track being added to the playlist
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        if let result = message.groupInfo[self.groupType] {

            if result.groupCreated {
                
                // If a new parent group was created, for this new track, insert the new group under the root
                playlistView.insertItems(at: IndexSet(integer: result.track.groupIndex), inParent: nil, withAnimation: .effectFade)
                
            } else {
                
                // Insert the new track under its parent group, and reload the parent group
                let group = result.track.group
                
                playlistView.insertItems(at: IndexSet(integer: result.track.trackIndex), inParent: group, withAnimation: .effectGap)
                playlistView.reloadItem(group)
            }
        }
    }
    
    // Refreshes the playlist view in response to a track being updated with new information
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        if let groupInfo = message.groupInfo[self.groupType] {
            
            // Reload the parent group and the track
            self.playlistView.reloadItem(groupInfo.group, reloadChildren: false)
            self.playlistView.reloadItem(groupInfo.track)
        }
    }
    
    // Refreshes the playlist view in response to tracks/groups being removed from the playlist
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        let removals = message.results.groupingPlaylistResults[self.groupType]!
        var groupsToReload = [Group]()
        
        for removal in removals {
            
            if let tracksRemoval = removal as? GroupedTracksRemovalResult {
                
                // Remove tracks from their parent group
                playlistView.removeItems(at: tracksRemoval.trackIndexesInGroup, inParent: tracksRemoval.parentGroup, withAnimation: .effectFade)
                
                // Make note of the parent group for later
                groupsToReload.append(tracksRemoval.parentGroup)
                
            } else {
                
                // Remove group from the root
                let groupRemoval = removal as! GroupRemovalResult
                playlistView.removeItems(at: IndexSet(integer: groupRemoval.groupIndex), inParent: nil, withAnimation: .effectFade)
            }
        }
        
        // For all groups from which tracks were removed, reload them
        groupsToReload.forEach({playlistView.reloadItem($0)})
    }
    
    private func trackChanged(_ notification: TrackChangedNotification) {
        
        let oldTrack = notification.oldTrack
        let newTrack = notification.newTrack
        
        if (oldTrack != nil) {
            
            playlistView.reloadItem(oldTrack!.track)
            let row = playlistView.row(forItem: oldTrack!.track)
            playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
        }
        
        if (newTrack != nil) {
            
            if !newTrack!.equals(oldTrack) {
                
                playlistView.reloadItem(newTrack!.track)
                let row = playlistView.row(forItem: newTrack!.track)
                playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
            }
            
            if layoutManager.isShowingPlaylist() {
                
                if let curViewGroupType = PlaylistViewState.current.toGroupType() {
                    
                    if curViewGroupType == self.groupType && playbackPreferences.showNewTrackInPlaylist {
                        showPlayingTrack()
                    }
                }
            }
            
        } else {
            
            if layoutManager.isShowingPlaylist() {
                
                if let curViewGroupType = PlaylistViewState.current.toGroupType() {
                    
                    if curViewGroupType == self.groupType && playbackPreferences.showNewTrackInPlaylist {
                        clearSelection()
                    }
                }
            }
        }
    }
    
    // Selects an item within the playlist view, to show a single result of a search
    private func handleSearchResultSelection(_ request: SearchResultSelectionRequest) {
        
        if PlaylistViewState.current == self.playlistType {
            
            // Select (show) the search result within the playlist view
            selectTrack(request.searchResult.location.groupInfo)
        }
    }
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        // This is a safe typecast, because the context menu will prevent this function from being executed on groups. In other words, the selected item will always be a track.
        let selTrack = playlistView.item(atRow: playlistView.selectedRow) as! Track
        FileSystemUtils.showFileInFinder(selTrack.file)
    }
    
    private func insertGap(_ gapBefore: PlaybackGap?, _ gapAfter: PlaybackGap?) {
        
        if let selTrack = playlistView.item(atRow: playlistView.selectedRow) as? Track {
            
            playlist.setGapsForTrack(selTrack, gapBefore, gapAfter)
            SyncMessenger.publishNotification(PlaybackGapUpdatedNotification(selTrack))
        }
    }
    
    private func removeGaps() {
        
        if let selTrack = playlistView.item(atRow: playlistView.selectedRow) as? Track {
            
            playlist.removeGapsForTrack(selTrack)
            SyncMessenger.publishNotification(PlaybackGapUpdatedNotification(selTrack))
        }
    }
    
    private func gapStarted(_ message: PlaybackGapStartedAsyncMessage) {
        
        var refreshTracks: [Track] = [message.nextTrack.track]
        
        if let oldTrack = message.lastPlayedTrack, !message.nextTrack.equals(oldTrack) {
            refreshTracks.append(oldTrack.track)
        }
        
        var refreshIndexSet: IndexSet = IndexSet([])
        refreshTracks.forEach({refreshIndexSet.insert(playlistView.row(forItem: $0))})
        
        // Don't include -1 when a row is not found
        refreshIndexSet = IndexSet(refreshIndexSet.filter({$0 >= 0}))
        
        // Playing track is no longer playing. One-time gaps may have been removed, so need to update the table view
        playlistView.reloadData(forRowIndexes: refreshIndexSet, columnIndexes: UIConstants.groupingPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: refreshIndexSet)
        
        let needToShowTrack: Bool = layoutManager.isShowingPlaylist() && PlaylistViewState.current == self.playlistType && playbackPreferences.showNewTrackInPlaylist
        if needToShowTrack {
            selectTrack(message.nextTrack.track)
        }
    }
    
    private func gapUpdated(_ message: PlaybackGapUpdatedNotification) {
        
        // Find track and refresh it
        let updatedRow = playlistView.row(forItem: message.updatedTrack)
        
        if updatedRow >= 0 {
            refreshRow(updatedRow)
        }
    }
    
    private func refreshSelectedRow() {
        refreshRow(playlistView.selectedRow)
    }
    
    private func refreshRow(_ row: Int) {
        
        playlistView.reloadData(forRowIndexes: IndexSet([row]), columnIndexes: UIConstants.groupingPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
    }
    
    func getID() -> String {
        return String(format: "%@-%@", self.className, String(describing: self.groupType))
    }
    
    // MARK: Message handlers
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .trackInfoUpdated:
            
            trackInfoUpdated(message as! TrackUpdatedAsyncMessage)
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        case .gapUpdatedNotification:
            
            gapUpdated(notification as! PlaybackGapUpdatedNotification)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .searchResultSelectionRequest:
            
            handleSearchResultSelection(request as! SearchResultSelectionRequest)
            
        default: break
            
        }
        
        // No meaningful response to return
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? PlaylistActionMessage {
            
            // Check if this message is intended for this playlist view
            if (msg.playlistType != nil && msg.playlistType != self.playlistType) {
                return
            }
            
            switch (msg.actionType) {
                
            case .refresh:
                
                refresh()
                
            case .removeTracks:
                
                removeTracks()
                
            case .showPlayingTrack:
                
                showPlayingTrack()
                
            case .playSelectedItem:
                
                playSelectedItemAction(self)
                
            case .moveTracksUp:
                
                moveTracksUp()
                
            case .moveTracksDown:
                
                moveTracksDown()
                
            case .moveTracksToTop:
                
                moveTracksToTop()
                
            case .moveTracksToBottom:
                
                moveTracksToBottom()
                
            case .scrollToTop:
                
                scrollToTop()
                
            case .scrollToBottom:
                
                scrollToBottom()
                
            case .showTrackInFinder:
                
                showTrackInFinder()
                
            case .invertSelection:
                
                invertSelection()
                
            case .cropSelection:
                
                cropSelection()
                
            default: return
                
            }
        }
        
        if let delayedPlaybackMsg = message as? DelayedPlaybackActionMessage {
            
            if delayedPlaybackMsg.playlistType == self.playlistType {
                
                playSelectedItemWithDelay(delayedPlaybackMsg.delay)
                return
            }
        }
        
        if let insertGapsMsg = message as? InsertPlaybackGapsActionMessage {
            
            // Check if this message is intended for this playlist view
            if insertGapsMsg.playlistType == self.playlistType {
                insertGap(insertGapsMsg.gapBeforeTrack, insertGapsMsg.gapAfterTrack)
            }
            
            return
        }
        
        if let removeGapMsg = message as? RemovePlaybackGapsActionMessage {
            
            if removeGapMsg.playlistType == self.playlistType {
                removeGaps()
            }
            
            return
        }
    }
}

extension IndexSet {

    // Convenience function to convert an IndexSet to an array
    func toArray() -> [Int] {
        return self.filter({$0 >= 0})
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}
