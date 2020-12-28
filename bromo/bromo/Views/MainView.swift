//
//  MainView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/18/20.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var config = Configuration()
    
    var body: some View {
        TabView {
            WorkoutGeneratorView(config: config, fetcher: WorkoutFetcher(config: config))
                .tabItem {
                    Image(systemName: "bolt.circle")
                }
            LogView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                }
            ConfigurationView(config: config)
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                }
        }
        .font(.headline)
        .preferredColorScheme(.dark)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
