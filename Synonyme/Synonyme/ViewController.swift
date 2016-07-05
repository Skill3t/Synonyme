//
//  ViewController.swift
//  Synonyme
//
//  Created by Lars Lengersdorf on 01.07.16.
//  Copyright © 2016 Lars Lengersdorf. All rights reserved.
//

import UIKit
enum APIError: ErrorType{
    case ConnectionError
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{

    var synonyme = [String](){
        didSet{
            if synonyme.count > 0 {
                emptyLabel.hidden = true
            }else{
                emptyLabel.hidden = false
            }
            tableView.reloadData()
        }
    }
    var emptyLabel = UILabel()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saeachfield: UITextField!
    @IBAction func goTapped(sender: AnyObject) {
        dismissKeyboard()
        var searchterm = saeachfield.text!
        activityIndicator.startAnimating()
        
        searchterm = searchterm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        getSynonyms(searchterm)
    }
    
    
    func getSynonyms(forString: String) -> Void{
    
        fetchSynonyms(forString){
            (jsonDictonary) in
            var foundSynonyms = [String]()
            let termlist = jsonDictonary["synsets"] as! NSArray
            for synsetData in termlist{
                let currentset =  synsetData as! NSDictionary
                for currentTerms in currentset["terms"] as! NSArray{
                    let term = currentTerms as! NSDictionary
                    foundSynonyms.append(term["term"] as! String)
                }
            }
            self.activityIndicator.stopAnimating()
            self.synonyme = foundSynonyms
        }
    }
    
    func fetchSynonyms(forString:String, callMe: (jsonDictonary: NSDictionary) -> Void){
        
        let baseUrl : String = "https://www.openthesaurus.de/synonyme/"
        let name : String = "search?q="+forString+"&format=application/json"
        let encodedName = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        //var encodedName = name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let finalUrl = baseUrl + encodedName!
        
        let apiUrl = NSURL(string: finalUrl)
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            let jsonResponse = NSData(contentsOfURL: apiUrl!)
            //try catch
            do{
                guard let jsonResponse = jsonResponse else{
                    throw APIError.ConnectionError
                }
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options: []) as! NSDictionary
                dispatch_async(dispatch_get_main_queue()){
                    callMe(jsonDictonary:jsonDict)
                }
            }catch{
                print(error)
                //Main que
                dispatch_async(dispatch_get_main_queue()){
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEmptyLable()
        // Do any additional setup after loading the view, typically from a nib.
        self.saeachfield.delegate = self;
        self.hideKeyboardWhenTappedAround()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emptyLabel.frame = tableView.bounds
    }
    func addEmptyLable(){
        emptyLabel.font = emptyLabel.font.fontWithSize(20)
        emptyLabel.numberOfLines = 1
        emptyLabel.text = "Keine Synonyme gefunden"
        emptyLabel.textAlignment = NSTextAlignment.Center
        emptyLabel.textColor = UIColor.lightGrayColor()
        emptyLabel.hidden = false
        tableView.addSubview(emptyLabel)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: DataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("synonymcell")!
        cell.textLabel!.text = synonyme[indexPath.row]
        return cell
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Anzahl der Spalten
        return synonyme.count
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
}

