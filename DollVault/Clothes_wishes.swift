//
//  Clothe_wishes.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 3/5/23.
//

import SwiftUI
import CloudKit


struct ClothesWishModel: Hashable {
    let Title: String
    let Record: CKRecord
    let Size: String
    let Color: String
    let Cost: String
    let Notes: String
}

class ClothesWishInfoViewModel: ObservableObject{
    
    @Published var text: String = ""
    @Published var size: String = ""
    @Published var color: String = ""
    @Published var cost: String = ""
    @Published var notes: String = ""
    @Published var clothes: [ClothesWishModel] = []

//So the list of existing wishes wouod appear right away
    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        guard !size.isEmpty else { return }
        guard !color.isEmpty else { return }
        guard !cost.isEmpty else { return }
        guard !notes.isEmpty else { return }
        addItem(Title: text, Size: size, Color: color, Cost: cost, Notes: notes)
        
    }
    
    private func addItem(Title: String, Size: String, Color: String, Cost: String, Notes: String) {
        let newClothes = CKRecord(recordType: "Clothing_wish")
        newClothes["Title"] = Title
        newClothes["Size"] = Size
        newClothes["Color"] = Color
        newClothes["Cost"] = Cost
        newClothes["Notes"] = Notes
        saveItem(record: newClothes)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self?.text = ""
                self?.size = ""
                self?.color = ""
                self?.cost = ""
                self?.notes = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Clothing_wish", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        var returnedItems: [ClothesWishModel] = []
        
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):
                guard let Title = Record["Title"] as? String else {
                    return
                }
                guard let Size = Record["Size"] as? String else {
                    return
                }
                guard let Color = Record["Color"] as? String else {
                    return
                }
                guard let Cost = Record["Cost"] as? String else {
                    return
                }
                guard let Notes = Record["Notes"] as? String else {
                    return
                }
    
                returnedItems.append(ClothesWishModel(Title: Title, Record: Record, Size: Size, Color: Color, Cost: Cost, Notes: Notes))
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
        }
      //Without this it would mess up
        DispatchQueue.main.async {
            queryOperation.queryResultBlock = { [weak self] returnedResult in print("RETURNED RESULT: \(returnedResult)")
                DispatchQueue.main.async {
                    self?.clothes = returnedItems
                }
                
            }
       
        }
        
        addOperation(operation: queryOperation)
        
    }
    

    func addOperation(operation: CKDatabaseOperation){
        
        CKContainer.default().publicCloudDatabase.add(operation)
        
    }
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let clothing = clothes[index]
        let record = clothing.Record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.clothes.remove(at: index)
            }
            
        }
        
    }
    
    func updateItem(clothing: ClothesWishModel, title: String = ""){
        
        let Record = clothing.Record

        Record["Title"] = title
        saveItem(record: Record)
        
    }
    
    func updateSize(clothing: ClothesWishModel, size: String = ""){
        
        let Record = clothing.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    
    func updateColor(clothing: ClothesWishModel, color: String = ""){
        
        let Record = clothing.Record

        Record["Color"] = color
        saveItem(record: Record)
    }
    
    func updateCost(clothing: ClothesWishModel, cost: String = ""){
        
        let Record = clothing.Record

        Record["Cost"] = cost
        saveItem(record: Record)
    }
    func updateNotes(clothing: ClothesWishModel, notes: String = ""){
        
        let Record = clothing.Record

        Record["Notes"] = notes
        saveItem(record: Record)
    }
    
}

struct Clothes_wishes: View {

    @StateObject private var vm = ClothesWishInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newName : [String] =  []
    @State var showSheet: Bool = false
    @State var nameNew = ""
    

    
    var body: some View {
        NavigationView {

            VStack{
                header
                textField
                textFieldSize
                textFieldColor
                textFieldCost
                textFieldNotes
                addButton
                
                List {
                    ForEach(vm.clothes, id: \.self) { clothing in
                        HStack{
                            Text(clothing.Title)
                               
                        
                            NavigationLink(destination: ClothesWishDetail(clothing: clothing)){
                            }
                       
                        }
                        
                        .sheet(isPresented: $showSheet, content: {
                            ClothesWishDetail(clothing: clothing)
                    
                        })
                    }
                    .onDelete(perform: vm.deleteItem(indexSet:))
                }
                .listStyle(PlainListStyle())
                
            }
            .padding()
            .navigationBarHidden(true)
            
        }

    }
    
}

struct Clothes_wishes_Previews: PreviewProvider {
    static var previews: some View {
        Clothes_wishes()
    }
}


extension Clothes_wishes {
    
    private var header: some View{
        Text("Clothes Wanted")
            .font(.title)

    }
    
    private var textField: some View {
        TextField("Add clothes wanted...",text: $vm.text)
            .frame(height: 60)
            .padding(.leading)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(13)
    }
    
    private var textFieldSize: some View {
        TextField("Add size",text: $vm.size)
            .frame(height: 60)
            .padding(.leading)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(13)
    }
    
    
    private var textFieldColor: some View {
        TextField("Add color",text: $vm.color)
            .frame(height: 60)
            .padding(.leading)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(13)
    }
    
    private var textFieldCost: some View {
        TextField("Add cost or budget",text: $vm.cost)
            .frame(height: 60)
            .padding(.leading)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(13)
    }
    
    private var textFieldNotes: some View {
        TextField("Add notes",text: $vm.notes)
            .frame(height: 60)
            .padding(.leading)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(13)
    }
    
    
    private var addButton: some View {
        Button{
            vm.addButtonPressed()
        } label: {
            Text("Add")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.cyan)
                .cornerRadius(13)
        }
    }

}

struct ClothesWishDetail: View {
    
    let clothing: ClothesWishModel
    
    @StateObject private var vm = ClothesWishInfoViewModel()
    @State private var titleNew = ""
    @State private var sizeNew = ""
    @State private var costNew = ""
    @State private var colorNew = ""
    @State private var notesNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each clothes
    var body: some View {
        ZStack(alignment: .topLeading){
            Color.cyan
                .edgesIgnoringSafeArea(.all)
            VStack{

                Text(clothing.Title)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .bold()
                HStack(){
                    
                    Text("TITLE:")
                        .padding(.leading)
                        .foregroundColor(.white)
                        .bold()
                    Text(clothing.Title)
                        .foregroundColor(.white)

                    TextField("New info here",
                              text:$titleNew
                              )
                    Button{
                        vm.updateItem(clothing: clothing, title: titleNew)
                        DispatchQueue.main.async{
                            self.titleNew = ""
                            self.sizeNew = ""
                            self.colorNew = ""
                            self.costNew = ""
                            self.notesNew = ""
                        }
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.blue)
                        
                            
                    } .cornerRadius(10)
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("SIZE:")
                        .padding(.leading)
                        .foregroundColor(.white)
                        .bold()
                    Text(clothing.Size)
                        .foregroundColor(.white)
      
                    TextField("New info here",
                              text:$sizeNew)
                    Button{
                        vm.updateSize(clothing: clothing, size : sizeNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.blue)
                    }.cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("GENDER:")
                        .padding(.leading)
                        .foregroundColor(.white)
                        .bold()
                    Text(clothing.Color)
                        .foregroundColor(.white)
                    
                    TextField("New info here",
                              text:$colorNew)
                    Button{
                        vm.updateColor(clothing: clothing, color: colorNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.blue)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                }.padding(.trailing)
                
                HStack(){
                    Text("COST:")
                        .padding(.leading)
                        .foregroundColor(.white)
                        .bold()
                    Text(clothing.Cost)
                        .foregroundColor(.white)
                   
                    TextField("New info here",
                              text:$costNew)

                    Button{
                        vm.updateCost(clothing: clothing, cost : costNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.blue)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                    
                }.padding(.trailing)
                HStack(){
                    Text("NOTES:")
                        .padding(.leading)
                        .foregroundColor(.white)
                        .bold()
                    Text(clothing.Notes)
                        .foregroundColor(.white)
                    
                    TextField("New info here",
                              text:$notesNew)
             
                    Button{
                        vm.updateNotes(clothing: clothing, notes: notesNew)
                        
                    } label: {
                        Text("Update")
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                            .cornerRadius(10)
                            .background(Color.blue)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                }.padding(.trailing)
                
            }
        }

    }
}

