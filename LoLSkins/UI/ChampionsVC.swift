//
//  ChampionsVC.swift
//  LoLSkins
//
//  Created by Zbigniew Górawski on 10.07.2016.
//  Copyright © 2016 Zbigniew Górawski. All rights reserved.
//

import UIKit
import AlamofireImage

class ChampionsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchPlaceholderView: UIView!
    
    fileprivate let championsCellRI = "ChampionsCellRI"
    fileprivate var champions: [ChampionsVM] = [] { didSet { filter(filter) }}
    fileprivate var filtered: [ChampionsVM] = []
    fileprivate var filter: String? = nil

    
    // MARK: dependencies
    
    fileprivate var championsPresenter: ChampionsPresenter!
    fileprivate var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        championsPresenter = ChampionsPresenter(subscriber: self)
        
        collectionView.dataSource = self        
        collectionView.delegate = self
        
        // configure search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .black
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        
        searchPlaceholderView.addSubview(searchController.searchBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.sizeToFit()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func filter(_ filter: String?) {
        
        defer {
            collectionView.reloadData()
        }
        
        guard let f = filter, !f.isEmpty else {
            filtered = champions
            searchController.searchBar.placeholder = "Search"
            return
        }
        
        searchController.searchBar.placeholder = f
        filtered = champions.filter({ $0.key.lowercased().contains(f.lowercased())})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let model = sender as? ChampionsVM,
            segue.identifier == "showSkins",
            let vc = segue.destination as? ChampionSkinVC {
            
            vc.championId = model.key
        }
    }
}

extension ChampionsVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter(nil)
    }
}

extension ChampionsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {

        guard searchController.isActive else { return }
        filter(searchController.searchBar.text)
    }
}

extension ChampionsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: championsCellRI, for: indexPath)
        
        if let championsCell = cell as? ChampionsCell {
            
            let championVM = filtered[indexPath.item]
            championsCell.backgroundColor = UIColor(randomString: championVM.key)
            championsCell.portraitImageView.af_setImage(withURL: championVM.imageUrl)
        }
        
        return cell
    }
}


extension ChampionsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 64, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showSkins", sender: filtered[indexPath.item])
    }
}

extension ChampionsVC: ChampionsPresenterSubscriber {
    
    func present(champions: [ChampionsVM]) {
        self.champions = champions
    }
    
    func show(error: ErrorVM) {
        print("error: \(error.title): \(error.message)")
    }
    
}