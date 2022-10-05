//
//  TheaterModel.swift

import Foundation


class TheaterModel {
    
    var name: String
    var docID: String
    var location: String
    
    init(docID: String,name:String,location:String) {
        self.name = name
        self.docID = docID
        self.location = location
    }
}
