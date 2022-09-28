//
//  onboardingView.swift
//  fridge
//
//  Created by Luis Bravo on 9/26/22.
//

import SwiftUI

struct onboardingView: View {
    
    @Binding var roomNumber : Int
    @State var tempNum = ""
    @State var join = false
    
    @State var width = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            
            Color(.systemGray5)
                .ignoresSafeArea()
            
            VStack{
                
                Button(action: {
                    let first = Int.random(in: 1...9)
                    let second = Int.random(in: 0...9)
                    let third = Int.random(in: 0...9)
                    let fourth = Int.random(in: 0...9)
                    let fifth = Int.random(in: 0...9)
                    
                    roomNumber = first * 10000 + second * 1000 + third * 100 + fourth * 10 + fifth
                    
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: width - 70, height: width / 5)
                        
                        Text("Create")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: {join = true}){
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: width - 70, height: width / 5)
                        
                        Text("Join")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
            }
            .fullScreenCover(isPresented: $join, content: {
                
                
                VStack {
                    TextField("Code", text: $tempNum)
                        .padding()
                        .frame(width: width - 80)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .onChange(of: tempNum, perform: { _ in
                            
                    })
                    
                    Button(action: {
                        
                        if !tempNum.isEmpty{
                            roomNumber = Int(tempNum) ?? 0
                            join = false
                        }
                        
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: width - 70, height: width / 5)
                            
                            Text("Join")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    
                }
                
        })
        }
        
    }

}


