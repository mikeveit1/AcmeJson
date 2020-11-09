//
//  ViewController.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/15/20.
//

import UIKit
import QuickLook

class ViewController: UIViewController {

        @IBOutlet weak var navBar: UINavigationBar!
        @IBOutlet weak var backButton: UIBarButtonItem!
        @IBOutlet weak var tableView: UITableView!
        var activityView: UIActivityIndicatorView?
        var acmeResponse: AcmeResponse?
        var id = ""
        var idArray = [String]()
        var items = [Item]()
        var pageNumber = 0
        var fileURL:URL?
        
        enum AcmeResponseError: Error {
            case unsuccessful
        }
        
        func showErrorAlert(title: String, message:String ) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                                self.dismiss(animated: true, completion: nil) })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        func disableBackButton() {
            backButton.isEnabled = false
            backButton.tintColor = .clear
        }
        
        func enableBackButton() {
            backButton.isEnabled = true
            backButton.tintColor = .systemBlue
        }
        
        func showActivityIndicator() {
            if activityView == nil {
                disableBackButton()
                activityView = UIActivityIndicatorView(style: .large)
                activityView!.center = view.center
                view.addSubview(activityView!)
                activityView!.startAnimating()
            }
        }
        
        func hideActivityIndicator(){
            if activityView != nil {
                enableBackButton()
                activityView!.stopAnimating()
                activityView!.removeFromSuperview()
                activityView = nil
            }
        }
        
        func getData(id: String) {
            showActivityIndicator()
            DispatchQueue.global(qos: .background).async {
                self.items.removeAll()
                DataService.shared.getData(id: id) { (data) in
                    do {
                        let decoder = JSONDecoder()
                        let json = try decoder.decode(AcmeResponse.self, from: data)
                        self.acmeResponse = json
                        if self.acmeResponse?.success == false {
                            throw AcmeResponseError.unsuccessful
                        }
                        guard let acmeItems = self.acmeResponse?.response?.items else { return }
                        self.items.append(contentsOf: acmeItems)
                    } catch {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "Error", message: "Can't load data.")
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.navBar.topItem?.title = id == "" ? "Home" : id
                        self.hideActivityIndicator()
                    }
                } errorHandler: {(error: Error) -> () in
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
        
        func downloadAssetURL(itemURL: URL?, filename: String, currentIndex: Int) {
            showActivityIndicator()
            let quickLookViewController = QLPreviewController()
            quickLookViewController.dataSource = self
            DispatchQueue.global(qos: .background).async {
                guard let downloadURL = itemURL else { return }
                URLSession.shared.dataTask(with: downloadURL) { data, urlResponse, error in
                    guard let data = data, error == nil, urlResponse != nil else {
                        self.showErrorAlert(title: "Error", message: "Can't download asset from URL.")
                        return
                    }
                    do {
                        self.fileURL = FileManager().temporaryDirectory.appendingPathComponent(filename)
                        if let fileUrl = self.fileURL {
                            try data.write(to: fileUrl, options: .atomic)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "Error", message: "Can't find the URL resource.")
                        }
                    }
                    DispatchQueue.main.async {
                        quickLookViewController.currentPreviewItemIndex = currentIndex
                        self.present(quickLookViewController, animated: true)
                        self.hideActivityIndicator()
                    }
                } .resume()
            }
        }
        
        @IBAction func backButtonPressed(_ sender: Any) {
            idArray.removeLast()
            pageNumber -= 1
            getData(id: idArray[pageNumber])
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            idArray.append(id)
            getData(id: id)
        }
    }

    extension ViewController: UITableViewDataSource, UITableViewDelegate {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
            let currentItem = items[indexPath.row]
            
            if pageNumber == 0 {
                disableBackButton()
            } else {
                enableBackButton()
            }
            
            cell.title.text =  "\(String(currentItem.metadata.title ?? "no title")) (\(String(currentItem.itemCount)) items)"
            
            do {
                let data = try Data(contentsOf: (currentItem.thumbnail.url))
                DispatchQueue.main.async {
                    cell.thumbnail?.image = UIImage(data: data)
                }
            } catch {
                showErrorAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let clickedItem = items[indexPath.row]
            
            id = clickedItem.id
            
            if clickedItem.type == "folder" {
                idArray.append(clickedItem.id)
                getData(id: id)
                pageNumber += 1
            }
            
            if clickedItem.type == "file" && clickedItem.asset != nil {
                downloadAssetURL(itemURL: (URL(string: clickedItem.asset!.url!)!), filename: (clickedItem.asset?.filename ?? ""), currentIndex: indexPath.row)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if clickedItem.type == "file" {
                showErrorAlert(title: "Error", message: "Can't find asset for \(String(clickedItem.metadata.title ?? "item with id \(String(clickedItem.id))"))")
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

    extension ViewController: QLPreviewControllerDataSource {
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return fileURL! as QLPreviewItem
        }
    }

