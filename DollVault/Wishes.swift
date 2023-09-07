//
//  Wishes.swift
//  DollVault
//
//  Created by Sijie Wang Belcher on 2/25/23.
//

import SwiftUI
import CloudKit

struct Wishes: View {
    var body: some View {
        NavigationView{

            VStack(alignment: .center, spacing: 20){
                                 Text("Wishes")
                                     .fontWeight(.bold)
                                     .font(.system(size: 80))
                                     .foregroundColor(.purple)
                                     .padding(.bottom)
                                 
                                 NavigationLink(destination: Doll_wishes()){
                                
                                     HStack{
                                         Text("Dolls")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 160, height: 60)
                                           
                                            .cornerRadius(10)
                                           
                                            .background(Color.purple)
                                     }
                                 }  .cornerRadius(10)
                                 
                                 NavigationLink(destination: Clothes_wishes()){
                                     //ForEach (dolls, id: \.self){ //dollName in
                                     HStack{
                                         Text("Clothes")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 160, height: 60)
                                           
                                            .cornerRadius(10)
                                           
                                            .background(Color.purple)
                                     }
                                 }  .cornerRadius(10)
                                 
                                 NavigationLink(destination: Wig_wishes()){
                                     
                                     Text("Wigs")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 160, height: 60)
                                       
                                        .cornerRadius(10)
                                       
                                        .background(Color.purple)
                                 }  .cornerRadius(10)
                                 
                                 NavigationLink(destination: Eye_wishes()){
                                     Text("Eyes")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 160, height: 60)
                                       
                                        .cornerRadius(10)
                                       
                                        .background(Color.purple)
                                 }  .cornerRadius(10)
                                 
                                 NavigationLink(destination: Services()){
                                     //ForEach (dolls, id: \.self){ //dollName in
                                     HStack{
                                         Text("Services")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 160, height: 60)
                                           
                                            .cornerRadius(10)
                                           
                                            .background(Color.purple)
                                     }  .cornerRadius(10)
                                 }
                             }
                             .background(
                                Image("closet")
                                    .resizable()
                                    .frame(width: 500, height:1100, alignment: .topLeading)
                                
                             
                             )
        
                         }
                          
                            .navigationBarTitle("DOLL VAULT")
     
                         }

                
            }


struct Wishes_Previews: PreviewProvider {
    static var previews: some View {
        Wishes()
    }
}
