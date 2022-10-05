//
//  BookingModel.swift
//  CinemaFinder

import Foundation

class BookingModel {
    var docID: String!
    var date: String!
    var time: String!
    var seats: String!
    var tID: String!
    var mID: String!
    var totalPayment: String!
    
    init(docID: String,date: String, time: String, seats: String, tID: String,mID: String,totalPayment: String) {
        self.docID = docID
        self.date = date
        self.time = time
        self.seats = seats
        self.mID = mID
        self.tID = tID
        self.totalPayment = totalPayment
    }
}
