//
//  AgenciasTableViewController.swift
//  Mockathon
//
//  Created by Luiz Fernando Dias on 11/01/17.
//  Copyright © 2017 Luiz Fernando Dias. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class AgenciasTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var lat = ""
    var long = ""
    var agencia = Agencia()
    var listaAgencias = [Agencia]()
    var locManager: CLLocationManager!
    var foi = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (CLLocationManager.locationServicesEnabled())
            
        {
            
            locManager = CLLocationManager()
            
            locManager.requestWhenInUseAuthorization()
            
            
            
            locManager.delegate = self;
            
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            
            locManager.requestAlwaysAuthorization()
            
            locManager.startUpdatingLocation()
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        lat = "\(locValue.latitude)"
        long = "\(locValue.longitude)"
        
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        
        if !foi {
            foi = true
            startNetworking()
        }
        
    }
    
    func startNetworking() {
        
        let urlPath = ("http://urldoservico.com.br/agencias?Raio=5000&PosicaoRelativa=\(lat),\(long)")
        let url = NSURL(string: urlPath)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET" // make it post if you want
        request.addValue("enterapikeyhere", forHTTPHeaderField: "apikey")
        //request.addValue(userid, forHTTPHeaderField: "uid")
        //request.addValue(hash, forHTTPHeaderField: "hash")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let data = data,
                let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue), error == nil {
                //                print(jsonString)
                //                let dicAgencias = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                let json = JSON(data: data)
                let i = 0
                for (key,subJson):(String, JSON) in json {
                    let prefixo = subJson["prefixo"].stringValue
                    let nome = subJson["nome"].stringValue
                    let latitude = subJson["latitude"].stringValue
                    let longitude = subJson["longitude"].stringValue
                    let agenciaX = Agencia()
                    agenciaX.nome = nome
                    agenciaX.prefixo = prefixo
                    agenciaX.latitude = latitude
                    agenciaX.longitude = longitude
                    print("\(agenciaX)")
//                    self.listaAgencias.append(self.agencia)
                    
                    
                    self.listaAgencias.append(agenciaX)
//                    i = i+1
//                    if (i > 10) {
//                        break
//                    }
                }
                print("\(self.listaAgencias)")
                self.tableView.reloadData()
            } else {
                print("error=\(error!.localizedDescription)")
            }
        })
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if listaAgencias.count > 0 {
            return 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if listaAgencias.count > 0 {
            return listaAgencias.count
        } else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        if listaAgencias.count != 0 {
            cell.textLabel?.text = listaAgencias[indexPath.row].nome
            cell.detailTextLabel?.text = listaAgencias[indexPath.row].prefixo
        } else {
            cell.textLabel?.text = "Carregando..."
            cell.detailTextLabel?.text = " "
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let agenciaRow = listaAgencias[indexPath.row]
        
        UIApplication.shared.openURL(NSURL(string: "waze://?ll=\(agenciaRow.latitude),\(agenciaRow.longitude)&navigate=yes")! as URL)
        
        print(agenciaRow)
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
