//
//  MovieModel.swift


import Foundation

class MovieModel {
    
    var name: String
    var docID: String
    var starCast: String
    var dName: String
    var imageurl: String
    
    init(docID: String,name:String,starCast:String,dName:String,imageurl: String) {
        self.name = name
        self.docID = docID
        self.starCast = starCast
        self.dName = dName
        self.imageurl = imageurl
    }
}
