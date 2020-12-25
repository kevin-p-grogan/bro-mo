//
//  bromoApp.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import SwiftUI

@main
struct bromoApp: App {
    let context = PersistenceController.sharedContext
    let test = allLifts
    var body: some Scene {
        WindowGroup {
            MainView().environment(\.managedObjectContext, context)
        }
    }
}

struct bromoApp_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
