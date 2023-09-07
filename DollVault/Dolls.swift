//
//  DollDetil.swift
//  DV_01
//
//  Created by Sijie Wang Belcher on 1/30/23.
//

import SwiftUI
import CloudKit



struct DollModel: Hashable {
    let Name: String
    let Record: CKRecord
    let Size: String
    let Gender: String
    let Price: String
}

class DollInfoViewModel: ObservableObject{
    
    @Published var text: String = ""
    @Published var size: String = ""
    @Published var gender: String = ""
    @Published var price: String = ""
    @Published var dolls: [DollModel] = []


        

    
    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        guard !size.isEmpty else { return }
        guard !gender.isEmpty else { return }
        guard !price.isEmpty else { return }
        addItem(Name: text, Size: size, Gender: gender, Price: price)
        
    }
    
    private func addItem(Name: String, Size: String, Gender: String, Price: String) {
        let newDoll = CKRecord(recordType: "Doll")
        newDoll["Name"] = Name
        newDoll["Size"] = Size
        newDoll["Gender"] = Gender
        newDoll["Price"] = Price
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
                self?.price = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Doll", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [DollModel] = []
        
 
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):
                guard let Name = Record["Name"] as? String else {
                    return
                }
                guard let Size = Record["Size"] as? String else {
                    return
                }
                guard let Gender = Record["Gender"] as? String else {
                    return
                }
                guard let Price = Record["Price"] as? String else {
                    return
                }
  
                returnedItems.append(DollModel(Name: Name, Record: Record, Size: Size, Gender: Gender, Price: Price))
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
    
    func updateItem(doll: DollModel, name: String = ""){
        
        let Record = doll.Record
  
        
        Record["Name"] = name
        saveItem(record: Record)
        
    }
    
    func updateSize(doll: DollModel, size: String = ""){
        
        let Record = doll.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    
    func updateGender(doll: DollModel, gender: String = ""){
        
        let Record = doll.Record

        Record["Gender"] = gender
        saveItem(record: Record)
    }
    
    func updatePrice(doll: DollModel, price: String = ""){
        
        let Record = doll.Record

        Record["Price"] = price
        saveItem(record: Record)
    }
    
}

struct Dolls: View {

    @StateObject private var vm = DollInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newName : [String] =  []
    @State var showSheet: Bool = false
    @State var nameNew = ""
    @State var selectedItem: DollModel?

    
    var body: some View {
        NavigationView {

            VStack{
                header
                textField
                textFieldSize
                textFieldGender
                textFieldPrice
                addButton
                
                List {
                    
                    ForEach(vm.dolls, id: \.self) { doll in
                        

                        HStack{

                            Text(doll.Name)
                                .onAppear(perform:  {selectedItem = doll})
                               
            
                          
                            NavigationLink(destination: DollDetail(doll: doll)){
                            }
                            
                       
                        }
            
                        
                        .sheet(isPresented: $showSheet, content: {
                            DollDetail(doll: doll)
                        
                        })
                        
               
                         
                    }
                    
                    
                    .onDelete(perform: vm.deleteItem(indexSet:))
                }
                .listStyle(PlainListStyle())
                
                
           
                
            }
            .padding()
            .navigationBarHidden(true)
            .background(
               Image("dolls")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
               
            
            )
   
        }
        

    }
    
    
}

struct Dolls_Previews: PreviewProvider {
    static var previews: some View {
        Dolls()
    }
}


extension Dolls {
    
    private var header: some View{
        Text("Dolls")
            .fontWeight(.bold)
            .foregroundColor(.teal)
            .font(.system(size: 60))

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
    
    private var textFieldPrice: some View {
        TextField("Add price",text: $vm.price)
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
                .font(.title)
                .foregroundColor(.white)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.teal)
                .cornerRadius(13)
            
        }
    }
    

    
}

struct DollDetail: View {
    
    let doll: DollModel
    
    @StateObject private var vm = DollInfoViewModel()
    @State private var nameNew = ""
    @State private var sizeNew = ""
    @State private var priceNew = ""
    @State private var genderNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each doll
    var body: some View {
       
         
             
        VStack(alignment: .center, spacing: 49){
                
          
                       
                
                Text(doll.Name)
                    .font(.system(size: 60))
                    .foregroundColor(.teal)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .bold()
                HStack(){
                    
                    Text("NAME:")
                        .padding(.leading)
                        .foregroundColor(.teal)
                        .bold()
                    Text(doll.Name)
                        .foregroundColor(.teal)
                    
                    
                    
                    TextField("New info here",
                              text:$nameNew
                              
                                    )
                    
             
                    
                    
                    Button{
                        vm.updateItem(doll: doll, name: nameNew)
                        DispatchQueue.main.async{
                            self.nameNew = ""
                            self.sizeNew = ""
                            self.genderNew = ""
                            self.priceNew = ""
                        }
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.teal)
                        
                            
                    } .cornerRadius(10)
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("SIZE:")
                        .padding(.leading)
                        .foregroundColor(.teal)
                        .bold()
                    Text(doll.Size)
                        .foregroundColor(.teal)
                    
                    
                    TextField("New info here",
                              text:$sizeNew)
                
                    
                    
                    Button{
                        vm.updateSize(doll: doll, size : sizeNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.teal)
                    }.cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("GENDER:")
                        .padding(.leading)
                        .foregroundColor(.teal)
                        .bold()
                    Text(doll.Gender)
                        .foregroundColor(.teal)
                    
                    
                    
                    TextField("New info here",
                              text:$genderNew)
    
                    
                    Button{
                        vm.updateGender(doll: doll, gender: genderNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.teal)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                }.padding(.trailing)
                
                HStack(){
                    Text("PRICE:")
                        .padding(.leading)
                        .foregroundColor(.teal)
                        .bold()
                    Text(doll.Price)
                        .foregroundColor(.teal)
                    
                    
                    
                    TextField("New info here",
                              text:$priceNew)
    
                    
                    Button{
                        vm.updatePrice(doll: doll, price : priceNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.teal)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                    
                }.padding(.trailing)
                    
            }
            .background(
               Image("reddoll")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
        
            
        }
        

    }
    




