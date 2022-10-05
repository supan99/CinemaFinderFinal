//
//  UserModel.swift
//  CinemaFinder

import Foundation



class UserModel {
    var docID: String
    var fullName: String
    var contactNumber: String
    var email: String
//    var password: String
//    var profile: String
    
    
    init(docID: String,fullName: String, email: String, contactNumber: String) {
        self.docID = docID
        self.fullName = fullName
        self.email = email
        self.contactNumber = contactNumber
       // self.password = password
       // self.profile = profile
    }
}

