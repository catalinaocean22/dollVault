//
//  Clothes.swift
//  DV_01
//
//  Created by Sijie Wang Belcher on 1/30/23.
//

import SwiftUI
import CloudKit



struct ClothingModel: Hashable {
    let Style: String
    let Record: CKRecord
    let Size: String
    let Date: String
    let Price: String
    let Color: String
}

class ClothingInfoViewModel: ObservableObject{
    
    @Published var style: String = ""
    @Published var size: String = ""
    @Published var date: String = ""
    @Published var price: String = ""
    @Published var color: String = ""
    @Published var clothes: [ClothingModel] = []


        

    
    init(){
        self.fetchItems()
    }
    
    func addButtonPressed() {
        guard !style.isEmpty else { return }
        guard !size.isEmpty else { return }
        guard !date.isEmpty else { return }
        guard !price.isEmpty else { return }
        guard !color.isEmpty else { return }
        addItem(Style: style, Size: size, Date: date, Price: price, Color: color)
        
    }
    
    private func addItem(Style: String, Size: String, Date: String, Price: String, Color: String) {
        let newClothing = CKRecord(recordType: "Clothing")
        newClothing["Style"] = Style
        newClothing["Size"] = Size
        newClothing["Date"] = Date
        newClothing["Price"] = Price
        newClothing["Color"] = Color
        saveItem(record: newClothing)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(String(describing: returnedRecord))")
            print("Error: \(String(describing: returnedError))")
            
            DispatchQueue.main.async{
                self?.style = ""
                self?.size = ""
                self?.date = ""
                self?.price = ""
                self?.color = ""
            }
        }
    }
    
    func fetchItems(){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Clothing", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [ClothingModel] = []
        
 
        queryOperation.recordMatchedBlock = {(returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let Record):
                guard let Style = Record["Style"] as? String else {
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
                returnedItems.append(ClothingModel(Style: Style, Record: Record, Size: Size, Date: Date, Price: Price, Color: Color))
            case .failure(let error):
                print("Error recordMachedBlock: \(error)")
            }
        }
            
        
      
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
    
    func updateItem(clothing: ClothingModel, style: String = ""){
        
        let Record = clothing.Record
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
        
        Record["Style"] = style
        saveItem(record: Record)
        
    }
    
    func updateSize(clothing: ClothingModel, size: String = ""){
        
        let Record = clothing.Record

        Record["Size"] = size
        saveItem(record: Record)
    }
    
    func updateDate(clothing: ClothingModel, date: String = ""){
        
        let Record = clothing.Record

        Record["Date"] = date
        saveItem(record: Record)
    }
    
    func updatePrice(clothing: ClothingModel, price: String = ""){
        
        let Record = clothing.Record

        Record["Price"] = price
        saveItem(record: Record)
    }
    
    func updateColor(clothing: ClothingModel, color: String = ""){
        
        let Record = clothing.Record

        Record["Color"] = color
        saveItem(record: Record)
    }
}

struct Clothes: View {

    @StateObject private var vm = ClothingInfoViewModel()
    @State private var isEditing: Bool = false
    @State var newStyle : [String] =  []
    @State var showSheet: Bool = false
    @State var styleNew = ""
    @State var selectedItem: ClothingModel?
    /*
    func newNames(a_doll: String) {
        newName.append(a_doll)
    }
    */
    
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
                    
                    ForEach(vm.clothes, id: \.self) { clothing in
                        

                        HStack{

                            Text(clothing.Style)
                                .onAppear(perform:  {selectedItem = clothing})
                           
                            NavigationLink(destination: ClothingDetail(clothing: clothing)){
                            }
                            
                        }
                        
                        .sheet(isPresented: $showSheet, content: {
                            ClothingDetail(clothing: clothing)
                        
                        })

                    }

                    .onDelete(perform: vm.deleteItem(indexSet:))
                }
                .listStyle(PlainListStyle())
                
            }
            .padding()
            .navigationBarHidden(true)
            .background(
               Image("clothing")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
        
           
        }

    }
    
}

struct Clothes_Previews: PreviewProvider {
    static var previews: some View {
        Clothes()
    }
}


extension Clothes {
    
    private var header: some View{
        Text("Clothes")
            .fontWeight(.bold)
            .foregroundColor(.cyan)
            .font(.system(size: 60))

    }
    
    private var textField: some View {
        TextField("Add a clothing style...",text: $vm.style)
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

struct ClothingDetail: View {
    
    let clothing: ClothingModel
    
    @StateObject private var vm = ClothingInfoViewModel()
    @State private var styleNew = ""
    @State private var sizeNew = ""
    @State private var priceNew = ""
    @State private var dateNew = ""
    @State private var colorNew = ""
    
    @Environment(\.presentationMode) var presentationMode
    // Display data fields for each clothing
    var body: some View {

        VStack(alignment: .center, spacing: 49){
              
                Text(clothing.Style)
                    .font(.title)
                    .foregroundColor(.gray)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .bold()
                HStack(){
                    
                    Text("STYLE:")
                        .padding(.leading)
                        .foregroundColor(.gray)
                        .bold()
                    Text(clothing.Style)
                        .foregroundColor(.gray)
                   
                    TextField("New info here",
                              text:$styleNew
                                    )
                    
                    Button{
                        vm.updateItem(clothing: clothing, style: styleNew)
                        DispatchQueue.main.async{
                            self.styleNew = ""
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
                           
                            .background(Color.cyan)
                        
                            
                    } .cornerRadius(10)
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("SIZE:")
                        .padding(.leading)
                        .foregroundColor(.blue)
                        .bold()
                    Text(clothing.Size)
                        .foregroundColor(.blue)
                    
                    
                    TextField("New info here",
                              text:$sizeNew)
          
                    
                    Button{
                        vm.updateSize(clothing: clothing, size : sizeNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.cyan)
                    }.cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("DATE:")
                        .padding(.leading)
                        .foregroundColor(.cyan)
                        .bold()
                    Text(clothing.Date)
                        .foregroundColor(.cyan)
                    
                    
                    
                    TextField("New info here",
                              text:$dateNew)
                    
                    
                    
                    Button{
                        vm.updateDate(clothing: clothing, date: dateNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.cyan)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                }.padding(.trailing)
                
                HStack(){
                    Text("PRICE:")
                        .padding(.leading)
                        .foregroundColor(.cyan)
                        .bold()
                    Text(clothing.Price)
                        .foregroundColor(.cyan)

                    TextField("New info here",
                              text:$priceNew)
                    
                    Button{
                        vm.updatePrice(clothing: clothing, price : priceNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.cyan)
                    }.buttonStyle(BorderlessButtonStyle())
                        .cornerRadius(10)
                    
                }.padding(.trailing)
                
                HStack(){
                    Text("COLOR:")
                        .padding(.leading)
                        .foregroundColor(.cyan)
                        .bold()
                    Text(clothing.Color)
                        .foregroundColor(.cyan)
                    
                    
                    TextField("New info here",
                              text:$colorNew)
                    
                    Button{
                        vm.updateColor(clothing: clothing, color : colorNew)
                        
                    } label: {
                        Text("Update")
                        
                            .foregroundColor(.white)
                            .frame(width: 90, height: 40)
                           
                            .cornerRadius(10)
                           
                            .background(Color.cyan)
                    }.cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                    
                }.padding(.trailing)
                
            }
            .background(
               Image("bluedress")
                   .resizable()
                   .frame(width: 500, height:1100, alignment: .topLeading)
            )
        }

    }


