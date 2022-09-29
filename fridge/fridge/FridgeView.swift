//
//  FridgeView.swift
//  fridge
//
//  Created by Luis Bravo on 9/24/22.
//

import SwiftUI

struct FridgeView: View {
    
    var widthOfScreen = UIScreen.main.bounds.width
    var heightOfScreen = UIScreen.main.bounds.height
    @Binding var roomNumber : Int
    @State var cdvm = CoreDataViewModel()
    @State var foodItemList = [FoodItem]()
    @State var images = 1001
    @State var animating = false
    @State var open = false
    @State var chatting : Bool = false
    @State var location = "Kitchen"
    

    
    
    var body: some View {
        
        NavigationView{
            ZStack {
                
                itemList(bool: $animating, location: $location, cdvm: $cdvm, foodItemList: $foodItemList)
                    .opacity(open ? 1 : 0)
                    .animation(.spring().speed(0.5).delay(0), value: open)
                
                Image("Fridge 2/\(images)")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .horizontal)
                    .onTapGesture {
                        animating.toggle()
                    }
                    .scaleEffect(open ? 10 : 1)
                    .opacity(open ? 0 : 1)
                    .animation(.spring().speed(1).delay(0.5), value: open)
                    .background(
                        Color(.white)
                            .ignoresSafeArea()
                            .opacity(open ? 0 : 1)
                            .animation(.spring().speed(1).delay(0.5), value: open)
                            .frame(width: widthOfScreen, height: heightOfScreen)
                        
                    )
                
                
                

            }
            .toolbar(content: {
                NavigationLink("Chat", destination: {chatView()})
            })
            .onChange(of: animating, perform: {
                _ in
                if animating{
                    images += 1
                    open = true
                    withAnimation(.spring().speed(0.5)){
                        location = "Fridge"
                    }
                }
                else{
                    images -= 1
                    open = false
                    withAnimation(.spring().speed(0.5)){
                        location = "Kitchen"
                    }
                }
            })
            .onChange(of: images, perform: {_ in
                if animating{
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(15)){
                        if images < 1060 {
                            images += 1
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(30)){
                        if images > 1001 {
                            images -= 1
                        }
                    }
                }
            })
        }
        .navigationViewStyle(.stack)
        .onAppear{
            foodItemList = cdvm.fridge
        }
        
    }
}

//MARK: Item List

private struct itemList: View {
    
    @Binding var bool : Bool
    @Binding var location : String
    @Binding var cdvm : CoreDataViewModel
    @State var adding = false
    @Binding var foodItemList : [FoodItem]
    
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            NavigationView{
                
                List{
                    ForEach(foodItemList, id: \.self){
                        item in
                        if item.location == location {
                            Text(item.name ?? "Error")
                        }
                    }
                    .onDelete(perform: delete)
                }

            }
            .navigationTitle(location)
        .navigationViewStyle(.stack)
            
            VStack{
                Spacer()
                HStack{
                    Button(action: {bool = false}){
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemRed))
                                .frame(width: (width - 60) / 2 , height: width / 8)
                            Text("Back")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.white))
                        }
                        
                    }
                    .padding(.bottom)
                    
                    Button(action: {adding = true}){
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBlue))
                                .frame(width: (width - 60) / 2 , height: width / 8)
                            Text("Add Item")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.white))
                        }
                        
                    }
                    .padding(.bottom)
                }
                    
            }
            
        }
        .fullScreenCover(isPresented: $adding, content: {foodAddScreen(adding: $adding, newItemLocation: location, cdvm: $cdvm, foodItemList: $foodItemList)})
        
    }
    
    func delete(index : IndexSet){
        cdvm.deleteFoodItem(indexSet: index)
        foodItemList = cdvm.fridge
    }
    
    
}

//MARK: Food Add Screen

private struct foodAddScreen : View {
    @Binding var adding : Bool
    @State var newItemName = ""
    @State var newItemLocation : String
    @State var newItemStatus : String = "Fully Stocked"
    @State var wheelSelection : [String] = ["Fully Stocked", "Very Stocked", "Running Low", "Nearly Out", "Completely Out"]
    var width = UIScreen.main.bounds.width - 70
    @Binding var cdvm : CoreDataViewModel
    @Binding var foodItemList : [FoodItem]
    var body : some View{
        ZStack{
            Color(.systemGray5)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                TextField("", text: $newItemName)
                    .modifier(PlaceholderStyle(showPlaceHolder: newItemName.isEmpty, placeholder: "Name"))
                    .frame(width: width, alignment: .center)
                    .keyboardType(.default)
                
                Picker("Status", selection: $newItemStatus){
                    ForEach(wheelSelection, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                
                Spacer()
                
                HStack{
                    Button(action: {
                        adding = false
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemRed).opacity(0.9))
                                .frame(width: (width - 60) / 1.5 , height: width / 8)
                            Text("Cancel")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.white))
                        }
                        
                    }
                    
                    Button(action: {
                        if !newItemName.isEmpty {
                            cdvm.addFoodItem(name: newItemName, status: newItemStatus, location: newItemLocation)
                            foodItemList = cdvm.fridge
                            adding = false
                        }
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(newItemName.isEmpty ?  Color(.systemGray) : Color(.systemGreen).opacity(0.9))
                                .frame(width: (width - 60) / 1.5 , height: width / 8)
                            Text("Save")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.white))
                        }
                        
                    }
                }
                
            }
            .padding()
            
        }
    }
}

//MARK: Place Holder

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    
    var width = UIScreen.main.bounds.width - 70

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .foregroundColor(Color(.systemGray).opacity(0.5))
                    .frame(width: width, alignment: .center)
            }
            content
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemBlue))
                .frame(width: width, alignment: .center)
                .multilineTextAlignment(.center)
        }
    }
}
