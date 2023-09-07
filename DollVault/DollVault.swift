//
//  DollVault.swift
//  DV_01
//
//  Created by Sijie Wang Belcher on 1/30/23.
//

import SwiftUI
import CloudKit

struct DollVault: View {
    var dolls = ["Dolls"]
    var body: some View {
        NavigationView{
            VStack(alignment: .center, spacing: 30){
                Text("Doll Vault")
                    .fontWeight(.bold)
                    .font(.system(size: 80))
                    .foregroundColor(.teal)
                    .padding(.bottom)
                NavigationLink(destination: Dolls()){
                    HStack{
                        Text("Dolls")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 140, height: 60)
                            .cornerRadius(10)
                            .background(Color.teal)
                        }
                    }.cornerRadius(10)
                        NavigationLink(destination: Items()){
                            Text("Items")
                               .font(.system(size: 30))
                               .fontWeight(.bold)
                               .foregroundColor(.white)
                               .frame(width: 140, height: 60)
                               .cornerRadius(10)
                               .background(Color.teal)
                            }.cornerRadius(10)
                        NavigationLink(destination: Wishes()){
                            Text("Wishes")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 60)
                                .background(Color.teal)
                            }.cornerRadius(10)
                    }
                      .background(
                        Image("Background1")
                            .resizable()
                            .frame(width: 500, height:1100, alignment: .topLeading)
                             )
                             
                         }
                            .navigationBarBackButtonHidden()
                            .navigationBarTitle("DOLL VAULT")
                    }
            }
                
    
    struct DollVault_Previews: PreviewProvider {
        static var previews: some View {
            DollVault()
        }
    }
    



