//
//  chatView.swift
//  fridge
//
//  Created by Luis Bravo on 9/26/22.
//

import SwiftUI

struct chatView: View {
    @State var user = "Luis"
    @State var messageList : [message] = []
    @State var yourText = ""
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        VStack{
            
            ScrollView {
                        ScrollViewReader { proxy in
                            
                            VStack(spacing: 5){
                                ForEach(messageList){
                                    message in
                                    messageView(thisMessage: message, thisUser: user)
                                }
                            }
                            
                        }
                    }
            
            ScrollViewReader{ value in
                ScrollView(.vertical, showsIndicators: false){
                    
                }
                
            }

                
                ZStack {
                
                    Rectangle()
                        .fill(.gray.opacity(0.8))
                    .frame(width: width, height: width / 5)
                    .ignoresSafeArea()
                    
                    HStack {
                        TextField("Message", text: $yourText)
                            .font(.system(size: width / 25))
                            .padding()
                            .textFieldStyle(.roundedBorder)
                            
                        
                        Button(action: {
                            if !yourText.isEmpty{
                                withAnimation{
                                    messageList.append(message(sender: user, text: yourText))
                                    yourText = ""
                                }
                            }
                        } ){
                            Text("Send")
                                .font(.system(size: width / 25, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                        
                    }
                    
                    
                    
                    
                }
                .keyboardType(.default)
            
                
                
            
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
                        .font(.system(size: width / 25, weight: .medium, design: .rounded))
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
                            .font(.system(size: width / 35, weight: .light, design: .rounded))
                            .opacity(0.5)
                    }
                    
                    Text(thisMessage.text)
                        .font(.system(size: width / 25, weight: .medium, design: .rounded))
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


struct message : Identifiable, Hashable{
    var id = UUID()
    var sender : String
    var text : String
}


