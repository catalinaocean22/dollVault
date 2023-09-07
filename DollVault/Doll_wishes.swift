//
//  Doll_wishes.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 3/5/23.
//

import SwiftUI
import CloudKit



struct DollWishModel: Hashable {
    let Title: String
    let Record: CKRecord
    let Size: String
    let Gender: String
    let Cost: String
    let Notes: String
}

class DollWishInfoViewModel: ObservableObject{
    
    @Published var text: String = ""
    @Published var size: String = ""
    @Published var gender: String = ""
    @Published var cost: String = ""
    @Published var notes: String = ""
    @Published var dolls: [DollWishModel] = []

    
    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        guard !size.isEmpty else { return }
        guard !gender.isEmpty else { return }
        guard !cost.isEmpty else { return }
        guard !notes.isEmpty else { return }
        addItem(Title: text, Size: size, Gender: gender, Cost: cost, Notes: notes)
        
    }
    
    private func addItem(Title: String, Size: String, Gender: String, Cost: String, Notes: String) {
        let newDoll = CKRecord(recordType: "Doll_wish")
        newDoll["Title"] = Title
        newDoll["Size"] = Size
        newDoll["Gender"] = Gender
        newDoll["Cost"] = Cost
        newDoll["Notes"] = Notes
        saveItem(record: newDoll)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self?.text = ""
                self?.size = ""
                self?.gender = ""
                self?.cost = ""
                self?.notes = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Doll_wish", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [DollWishModel] = []
        
 
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):
                guard let Title = Record["Title"] as? String else {
                    return
                }
                guard let Size = Record["Size"] as? String else {
                    return
                }
                guard let Gender = Record["Gender"] as? String else {
                    return
                }
                guard let Cost = Record["Cost"] as? String else {
                    return
                }
                guard let Notes = Record["Notes"] as? String else {
                    return
                }
      
                returnedItems.append(DollWishModel(Title: Title, Record: Record, Size: Size, Gender: Gender, Cost: Cost, Notes: Notes))
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
        }
            
        
      
        DispatchQueue.main.async {
            queryOperation.queryResultBlock = { [weak self] returnedResult in print("RETURNED RESULT: \(returnedResult)")
                DispatchQueue.main.async {
                    self?.dolls = returnedItems
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
        let doll = dolls[index]
        let record = doll.Record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.dolls.remove(at: index)
            }
            
        }
        
    }
    
    func updateItem(doll: DollWishModel, title: String = ""){
        
        let Record = doll.Record

        
        Record["Title"] = title
        saveItem(record: Record)
        
    }
    
    func updateSize(doll: DollWishModel, size: String = ""){
        
        let Record = doll.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    
    func updateGender(doll: DollWishModel, gender: String = ""){
        
        let Record = doll.Record

        Record["Gender"] = gender
        saveItem(record: Record)
    }
    
    func updateCost(doll: DollWishModel, cost: String = ""){
        
        let Record = doll.Record

        Record["Cost"] = cost
        saveItem(record: Record)
    }
    func updateNotes(doll: DollWishModel, notes: String = ""){
        
        let Record = doll.Record

        Record["Notes"] = notes
        saveItem(record: Record)
    }
    
}

struct Doll_wishes: View {

    @StateObject private var vm = DollWishInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newName : [String] =  []
    @State var showSheet: Bool = false
    @State var nameNew = ""
    @State var selectedItem: DollWishModel?
 
    
    var body: some View {
        NavigationView {

            VStack{
                header
                textField
                textFieldSize
                textFieldGender
                textFieldCost
                textFieldNotes
                addButton
                
                List {
                    
                    ForEach(vm.dolls, id: \.self) { doll in
                        

                        HStack{

                            Text(doll.Title)
                                .onAppear(perform:  {selectedItem = doll})
                               
                          
                           
                            NavigationLink(destination: DollWishDetail(doll: doll)){
                            }
                       
                        }
                        
                        
                        .sheet(isPresented: $showSheet, content: {
                            DollWishDetail(doll: doll)
                        
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

struct Doll_wishes_Previews: PreviewProvider {
    static var previews: some View {
        Doll_wishes()
    }
}


extension Doll_wishes {
    
    private var header: some View{
        Text("Dolls Wanted")
            .font(.title)

    }
    
    private var textField: some View {
        TextField("Add a doll...",text: $vm.text)
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
    
    
    private var textFieldGender: some View {
        TextField("Add gender",text: $vm.gender)
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

struct DollWishDetail: View {
    
    let doll: DollWishModel
    
    @StateObject private var vm = DollWishInfoViewModel()
    @State private var titleNew = ""
    @State private var sizeNew = ""
    @State private var costNew = ""
    @State private var genderNew = ""
    @State private var notesNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each doll
    var body: some View {
        ZStack(alignment: .topLeading){
            Color.cyan
                .edgesIgnoringSafeArea(.all)
            VStack{
                

                       
                
                Text(doll.Title)
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
                    Text(doll.Title)
                        .foregroundColor(.white)
                    
                    
                    
                    TextField("New info here",
                              text:$titleNew
                              
                                    )
                    
                    //text:$newName[newName.firstIndex(of: doll.Name)!])
                    //.onAppear(perform: { newName.append(doll.Name)})
                    
                    
                    Button{
                        vm.updateItem(doll: doll, title: titleNew)
                        DispatchQueue.main.async{
                            self.titleNew = ""
                            self.sizeNew = ""
                            self.genderNew = ""
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
                    Text(doll.Size)
                        .foregroundColor(.white)
                    
                    
                    TextField("New info here",
                              text:$sizeNew)
           
                    
                    
                    Button{
                        vm.updateSize(doll: doll, size : sizeNew)
                        
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
                    Text(doll.Gender)
                        .foregroundColor(.white)
                 
                    TextField("New info here",
                              text:$genderNew)
                    
                    
                    Button{
                        vm.updateGender(doll: doll, gender: genderNew)
                        
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
                    Text(doll.Cost)
                        .foregroundColor(.white)
                 
                    TextField("New info here",
                              text:$costNew)
            
                    Button{
                        vm.updateCost(doll: doll, cost : costNew)
                        
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
                    Text(doll.Notes)
                        .foregroundColor(.white)
                    
                    
                    
                    TextField("New info here",
                              text:$notesNew)

                    
                    Button{
                        vm.updateNotes(doll: doll, notes: notesNew)
                        
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
