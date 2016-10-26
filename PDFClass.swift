//
//  PDFClass.swift
//  PDF-Kit
//
//  Created by George Bonnici-Carter on 9/26/16.
//  Copyright © 2016 George Bonnici-Carter. All rights reserved.
//

import Foundation
import Quartz

//extending the document class so it can hold bookmarks and notes
public class PDFClass: PDFDocument{
    
    //initializing bookmarkArray and notesArray
    override init(){
        bookmarkArray = Array()
        notesArray = [String:String]();
        super.init()
    }
    
    override init(URL url: NSURL!){
        bookmarkArray = Array()
        notesArray = [String:String]();
        super.init(URL: url)
    }
    
    
    //declaring variables
    public var bookmarkArray: [String]
    public var notesArray: [String:String];
    //public var notes: [String]
    
}