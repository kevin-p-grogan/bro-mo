//
//  MainView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/18/20.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var config = Configuration()
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        TabView {
            WorkoutGeneratorView(config: config)
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Generate Workout")
                }.environment(\.managedObjectContext, context)
            LogView()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Exercise Log")
                }.environment(\.managedObjectContext, context)
            ConfigurationView(config: config)
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Configure")
                }
            FormInspectorView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Inspect Form")
                }
        }
        .font(.headline)
        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
