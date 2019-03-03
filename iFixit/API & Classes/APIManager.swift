//
//  Request.swift
//  iFixit
//
//  Created by Tanner Villarete on 1/29/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class APIManager {
    let apiUrl = "https://www.ifixit.com/api/2.0"
    var user: User?
    
    init(user: User?) {
        self.user = user
    }
    
    public func login(username: String, password: String, completion: @escaping (User?, Error?) -> ()) {
        let url = URL(string: "\(self.apiUrl)/user/token")!
        
        let parameters: [String: String] = ["email": username, "password": password]
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // iFixit App-Id
        request.addValue("07fd23b0e1ab50cdda21c5878a813c0e", forHTTPHeaderField: "X-App-Id")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                self.user = try decoder.decode(User.self, from: data)
                completion(self.user, nil)
            } catch let error {
                completion(nil, error)
            }
        })
        task.resume()
    }
    
    public func getGuides(completion: @escaping ([GuideSnippet]) -> ()) {
        //let userid = user!.userid
        let url = URL(string: "\(self.apiUrl)/users/\(1101176)/guides")!
        print(url)
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                print(error ?? "Unexpected error")
                return
            }
            guard let data = data else {
                print("No data found")
                return
            }
            do {
                //create json object from data
                
                let decoder = JSONDecoder()
                let guideSnippets = try
                    decoder.decode([GuideSnippet].self, from: data)
                completion(guideSnippets)
            } catch let error {
                print("Error serializing json: ", error)
            }
        })
        task.resume()
    }
    
    public func getGuide(guideid: Int, completion: @escaping (Guide) -> ()) {
        //let userid = user!.userid
        print("Getting Guide \(guideid)")

        let url = URL(string: "\(self.apiUrl)/guides/\(guideid)")!
        print(url)
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                print(error ?? "Unexpected error")
                return
            }
            guard let data = data else {
                print("No guide data found")
                return
            }
            do {
                //create json object from data
                
                let decoder = JSONDecoder()
                let guide = try
                    decoder.decode(Guide.self, from: data)
                completion(guide)
            } catch let error {
                print("Error serializing json: ", error)
            }
        })
        task.resume()
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
                self.fadeIn()
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    func addCornerRadius(value: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = value
    }
}
