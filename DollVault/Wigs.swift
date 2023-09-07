//
//  Wigs.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 2/26/23.
//

import SwiftUI
import CloudKit



struct WigModel: Hashable {
    let Length: String
    let Record: CKRecord
    let Size: String
    let Date: String
    let Price: String
    let Color: String
}

class WigInfoViewModel: ObservableObject{
    
    @Published var length: String = ""
    @Published var size: String = ""
    @Published var date: String = ""
    @Published var price: String = ""
    @Published var color: String = ""
    @Published var wigs: [WigModel] = []


        

    
    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {
        guard !length.isEmpty else { return }
        guard !size.isEmpty else { return }
        guard !date.isEmpty else { return }
        guard !price.isEmpty else { return }
        guard !color.isEmpty else { return }
        addItem(Length: length, Size: size, Date: date, Price: price, Color: color)
        
    }
    
    private func addItem(Length: String, Size: String, Date: String, Price: String, Color: String) {
        let newWig = CKRecord(recordType: "Wig")
        newWig["Length"] = Length
        newWig["Size"] = Size
        newWig["Date"] = Date
        newWig["Price"] = Price
        newWig["Color"] = Color
        saveItem(record: newWig)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.async{
                self?.length = ""
                self?.size = ""
                self?.date = ""
                self?.price = ""
                self?.color = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Wig", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [WigModel] = []
        
 
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):
                guard let Length = Record["Length"] as? String else {
                    return
                }
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
                
                /*
                guard Record["Size"] is String else {
                    return
                }
                guard Record["Gender"] is String else {
                    return
                }
                guard Record["Price"] is String else {
                    return
                }
                 */
                returnedItems.append(WigModel(Length: Length, Record: Record, Size: Size, Date: Date, Price: Price, Color: Color))
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
        }
            
        
      
        DispatchQueue.main.async {
            queryOperation.queryResultBlock = { [weak self] returnedResult in print("RETURNED RESULT: \(returnedResult)")
                DispatchQueue.main.async {
                    self?.wigs = returnedItems
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
        let wig = wigs[index]
        let record = wig.Record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.wigs.remove(at: index)
            }
            
        }
        
    }
    
    func updateItem(wig: WigModel, length: String = ""){
        
        let Record = wig.Record
        /*
        @State var newName: String = ""
        
        var textField: some View {
            TextField("Add a doll...", text: $newName)
                .frame(height: 60)
                .padding(.leading)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(13)
        }
        */
        
        Record["Length"] = length
        saveItem(record: Record)
        
    }
    
    func updateSize(wig: WigModel, size: String = ""){
        
        let Record = wig.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    
    func updateDate(wig: WigModel, date: String = ""){
        
        let Record = wig.Record

        Record["Date"] = date
        saveItem(record: Record)
    }
    
    func updatePrice(wig: WigModel, price: String = ""){
        
        let Record = wig.Record

        Record["Price"] = price
        saveItem(record: Record)
    }
    
    func updateColor(wig: WigModel, color: String = ""){
        
        let Record = wig.Record

        Record["Color"] = color
        saveItem(record: Record)
    }
}

struct Wigs: View {

    @StateObject private var vm = WigInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newLength : [String] =  []
    @State var showSheet: Bool = false
    @State var lengthNew = ""
    @State var selectedItem: WigModel?

    
    var body: some View {
        NavigationView {

            VStack{
                header
                textField
                textFieldSize
                textFieldDate
                textFieldPrice
                textFieldColor
                addButton
                
                List {
                    
                    ForEach(vm.wigs, id: \.self) { wig in

                        HStack{

                            Text(wig.Length)
                                .onAppear(perform:  {selectedItem = wig})
                           
                            NavigationLink(destination: WigDetail(wig: wig)){
                            }
       
                        }
                        
                        
                        .sheet(isPresented: $showSheet, content: {
                            WigDetail(wig: wig)
                        
                        })

                    }
                    
                    
                    .onDelete(perform: vm.deleteItem(indexSet:))
                }
                .listStyle(PlainListStyle())
                
                
              
                
            }
            .padding()
            .navigationBarHidden(true)
            .background(
               Image("wig1")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
        
   
        }

    }
    
}

struct Wigs_Previews: PreviewProvider {
    static var previews: some View {
        Wigs()
    }
}


extension Wigs {
    
    private var header: some View{
        Text("Wigs")
            .fontWeight(.bold)
            .foregroundColor(.cyan)
            .font(.system(size: 60))

    }
    
    private var textField: some View {
        TextField("Add a wig length...",text: $vm.length)
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

struct WigDetail: View {
    
    let wig: WigModel
    
    @StateObject private var vm = WigInfoViewModel()
    @State private var lengthNew = ""
    @State private var sizeNew = ""
    @State private var priceNew = ""
    @State private var dateNew = ""
    @State private var colorNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each wig
    var body: some View {

            VStack(alignment: .center, spacing: 49){
                Text(wig.Length)
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .bold()
                HStack(){
                    
                    Text("LENGTH:")
                        .padding(.leading)
                        .foregroundColor(.blue)
                        .bold()
                    Text(wig.Length)
                        .foregroundColor(.blue)
                    
                    TextField("New info here",
                              text:$lengthNew
                              
                                    )
                    Button{
                        vm.updateItem(wig: wig, length: lengthNew)
                        DispatchQueue.main.async{
                            self.lengthNew = ""
                            self.sizeNew = ""
                            self.dateNew = ""
                            self.priceNew = ""
                            self.colorNew = ""
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
                        .foregroundColor(.blue)
                        .bold()
                    Text(wig.Size)
                        .foregroundColor(.blue)

                    TextField("New info here",
                              text:$sizeNew)
                    Button{
                        vm.updateSize(wig: wig, size : sizeNew)
                        
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
                    Text(wig.Date)
                        .foregroundColor(.blue)
                    
                    TextField("New info here",
                              text:$dateNew)
                    Button{
                        vm.updateDate(wig: wig, date: dateNew)
                        
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
                    Text(wig.Price)
                        .foregroundColor(.blue)
                    
                    TextField("New info here",
                              text:$priceNew)
                    
                    Button{
                        vm.updatePrice(wig: wig, price : priceNew)
                        
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
                    Text(wig.Color)
                        .foregroundColor(.blue)
                    
                    
                    TextField("New info here",
                              text:$colorNew)

                    
                    
                    Button{
                        vm.updateColor(wig: wig, color : colorNew)
                        
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
               Image("wig2")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
        }

    }

