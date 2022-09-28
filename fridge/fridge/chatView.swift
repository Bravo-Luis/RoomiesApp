//
//  chatView.swift
//  fridge
//
//  Created by Luis Bravo on 9/26/22.
//

import SwiftUI

struct chatView: View {
    @Binding var presentingChatView : Bool
    @State var user = "Luis"
    @State var messageList : [message] = [message(sender: "Luis", text: "Hey Victor, it's Luis"), message(sender: "Luis", text: "Hey I have to tell you something"), message(sender: "Luis", text: "What?!?!?"), message(sender: "Victor", text: "I think i love you <3"), message(sender: "Luis", text: "Bruh")]
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack{
            Color(.gray).opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 5){
                ForEach(messageList){
                    message in
                    messageView(thisMessage: message, thisUser: user)
                }
            }
            
            VStack{
                ZStack {
                    Rectangle()
                        .fill(.gray.opacity(0.8))
                    .frame(width: width, height: width / 3)
                    
                    HStack {
                        Button(action: {presentingChatView = false}, label: {Text("Back")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        })
                        .padding(.leading)
                        Spacer()
                    }
                }
                Spacer()
            }
            .ignoresSafeArea()
                
                
            
        }
    }
}

struct messageView: View{
    @State var thisMessage : message
    @State var thisUser : String
    var width = UIScreen.main.bounds.width
    var body: some View{
        
        if thisMessage.sender == thisUser {
            ZStack {
                ZStack {
                    Text(thisMessage.text)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.blue)
                            
                    )
                }
                .frame(idealWidth: 0, maxWidth: width / 1.5, alignment: .trailing)
            }.frame(width: width - 30, alignment: .trailing)
            
        }else{
            
            ZStack {
                VStack(spacing: 0) {
                    HStack{
                        Text(thisMessage.sender)
                            .font(.system(size: 15, weight: .light, design: .rounded))
                            .opacity(0.5)
                    }
                    
                    Text(thisMessage.text)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.gray.opacity(0.8))
                            
                    )
                }
                .frame(idealWidth: 0, maxWidth: width / 1.5, alignment: .leading)
            }.frame(width: width - 30, alignment: .leading)
        }
        
    }
}


struct message : Identifiable {
    var id = UUID()
    var sender : String
    var text : String
}
