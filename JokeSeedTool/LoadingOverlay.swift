//
//  LoadingOverlay.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/25/22.
//

import SwiftUI

struct LoadingOverlay: View {
    let isLoading: Bool
    let text: String
    
    @ViewBuilder
    var body: some View {
        if isLoading {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    loadingIndicator()
                    Spacer()
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 0.85))
        }
    }
    
    func loadingIndicator() -> some View {
        ZStack {
            ZStack {
                Text(text)
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                    .padding(.horizontal, 6)
            }
            .frame(width: 138, height: 138, alignment: Alignment(horizontal: .center, vertical: .bottom))
            .background(RoundedRectangle(cornerRadius: 12).fill().foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 0.90)))
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
            
        }
        .frame(width: 140, height: 140)
        .background(RoundedRectangle(cornerRadius: 12).fill().foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55, opacity: 0.65)))
    }
}


struct LoadingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    button("Generate Words") {
                    }
                    button("Stamp Words") {
                    }
                    button("Fix Edges") {
                    }
                }
                .padding(.all, 12)
                .background(RoundedRectangle(cornerRadius: 16).fill().foregroundColor(Color(red: 0.625, green: 0.825, blue: 0.75)))
                .background(RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 4).foregroundColor(Color(red: 0.525, green: 0.625, blue: 0.65)))
                
                Spacer()
            }
            Spacer()
        }
        .frame(width: 768, height: 512, alignment: .center)
        .background(Color.white)
        .overlay(LoadingOverlay(isLoading: true, text: "asdf sdfsdfs dfs dg sdgsdf gsdfs dgsdgsdf"))
    }
    
    static func button(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            print("Clicked: {\(title)}")
            action()
        } label: {
            ZStack {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(width: 180, height: 56)
            .background(RoundedRectangle(cornerRadius: 16).fill().foregroundColor(Color(red: 0.125, green: 0.325, blue: 0.85)))
            .background(RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 4).foregroundColor(Color(red: 0.025, green: 0.025, blue: 0.65)))
        }
        .buttonStyle(.plain)
        
    }
}
