import Foundation

protocol GroupingPlaylistAccessorProtocol {
    
    func groupAtIndex(_ index: Int) -> Group
    
    func numberOfGroups() -> Int
    
    func groupType() -> GroupType
 
    func groupingInfoForTrack(_ track: Track) -> GroupedTrack
    
    func indexOfGroup(_ group: Group) -> Int
    
    func displayNameForTrack(_ track: Track) -> String
    
    // Searches the playlist, given certain query parameters, and returns all matching results
    func search(_ searchQuery: SearchQuery) -> SearchResults
}

protocol GroupingPlaylistMutatorProtocol: CommonPlaylistMutatorProtocol {
    
    // Adds a single track to the playlist, and returns its index within the playlist.
    func addTrack(_ track: Track) -> GroupedTrackAddResult
    
    func removeTracksAndGroups(_ tracks: [Track], _ groups: [Group]) -> [ItemRemovalResult]
    
    func moveTracksAndGroupsUp(_ tracks: [Track], _ groups: [Group]) -> ItemMoveResults
    
    func moveTracksAndGroupsDown(_ tracks: [Track], _ groups: [Group]) -> ItemMoveResults
    
    func dropTracksAndGroups(_ tracks: [Track], _ groups: [Group], _ dropParent: Group?, _ dropIndex: Int) -> ItemMoveResults
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}

protocol GroupingPlaylistCRUDProtocol: GroupingPlaylistAccessorProtocol, GroupingPlaylistMutatorProtocol {}
