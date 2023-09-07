//
//  Eyes.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 2/26/23.
//

import SwiftUI
import CloudKit



struct eyeModel: Hashable {

    let Record: CKRecord
    let Size: String
    let Date: String
    let Price: String
    let Color: String
}

class EyeInfoViewModel: ObservableObject{
    

    @Published var size: String = ""
    @Published var date: String = ""
    @Published var price: String = ""
    @Published var color: String = ""
    @Published var eyes: [eyeModel] = []

    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {

        guard !size.isEmpty else { return }
        guard !date.isEmpty else { return }
        guard !price.isEmpty else { return }
        guard !color.isEmpty else { return }
        addItem(Size: size, Date: date, Price: price, Color: color)
        
    }
    
    private func addItem(Size: String, Date: String, Price: String, Color: String) {
        let neweye = CKRecord(recordType: "eye")
 
        neweye["Size"] = Size
        neweye["Date"] = Date
        neweye["Price"] = Price
        neweye["Color"] = Color
        saveItem(record: neweye)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.async{
         
                self?.size = ""
                self?.date = ""
                self?.price = ""
                self?.color = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "eye", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [eyeModel] = []
        
 
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):

                guard let Size = Record["Size"] as? String else {
                    return
                }
                guard let Date = Record["Date"] as? String else {
                    return
                }
                guard let Price = Record["Price"] as? String else {
                    return
                }
                guard let Color = Record["Color"] as? String else {
                    return
                }
                

                returnedItems.append(eyeModel(Record: Record, Size: Size, Date: Date, Price: Price, Color: Color))
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
        }
            
        
      
        DispatchQueue.main.async {
            queryOperation.queryResultBlock = { [weak self] returnedResult in print("RETURNED RESULT: \(returnedResult)")
                DispatchQueue.main.async {
                    self?.eyes = returnedItems
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
        let eye = eyes[index]
        let record = eye.Record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.eyes.remove(at: index)
            }
            
        }
        
    }
    

    
    func updateSize(eye: eyeModel, size: String = ""){
        
        let Record = eye.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    
    func updateDate(eye: eyeModel, date: String = ""){
        
        let Record = eye.Record

        Record["Date"] = date
        saveItem(record: Record)
    }
    
    func updatePrice(eye: eyeModel, price: String = ""){
        
        let Record = eye.Record

        Record["Price"] = price
        saveItem(record: Record)
    }
    
    func updateColor(eye: eyeModel, color: String = ""){
        
        let Record = eye.Record

        Record["Color"] = color
        saveItem(record: Record)
    }
}

struct Eyes: View {

    @StateObject private var vm = EyeInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newLength : [String] =  []
    @State var showSheet: Bool = false
    @State var lengthNew = ""
    @State var selectedItem: eyeModel?
    /*
    func newNames(a_doll: String) {
        newName.append(a_doll)
    }
    */
    
    var body: some View {
        NavigationView {

            VStack{
                header
        
                textFieldSize
                textFieldDate
                textFieldPrice
                textFieldColor
                addButton
                
                List {
                    
                    ForEach(vm.eyes, id: \.self) { eye in
                        

                        HStack{

                   
                            Text(eye.Color)
                            NavigationLink(destination: eyeDetail(eye: eye)){
                            }
                            
                        }
                        
                        .sheet(isPresented: $showSheet, content: {
                            eyeDetail(eye: eye)
                        
                        })
                    }
                    
                    
                    .onDelete(perform: vm.deleteItem(indexSet:))
                }
                .listStyle(PlainListStyle())
                
                
            }
            .padding()
            .navigationBarHidden(true)
            .background(
               Image("eyes2")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
        }
 
    }
    
}

struct Eyes_Previews: PreviewProvider {
    static var previews: some View {
        Eyes()
    }
}


extension Eyes {
    
    private var header: some View{
        Text("Eyes")
            .fontWeight(.bold)
            .foregroundColor(.cyan)
            .font(.system(size: 60))

    }
     
    private var textFieldSize: some View {
        TextField("Add size",text: $vm.size)
            .frame(height: 60)
            .padding(.leading)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(13)
    }
    
    
    private var textFieldDate: some View {
        TextField("Add date",text: $vm.date)
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
    
    private var textFieldColor: some View {
        TextField("Add color",text: $vm.color)
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

struct eyeDetail: View {
    
    let eye: eyeModel
    
    @StateObject private var vm = EyeInfoViewModel()

    @State private var sizeNew = ""
    @State private var priceNew = ""
    @State private var dateNew = ""
    @State private var colorNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each pair of eyes
    var body: some View {

            VStack(alignment: .center, spacing: 49){
                Text(eye.Color)
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .bold()
                HStack(){
                    Text("SIZE:")
                        .padding(.leading)
                        .foregroundColor(.blue)
                        .bold()
                    Text(eye.Size)
                        .foregroundColor(.blue)
                    
                    TextField("New info here",
                              text:$sizeNew)
                    Button{
                        vm.updateSize(eye: eye, size : sizeNew)
                        
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
                    Text("DATE:")
                        .padding(.leading)
                        .foregroundColor(.blue)
                        .bold()
                    Text(eye.Date)
                        .foregroundColor(.blue)
                    
                    TextField("New info here",
                              text:$dateNew)
                    Button{
                        vm.updateDate(eye: eye, date: dateNew)
                        
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
                    Text("PRICE:")
                        .padding(.leading)
                        .foregroundColor(.blue)
                        .bold()
                    Text(eye.Price)
                        .foregroundColor(.blue)
                
                    TextField("New info here",
                              text:$priceNew)
                    Button{
                        vm.updatePrice(eye: eye, price : priceNew)
                        
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
                    Text("COLOR:")
                        .padding(.leading)
                        .foregroundColor(.blue)
                        .bold()
                    Text(eye.Color)
                        .foregroundColor(.blue)
                
                    TextField("New info here",
                              text:$colorNew)
                    Button{
                        vm.updateColor(eye: eye, color : colorNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                        
                            .cornerRadius(10)
                        
                            .background(Color.blue)
                    }.cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                    
                }.padding(.trailing)
                
            }
            .background(
               Image("eyes2")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
                
            }
        
    }

