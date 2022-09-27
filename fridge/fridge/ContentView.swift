//
//  ContentView.swift
//  fridge
//
//  Created by Luis Bravo on 9/24/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
   
    var body: some View {
        ZStack{
            FridgeView()
                .preferredColorScheme(.light)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
