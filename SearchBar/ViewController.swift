//
//  ViewController.swift
//  SearchBar
//
//  Created by Admin on 04/09/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var nameOfCity = [String]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameOfCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")!
        cell.textLabel?.text = self.nameOfCity[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(self.nameOfCity[indexPath.row])
        //search of weather
        self.showSearchResult(status: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        if (!searchText.isEmpty){
            self.searchCity(nameCity: searchText)
        }else{
            self.showSearchResult(status: true)
        }
    }
    
    func searchCity(nameCity: String) {
        
        self.nameOfCity.removeAll()
        
        let urlString = "https://api.teleport.org/api/cities/?search=\(nameCity.replacingOccurrences(of: " ", with: "%20"))"
        print(urlString)
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!){(data,response,error) in
            do{
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    as?  [String : AnyObject]{
                    
                    if let _embedded = json["_embedded"] as? (AnyObject){
                        
                        if let search_results = _embedded["city:search-results"] as? Array<Dictionary<String, AnyObject>>{
                            
                            for search_result in search_results{
                                
                                if let matching_alternate_names = search_result["matching_alternate_names"] as? Array<Dictionary<String, AnyObject>>{
                                    for matching_alternate_name in matching_alternate_names{
                                        
                                        self.nameOfCity.append(matching_alternate_name["name"] as! String)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (!self.nameOfCity.isEmpty){
                    
                    self.showSearchResult(status: false)
                }else{
                    self.showSearchResult(status: true)
                }
            }
            catch let jsonError{
                print(jsonError)
            }
        }
    
        task.resume()
    }
    
    func showSearchResult(status: Bool){
        DispatchQueue.main.async {
    
            self.tableView.isHidden = status
            
            self.tableView.reloadData()
            
        }
    }
    
}


