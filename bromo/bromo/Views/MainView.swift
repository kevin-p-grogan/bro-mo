//
//  MainView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/18/20.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var config = Configuration()
    
    var body: some View {
        TabView {
            WorkoutView(config: config, scheduler: WorkoutScheduler().make(config))
                .tabItem {
                    Image(systemName: "bolt.heart")
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
        .accentColor(.red)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
