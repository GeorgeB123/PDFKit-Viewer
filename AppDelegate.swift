//
//  AppDelegate.swift
//  PDF-Kit
//
//  Created by George Bonnici-Carter on 9/21/16.
//  Copyright © 2016 George Bonnici-Carter. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate{

    //All Outlets linked up to appropriate sources
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var ourPDF: PDFView!
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var totalPageDisplay: NSTextField!
    @IBOutlet weak var choosePage: NSTextField!
    @IBOutlet weak var bookmarks: NSPopUpButton!
    @IBOutlet weak var about: NSMenuItem!
    @IBOutlet weak var pdfDirectory: NSComboBox!
    @IBOutlet weak var currentPageNumber: NSTextField!
    @IBOutlet weak var notepad: NSTextField!
    @IBOutlet weak var searchBar: NSSearchField!
    @IBOutlet weak var rightSearch: NSButton!
    @IBOutlet weak var leftSearch: NSButton!
    @IBOutlet weak var totalCount: NSTextField!
    @IBOutlet weak var helpPanel: NSView!
    @IBOutlet weak var helpString: NSTextField!
    @IBOutlet weak var searchCount: NSTextField!
    
    //local variables declared
    internal var pdf: PDFDocument
    internal var documents: [PDFClass] = Array<PDFClass>()
    internal var currentPage: Int
    internal var pdfCount: Int
    internal var currentPDF: Int
    internal var exists: Bool
    internal var searchNum: Int
    internal var searchVals = [AnyObject]()

    //initialization of local variables
    override init(){
        currentPage = 1
        pdfCount = 0
        currentPDF = 0
        pdf = PDFClass()
        documents = Array()
        exists = false
        searchNum = 0
        searchVals = Array()
    }
    
    //functions executed on startup
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let size: NSRect = NSMakeRect(400, 400, 420, 450)//setting the panel
        helpPanel.window?.setIsVisible(false)
        helpPanel.window?.setFrame(size, display: true)
        helpPanel.window?.title = "Help Menu"
        helpString.stringValue = "\n Open PDF: Allows a user open one or more pdf documents.\n\n Zoom in/Zoom out: Allows a user zoom in and out of document.\n\n Fit to Screen: Fits a document to the appropriate screen size.\n\n Previous/Next Page: Allows a user navigate within a document.\n\n Go to Page: Allows a user go to a specified page within a document.\n\n Bookmark Page: Allows a user to save a specific page in a specific document for future reference. These bookmarks are displayin the drop down button below.\n\n Notes: Allows a user to add notes to a specific page in a specific document. Notes must be added by clicking the 'Add notes'button.\n\n Search: Allows a user to search for a certain word or character within a document.You can cycle through results with the buttons either side. \n\n Previous/Next PDF: Allows a user to navigate between recently opened PDFs.\n\n Choose PDF: Allows a user to open a specific document among recently opened documents."
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(choosePDF), name: NSComboBoxSelectionDidChangeNotification, object: nil) //button listener for pop down button
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePageCount), name: PDFViewPageChangedNotification, object: nil) //button listener for page change
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    //open PDF function using completionHandler appending docs to a documents array
    @IBAction func openPDF(sender: NSToolbarItem) {
        let panel: NSOpenPanel = NSOpenPanel()
        panel.allowedFileTypes = ["pdf"]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.beginWithCompletionHandler { (result) -> Void in
            if(result == NSFileHandlingPanelOKButton){
                for index in 0...panel.URLs.count-1{
                    self.exists = true
                    self.currentPageNumber.stringValue = "1"
                    self.pdfCount += 1
                    self.currentPDF += 1
                    let newURL = panel.URLs[index]
                    self.pdf = PDFClass(URL: newURL)
                    self.pdfDirectory.addItemWithObjectValue((panel.URLs[index].lastPathComponent)!)
                    self.documents.append(self.pdf as! PDFClass)
                    self.ourPDF.setDocument(self.documents[self.pdfCount-1])
                    self.updatePDF(self.documents[self.pdfCount-1] )
                }

            }
        }
    }
    
    //Zoom out function
    @IBAction func zoomOut(sender: NSToolbarItem) {
        if(ourPDF.canZoomOut()){
            ourPDF.zoomOut(toolbar)
        }
    }
    
    //Zoom in function
    @IBAction func zoomIn(sender: NSToolbarItem) {
        if(ourPDF.canZoomIn()){
            ourPDF.zoomIn(toolbar)
        }
    }

    //Fit to screen function
    @IBAction func fitToScreen(sender: NSToolbarItem) {
        ourPDF.setAutoScales(true)
    }
    
    //Next page function, increments page count
    @IBAction func nextPage(sender: NSToolbarItem) {
        if(ourPDF.canGoToNextPage()){
            currentPage += 1
       
            ourPDF.goToNextPage(window)
         }
    }
    
    //Previous page function, decrements page count
    @IBAction func previousPage(sender: NSToolbarItem) {
        if(ourPDF.canGoToPreviousPage()){
            currentPage -= 1
            ourPDF.goToPreviousPage(window)
        }
    }
    

    //allows user to add notes on specific page
    @IBAction func addNotes(sender: NSButton) {
        if exists{
            let page = String(documents[currentPDF-1].indexForPage(ourPDF.currentPage()));
            let name = documents[currentPDF-1].documentURL().lastPathComponent!;
        
            documents[currentPDF-1].notesArray[name+page] = notepad.stringValue;
        }
    }
    
    
    //user can go to previous PDF in the documents array
    @IBAction func prevPDF(sender: NSButton) {
        if exists{
        if(pdfCount > 0 && currentPDF > 1){ //FIX LATER?
            currentPDF -= 1
            ourPDF.setDocument(documents[currentPDF-1])
            updatePDF(documents[currentPDF-1] )
            updatePageCount(documents[currentPDF-1])
            pdf = documents[currentPDF-1]
            
        }else{}
        
        }
    }
    
    //user can go to next PDF in the documents array
    @IBAction func nextPDF(sender: NSButton) {
        if exists{
        if(currentPDF < documents.count){
            currentPDF += 1
            print("\(self.currentPDF)")
            print("\(documents)")
            ourPDF.setDocument(documents[currentPDF-1])
            updatePDF(documents[currentPDF-1])
            updatePageCount(documents[currentPDF-1])
            self.pdf = documents[currentPDF-1]

        }else{}
        }
    }

    //User can go to a chosen page, current page is then updated
    @IBAction func pageChoice(sender: NSTextField) {
        if exists{
        if(choosePage.stringValue != ""){
            if(currentPage > pdf.pageCount() || currentPage < 1){
                
            }else{
                if(Int(choosePage.stringValue) != nil){
                    ourPDF.goToPage(pdf.pageAtIndex(Int(sender.stringValue)!-1))
                }
            }
        }
        }
    }
    
    //allows user to save a bookmark in bookmarkArray that is extended by the PDFClass()
    @IBAction func bookmark(sender: NSButton) {
        if exists{
            let mark: String = /*"page " +*/ (String)(documents[currentPDF-1].indexForPage(ourPDF.currentPage())+1)
            documents[currentPDF-1].bookmarkArray.append(mark)
            bookmarks.addItemWithTitle(mark)
        }
 
    }
    
    //displays bookmarks for a certain PDF
    @IBAction func savedPages(sender: NSPopUpButton) {
        if exists{
            let item: String = documents[currentPDF-1].bookmarkArray[(Int)(sender.indexOfSelectedItem)]
            ourPDF.goToPage(documents[currentPDF-1].pageAtIndex(((Int)(item)!)-1))
        }
    }
    
    //Jumps to the index of the PDf in the documents array
    @IBAction func choosePDF(sender: NSComboBox) {
        if(pdfDirectory.indexOfSelectedItem != -1){
            let index: Int = pdfDirectory.indexOfSelectedItem
            ourPDF.setDocument(documents[index])
            currentPDF = index+1 // +1
            updatePDF(documents[currentPDF-1])
            self.pdf = documents[currentPDF-1]
        }
    }
    

    //Allows user to search for a given word or character
    @IBAction func search(sender: NSSearchField) {
        if exists{
            searchBar.sendsSearchStringImmediately = true
            let searchString: String = searchBar.stringValue
            if(searchString != ""){
                leftSearch.hidden = false
                rightSearch.hidden = false
                
                searchVals = documents[currentPDF-1].findString(searchBar.stringValue, withOptions: 1)
                if(!searchVals.isEmpty){
                    searchCount.stringValue = "1"
                    searchNum = 0
                    totalCount.stringValue = "/ " + searchVals.endIndex.description
                    wordFind()
                    
                }
            }else{
                searchCount.stringValue = ""
                totalCount.stringValue = ""
                leftSearch.hidden = true
                rightSearch.hidden = true
                ourPDF.setHighlightedSelections(nil)
            }
        }
    }
    
    //jumps to the next word highlighted in the array of values
    @IBAction func nextWord(sender: NSButton) {
        if exists{
            if(searchNum < searchVals.count-1){
                searchNum += 1
                wordFind()
            }
        }
    }
    
    //jumps to the previous word highlighted in the array of values
    @IBAction func previousWord(sender: NSButton) {
        if exists{
            if(searchNum > 0){
                searchNum -= 1
                wordFind()
            }
        }
    }
    
    //causes the help menu to pop up
    @IBAction func help(sender: NSButton) {
        helpPanel.window?.setIsVisible(true)
        
    }
    
    //helper function Updates the display when a new PDF is displayed
    func updatePDF(sender: PDFDocument){
        totalPageDisplay.stringValue = "/ " + sender.pageCount().description
        window.title = sender.documentURL().lastPathComponent!
        currentPageNumber.stringValue = "1"
        bookmarks.removeAllItems()
        bookmarks.addItemsWithTitles(documents[currentPDF-1].bookmarkArray)
            
        
    }
    
    //helper function which updates page count and also updates the notes for that certain page
    internal func updatePageCount(sender: PDFDocument){
        
        var tempInt: Int = pdf.indexForPage(ourPDF.currentPage())
        if(tempInt == Int.max){
            tempInt = 1
        }else{
            tempInt = pdf.indexForPage(ourPDF.currentPage())+1
        }
        if((currentPageNumber.stringValue) != String(tempInt)){
            
            print(tempInt)
            self.currentPageNumber.stringValue = String(tempInt)
            
            currentPage = (Int)(currentPageNumber.stringValue)!
        }else{}
        
        let pagex = String(documents[currentPDF-1].indexForPage(ourPDF.currentPage()));
        let namex = documents[currentPDF-1].documentURL().lastPathComponent!;
        if(documents[currentPDF-1].notesArray[namex+pagex] != nil){
            notepad.stringValue = documents[currentPDF-1].notesArray[namex+pagex]!
        }else{
            notepad.stringValue = "";
        }
    }
    
    //helper search function which allows the highlighted word to be found
    func wordFind(){
        ourPDF.goToSelection(searchVals[searchNum] as! PDFSelection)
        for i in searchVals{
            i.setColor(NSColor(red: 0.5, green: 1, blue: 0.5, alpha: 1))
        }
        
        searchCount.stringValue = (searchNum+1).description
        searchVals[searchNum].setColor(NSColor(red: 1, green: 1, blue: 0, alpha: 1))
        ourPDF.setHighlightedSelections(searchVals)
    }
    
}
