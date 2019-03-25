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
    var appId = "07fd23b0e1ab50cdda21c5878a813c0e"
    var user: User?
    
    init(user: User?) {
        self.user = user
    }
    
    public func login(username: String, password: String, completion: @escaping (User) -> ()) {
        let url = URL(string: "\(self.apiUrl)/user/token")!
        
        let parameters: [String: String] = ["email": username, "password": password]
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.self, from: data!)
                self.user = user
                completion(user)
            } catch {
                print("ERROR Logging in")
            }
        })
        task.resume()
    }
    
    public func getGuides(completion: @escaping ([GuideSnippet]) -> ()) {
        let url: URL?
        print(self.user?.username as Any)
        if self.user?.username == "CSC 436" {
            print("GETTING USER THING")
            url = URL(string: "\(self.apiUrl)/users/\(1101176)/guides")!
        } else {
            url = URL(string: "\(self.apiUrl)/user/guides")!
        }
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            do {
                let decoder = JSONDecoder()
                let guideSnippets = try
                    decoder.decode([GuideSnippet].self, from: data!)
                completion(guideSnippets)
            } catch let error {
                print("Error serializing json: ", error)
            }
        })
        task.resume()
    }
    
    public func getGuide(guideid: Int, completion: @escaping (Guide) -> ()) {
        let url = URL(string: "\(self.apiUrl)/guides/\(guideid)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            do {
                let decoder = JSONDecoder()
                let guide = try
                    decoder.decode(Guide.self, from: data!)
                completion(guide)
            } catch let error {
                print("Error serializing response from getGuide: ", error)
            }
        })
        task.resume()
    }
    
    public func createGuide(category: String, type: String, subject: String?, completion: @escaping (Guide) -> ()) {
        let url = URL(string: "\(self.apiUrl)/guides")!
        
        let parameters: [String: String] = ["category": category, "type": type, "subject": subject ?? ""]
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            do {
                let decoder = JSONDecoder()
                let guide = try decoder.decode(Guide.self, from: data!)
                completion(guide)
            } catch let error {
                print("Couldn't create guide: ")
                print(error)
            }
        })
        task.resume()
    }
    
    public func updateGuide(guide: Guide, parameters: [String: Any], completion: @escaping (Guide) -> ()) {
        let url = URL(string: "\(self.apiUrl)/guides/\(guide.guideid)?revisionid=\(guide.revisionid)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            do {
                let jsonSerialized = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                print(jsonSerialized as Any)
            } catch {
                print("ERR")
            }
            
            do {
                let decoder = JSONDecoder()
                let guide = try decoder.decode(Guide.self, from: data!)
                completion(guide)
            } catch let error {
                print("Couldn't create guide: ")
                print(error)
            }
        })
        task.resume()
    }
    
    public func deleteGuide(guideid: Int, revisionid: Int, completion: @escaping (Bool) -> ()) {
        let url = URL(string: "\(self.apiUrl)/guides/\(guideid)?revisionid=\(revisionid)")!
        
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            completion(true)
        })
        task.resume()
    }
    
    public func addStep(guideid: Int, parameters: [String: Any], completion: @escaping (GuideStep) -> ()) {
//        let url = URL(string: "\(self.apiUrl)/guides/\(guideid)/steps")!
//
//        let session = URLSession.shared
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let stepLines = createLines(lines: lines)
//        let body = RequestBody(lines: stepLines)
//
//        do {
//            let encoder = JSONEncoder()
//            let jsonSerialized = try encoder.encode(body)
//            request.httpBody = jsonSerialized
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
//        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
//
//        let task = session.dataTask(with: request, completionHandler: { data, response, error in
//            do {
//                let decoder = JSONDecoder()
//                let updatedStep = try decoder.decode(GuideStep.self, from: data!)
//                completion(updatedStep)
//            } catch let error {
//                print("Couldn't create guide step: ")
//                print(error)
//            }
//        })
//        task.resume()
    }
    
    public func updateStep(step: GuideStep, completion: @escaping (GuideStep) -> ()) {
        let url = URL(string: "\(self.apiUrl)/guides/\(step.guideid)/steps/\(step.stepid)?revisionid=\(step.revisionid)")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let stepLines = createLines(lines: step.lines)
        let body = RequestBody(lines: stepLines)
        
        do {
            let encoder = JSONEncoder()
            let jsonSerialized = try encoder.encode(body)
            request.httpBody = jsonSerialized
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            do {
                let decoder = JSONDecoder()
                let updatedStep = try decoder.decode(GuideStep.self, from: data!)
                completion(updatedStep)
            } catch let error {
                print("Couldn't update guide step: ")
                print(error)
            }
        })
        task.resume()
    }
    
    public func createLines(lines: [GuideStep.GuideLine]) -> [StepLine] {
        var newLines = [StepLine]()
        
        for line in lines {
            newLines.append(StepLine(bullet: line.bullet, level: line.level, text: line.text_raw))
        }
        
        return newLines
    }
    
    public func getUserImages(user: User?, completion: @escaping ([MediaManagerImage]) -> ()) {
        let url = URL(string: "\(self.apiUrl)/user/media/images")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            do {
                let decoder = JSONDecoder()
                let images = try decoder.decode([MediaManagerImage].self, from: data!)
                completion(images)
            } catch let error {
                print("Couldn't get user images: ")
                print(error)
            }
        })
        task.resume()
    }
    
    public func uploadToMediaManager(image: UIImage, filename: String, completion: @escaping (MediaManagerImage) -> ()) {
        print(filename)
        let url = URL(string: "\(self.apiUrl)/user/media/images?file=\(filename).png")!
        
        let imageData = UIImage.pngData(image)
        
        var request = URLRequest(url: url)
        request.addValue(self.appId, forHTTPHeaderField: "X-App-Id")
        request.addValue("api \(self.user!.authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let task = URLSession.shared.uploadTask(with: request, from: imageData()) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
            }
            
            if let mimeType = response.mimeType, mimeType == "application/json", let data = data {
                do {
                    let decoder = JSONDecoder()
                    let mediaImage = try decoder.decode(MediaManagerImage.self, from: data)
                    completion(mediaImage)
                } catch let error {
                    print("Couldn't get user images: ")
                    print(error)
                }
            }
        }
        task.resume()
    }
}
