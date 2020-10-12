//
//  ContentView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import Foundation
import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var fetcher = WorkoutFetcher()
    
    var body: some View {
        VStack {
            List(fetcher.workout) { exercise in
                VStack (alignment: .leading) {
                    Text(exercise.name)
                    Text(exercise.setsAndReps)
                        .font(.system(size: 11))
                        .foregroundColor(Color.gray)
                }
            }
        }
    }
}

public class WorkoutFetcher: ObservableObject {

    @Published var workout = [Exercise]()
    
    init(){
        load()
    }
    
    func load() {
        let parameters = GeneratorParameters(workout: "Upper Pull", week: "Test")
        let url = URL(string: "https://bro-science-stage.herokuapp.com/generate")!
        
        let encoder = JSONEncoder()
        guard let uploadData = try? encoder.encode(parameters) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData


        // insert json data to the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let d = data {
                let decoder = JSONDecoder()
                do {
                    let decodedLists = try decoder.decode([Exercise].self, from: d)
                    DispatchQueue.main.async {
                        self.workout = decodedLists
                    }
                }
                catch {
                    print("Unexpected error: \(error).")
                }
                print(d)
                // Handle HTTP request response
            } else {
                print("Uh oh, spaghetti-os")
                // Handle unexpected error
            }
        }
        
        task.resume()
         
    }
}

struct Exercise: Codable, Identifiable {
    public var name: String
    public var setsAndReps: String
    public var id: String
    
    enum CodingKeys: String, CodingKey {
           case name = "Exercise"
           case setsAndReps = "Sets and Reps"
           case id = "Type"
        }
}


struct GeneratorParameters: Codable {
    let workout: String
    let week: String
}


struct WorkoutGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
