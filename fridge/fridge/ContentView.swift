//
//  ContentView.swift
//  fridge
//
//  Created by Luis Bravo on 9/24/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var chatting : Bool = false
    
    @State var roomNumber = 0
    var body: some View {
        ZStack{
           FridgeView(roomNumber: $roomNumber)
                .preferredColorScheme(.light)
                .overlay{
                    Button(action: {chatting = true}, label: {Text("Chat")
                            .padding()
                    })
                        .offset(x: 150, y: -360)
                }
            
            if roomNumber == 0 {
                onboardingView(roomNumber: $roomNumber)
            }
            
            
            
        }
        .fullScreenCover(isPresented: $chatting, content: {
            chatView(presentingChatView: $chatting)
        })
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
