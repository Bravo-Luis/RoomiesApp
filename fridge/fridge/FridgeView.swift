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
    
    var body: some View {
        
        NavigationView{
            ZStack {
                kitchenBG(roomNumber: $roomNumber)
                VStack(spacing: 0){
                    NavigationLink(destination: {itemList(thisList: $foodItemList, location: "Freezer", cdvm: $cdvm, foodItemList: $foodItemList)}, label: {freezer()})
                        
                    NavigationLink(destination: {itemList(thisList: $foodItemList, location: "Fridge", cdvm: $cdvm, foodItemList: $foodItemList)}, label: {fridge()})
                        
                }
                .navigationTitle("Kitchen")
            }
        }
        .navigationViewStyle(.stack)
        .onAppear{
            foodItemList = cdvm.fridge
        }
        
    }
}

//MARK: Aesthetics

private struct freezer: View {
    
    private var width = UIScreen.main.bounds.width
    private var height = UIScreen.main.bounds.width * 2
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(.systemGray5))
                .frame(width: width / 2, height: height / 6)
                .shadow(radius: 3)
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: width / 30, height: height / 12)
                .offset(x: -width / 6)
                .shadow(radius: 2)
        }
        
    }
}

private struct fridge: View {
    
    private var width = UIScreen.main.bounds.width
    private var height = UIScreen.main.bounds.width * 2
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(.systemGray5))
                .frame(width: width / 2, height: height / 3)
                .shadow(radius: 3)
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: width / 30, height: height / 5)
                .offset(x: -width / 6, y: -height / 25)
                .shadow(radius: 2)
        }
        
    }
}

//MARK: Item List

private struct itemList: View {
    
    @Binding var thisList : [FoodItem]
    var location : String
    @Binding var cdvm : CoreDataViewModel
    @State var adding = false
    @Binding var foodItemList : [FoodItem]
    
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            NavigationView{
                
                List{
                    ForEach(thisList, id: \.self){
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
                Button(action: {adding = true}){
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBlue))
                            .frame(width: width - 60, height: width / 8)
                        Text("Add Item")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.white))
                    }
                    
                }
                .padding(.bottom)
                    
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

private struct kitchenBG : View {
    @Binding var roomNumber : Int
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack{
            Color(.systemMint).opacity(0.3)
                .ignoresSafeArea()
            VStack {
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(Color(.systemYellow)).blendMode(.hue)
                        .ignoresSafeArea()
                        .frame(width: width, height: width / 2.5)
                    
                    Text(String(roomNumber))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                }
            }
            
            Rectangle()
                .fill(Color(.systemBrown).opacity(0.9))
                .frame(width: width, height: width / 2)
                .offset(y: width / 4)
                .background(
                    Color(.black)
                        .ignoresSafeArea()
                        .offset(y: width / 4)
                )
            
            
            Rectangle()
                .fill(Color(.systemBrown))
                .frame(width: width, height: width / 30)
                .offset(y: -width / 60)
            
            Rectangle()
                .fill(Color(.systemBrown))
                .frame(width: width, height: width / 30)
                .offset(y: -width / 60.1)
                .shadow(radius: 3)
            
            
            VStack {
                ZStack{
                    Rectangle()
                        .fill(Color(.systemBrown))
                        .frame(width: width / 4, height: width / 7)
                        .offset(x: width / 2.5, y: width / 4)
                        .shadow(radius: 2)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemYellow).opacity(0.6))
                        .frame(width: width / 30, height: width / 30)
                        .offset(x: width / 2.2, y: width / 4)
                        .shadow(radius: 3)
                }
                ZStack{
                    Rectangle()
                        .fill(Color(.systemBrown))
                        .frame(width: width / 4, height: width / 7)
                        .offset(x: width / 2.5, y: width / 4)
                        .shadow(radius: 2)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemYellow).opacity(0.6))
                        .frame(width: width / 30, height: width / 30)
                        .offset(x: width / 2.2, y: width / 4)
                        .shadow(radius: 3)
                }
                ZStack{
                    Rectangle()
                        .fill(Color(.systemBrown))
                        .frame(width: width / 4, height: width / 7)
                        .offset(x: width / 2.5, y: width / 4)
                        .shadow(radius: 2)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemYellow).opacity(0.6))
                        .frame(width: width / 30, height: width / 30)
                        .offset(x: width / 2.2, y: width / 4)
                        .shadow(radius: 3)
                }
                .hidden()
            }
            ZStack {
                Rectangle()
                    .fill(Color(.systemBrown))
                    .frame(width: width / 4, height: width / 2.25)
                    .offset(x: -width / 2.5, y: width / 4)
                    .shadow(radius: 2)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemYellow).opacity(0.6))
                    .frame(width: width / 30, height: width / 30)
                    .offset(x: -width / 2.2, y: width / 4)
                    .shadow(radius: 3)
            }
            
            
            
        }
    }
}

