//
//  MainView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/18/20.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            WorkoutGeneratorView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Generate Workout")
                }
            FormInspectorView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Inspect Form")
                }
        }
        .font(.headline)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
