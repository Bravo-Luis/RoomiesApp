//
//  ContentView.swift
//  fridge
//
//  Created by Luis Bravo on 9/24/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var fontSize = 0
    @State var roomNumber = 0
    
    var body: some View {
        ZStack{
           FridgeView(roomNumber: $roomNumber)
                .preferredColorScheme(.light)
            
            if roomNumber == 0 {
                onboardingView(roomNumber: $roomNumber)
            }
            
            
            
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
