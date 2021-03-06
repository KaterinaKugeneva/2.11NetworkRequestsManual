//
//  MainTableViewController.swift
//  2.10NetworkRequests
//
//  Created by Ekaterina Kugeneva on 26.11.2021.
//

import UIKit
import Alamofire

class MainTableViewController: UITableViewController {
    
    private var persons: [Person] = []
    private var info : WebInformation?
    private var currentPage = "https://rickandmortyapi.com/api/character/?page=1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        print (currentPage)
        //fetchData(url: currentPage)
        manualJSON(url: currentPage)
        
        
    }
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        currentPage = info?.info.next ?? "https://rickandmortyapi.com/api/character/?page=42"
        manualJSON(url: currentPage)
    }
    @IBAction func buttunBackpressed(_ sender: UIBarButtonItem) {
        currentPage = info?.info.prev ?? "https://rickandmortyapi.com/api/character/?page=1"
        manualJSON(url: currentPage)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        persons.count    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonCell
        let person = persons[indexPath.row]
        
        cell.configure(with: person)
        return cell
    }
    private func fetchData(url: String?) {
        NetworkManager.shared.fetchData(from: url) { info in
            self.info = info
            self.persons = self.info!.results
            self.tableView.reloadData()
        }
    }
    
    private func manualJSON (url: String) {
        self.persons.removeAll()
            AF.request(url)
               .validate()
               .responseJSON { dataResponse in
                switch dataResponse.result {
                case .success(let value):
                    guard let receivedData = value as? [String: Any] else { return }
                    
                    guard let infoData = receivedData["info"] as? [String: Any] else { return }
                    let info = Info(infoData: infoData)
                    
                    guard let charactersData = receivedData["results"] as? [[String: Any]] else { return }
                    for characterData in charactersData {
                        print(characterData)
                        guard let location = characterData["location"] as? [String: Any] else { return }
                        let personLocation = Location(location: location)
                        let person = Person(characterData: characterData, personLocation: personLocation)
                        self.persons.append(person)
                    }
                    let webInformation = WebInformation(info: info, results: self.persons)
                    self.info = webInformation
                    
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print (error)
                }
            }
        }
}
