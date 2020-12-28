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
    @FetchRequest(entity: FilteredItem.entity(), sortDescriptors:[]) var filteredItems: FetchedResults<FilteredItem>
    
    var body: some View {
        TabView {
            WorkoutView(config: config, fetcher: WorkoutFetcher(config: config, filteredWords: filteredItems.map{$0.filteredWord ?? ""}))
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
