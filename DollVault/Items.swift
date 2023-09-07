//
//  DollDetail.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 2/20/23.
//

import SwiftUI
import CloudKit

struct Items: View {
    var body: some View {
        NavigationView{
    
                             VStack(alignment: .center, spacing: 49){
                               
                                 Text("Items")
                                     .fontWeight(.bold)
                                     .font(.system(size: 100))
                                     .foregroundColor(.cyan)
                                     .padding(.leading)
                                   
                                 NavigationLink(destination: Clothes()){
                        
                                     HStack{
                                         Text("Clothes")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 140, height: 60)
                                           
                                            .cornerRadius(10)
                                           
                                            .background(Color.cyan)
                                     }
                                 }.cornerRadius(10)
                                 NavigationLink(destination: Wigs()){
                            
                                     Text("Wigs")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 140, height: 60)
                                       
                                        .cornerRadius(10)
                                       
                                        .background(Color.cyan)
                                 }.cornerRadius(10)
                                 NavigationLink(destination: Eyes()){
                               
                                     Text("Eyes")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 140, height: 60)
                                       
                                        .cornerRadius(10)
                                       
                                        .background(Color.cyan)
                                 }.cornerRadius(10)
                                 
                             }
                             .background(
                                Image("items")
                                    .resizable()
                                    .frame(width: 500, height:1100, alignment: .topLeading)
               
                             )
                       
                             
                         }
                            
                         
                            .navigationBarTitle("DOLL VAULT")
        
     
                         }

            }


struct Items_Previews: PreviewProvider {
    static var previews: some View {
        Items()
    }
}
