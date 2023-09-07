//
//  Services.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 3/5/23.
//

import SwiftUI
import CloudKit



struct ServiceModel: Hashable {
    let Title: String
    let Record: CKRecord
    let Size: String
 
    let Cost: String
    let Notes: String
}

class ServiceInfoViewModel: ObservableObject{
    
    @Published var text: String = ""
    @Published var size: String = ""
    
    @Published var cost: String = ""
    @Published var notes: String = ""
    @Published var services: [ServiceModel] = []


        

    
    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        guard !size.isEmpty else { return }
 
        guard !cost.isEmpty else { return }
        guard !notes.isEmpty else { return }
        addItem(Title: text, Size: size, Cost: cost, Notes: notes)
        
    }
    
    private func addItem(Title: String, Size: String, Cost: String, Notes: String) {
        let newService = CKRecord(recordType: "Services")
        newService["Title"] = Title
        newService["Size"] = Size
 
        newService["Cost"] = Cost
        newService["Notes"] = Notes
        saveItem(record: newService)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self?.text = ""
                self?.size = ""
         
                self?.cost = ""
                self?.notes = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Services", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [ServiceModel] = []
        
 
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):
                guard let Title = Record["Title"] as? String else {
                    return
                }
                guard let Size = Record["Size"] as? String else {
                    return
                }

                guard let Cost = Record["Cost"] as? String else {
                    return
                }
                guard let Notes = Record["Notes"] as? String else {
                    return
                }

                returnedItems.append(ServiceModel(Title: Title, Record: Record, Size: Size, Cost: Cost, Notes: Notes))
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
        }
            
        
      
        DispatchQueue.main.async {
            queryOperation.queryResultBlock = { [weak self] returnedResult in print("RETURNED RESULT: \(returnedResult)")
                DispatchQueue.main.async {
                    self?.services = returnedItems
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
        let service = services[index]
        let record = service.Record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.services.remove(at: index)
            }
            
        }
        
    }
    
    func updateItem(service: ServiceModel, title: String = ""){
        
        let Record = service.Record

        
        Record["Title"] = title
        saveItem(record: Record)
        
    }
    
    func updateSize(service: ServiceModel, size: String = ""){
        
        let Record = service.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    

    func updateCost(service: ServiceModel, cost: String = ""){
        
        let Record = service.Record

        Record["Cost"] = cost
        saveItem(record: Record)
    }
    func updateNotes(service: ServiceModel, notes: String = ""){
        
        let Record = service.Record

        Record["Notes"] = notes
        saveItem(record: Record)
    }
    
}

struct Services: View {

    @StateObject private var vm = ServiceInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newName : [String] =  []
    @State var showSheet: Bool = false
    @State var nameNew = ""
    @State var selectedItem: ServiceModel?

    
    var body: some View {
        NavigationView {

            VStack{
                header
                textField
                textFieldSize
             
                textFieldCost
                textFieldNotes
                addButton
                
                List {
                    
                    ForEach(vm.services, id: \.self) { service in
                        

                        HStack{

                            Text(service.Title)
                                .onAppear(perform:  {selectedItem = service})
                               
                          
                           
                            NavigationLink(destination: ServiceDetail(service: service)){
                            }
                       
                        }
                        
                        
                        .sheet(isPresented: $showSheet, content: {
                            ServiceDetail(service: service)
                        
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

struct Services_Previews: PreviewProvider {
    static var previews: some View {
        Services()
    }
}


extension Services {
    
    private var header: some View{
        Text("Services Wanted")
            .font(.title)

    }
    
    private var textField: some View {
        TextField("Add service wanted...",text: $vm.text)
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

struct ServiceDetail: View {
    
    let service: ServiceModel
    
    @StateObject private var vm = ServiceInfoViewModel()
    @State private var titleNew = ""
    @State private var sizeNew = ""
    @State private var costNew = ""

    @State private var notesNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each clothes
    var body: some View {
        ZStack(alignment: .topLeading){
            Color.cyan
                .edgesIgnoringSafeArea(.all)
            VStack{
                

                       
                
                Text(service.Title)
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
                    Text(service.Title)
                        .foregroundColor(.white)
                    
                    
                    
                    TextField("New info here",
                              text:$titleNew
                              
                                    )
                    
                
                    
                    
                    Button{
                        vm.updateItem(service: service, title: titleNew)
                        DispatchQueue.main.async{
                            self.titleNew = ""
                            self.sizeNew = ""
                        
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
                    Text(service.Size)
                        .foregroundColor(.white)
                    
                    
                    TextField("New info here",
                              text:$sizeNew)
           
                    
                    
                    Button{
                        vm.updateSize(service: service, size : sizeNew)
                        
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
                    Text("COST:")
                        .padding(.leading)
                        .foregroundColor(.white)
                        .bold()
                    Text(service.Cost)
                        .foregroundColor(.white)
                    
                    
                    
                    TextField("New info here",
                              text:$costNew)
    
                    
                    
                    Button{
                        vm.updateCost(service: service, cost : costNew)
                        
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
                    Text(service.Notes)
                        .foregroundColor(.white)
                    
                    
                    
                    TextField("New info here",
                              text:$notesNew)
                   
                    
                    
                    Button{
                        vm.updateNotes(service: service, notes: notesNew)
                        
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

