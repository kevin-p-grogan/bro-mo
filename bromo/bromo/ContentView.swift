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
    @ObservedObject var fetcher = MovieFetcher()
    
    var body: some View {
        VStack {
            List(fetcher.movies) { movie in
                VStack (alignment: .leading) {
                    Text(movie.name)
                    Text(movie.released)
                        .font(.system(size: 11))
                        .foregroundColor(Color.gray)
                }
            }
            Text("asdf")
        }
    }
}

public class MovieFetcher: ObservableObject {

    @Published var movies = [Movie]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "https://gist.githubusercontent.com/rbreve/60eb5f6fe49d5f019d0c39d71cb8388d/raw/f6bc27e3e637257e2f75c278520709dd20b1e089/movies.json")!
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Movie].self, from: d)
                    DispatchQueue.main.async {
                        self.movies = decodedLists
                    }
                }else {
                    print("No Data")
                }
            } catch {
                print ("Error")
            }
            
        }.resume()
         
    }
}

struct Movie: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var released: String
    
    enum CodingKeys: String, CodingKey {
           case id = "id"
           case name = "title"
           case released = "year"
        }
}

struct WorkoutGenerator_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
