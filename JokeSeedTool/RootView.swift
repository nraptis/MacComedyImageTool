//
//  RootView.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                decoration()
                
                Spacer()
                    .frame(width: 64)
                
                controlPanel()
                
                Spacer()
                    .frame(width: 64)
                
                decoration()
                
                Spacer()
            }
            Spacer()
        }
        .frame(width: 768, height: 512, alignment: .center)
        .background(Color.white)
        .overlay(LoadingOverlay(isLoading: viewModel.isLoading, text: viewModel.loadingText))
    }
    
    func controlPanel() -> some View {
        VStack(spacing: 12) {
            
            
            Text("\(viewModel.bitCount) Bits Loaded")
                .font(.title2.bold())
                .foregroundColor(.black)
            
            button("Generate Words") {
                print("Generating Words based on \"Assets/words.txt\"")
                self.viewModel.generateWords()
            }
            button("Stamp Words") {
                print("Stamping words on \"background.png\", expecting words in \"Assets/[text]/\"")
                self.viewModel.stampWords()
            }
            button("Fix Edges") {
                print("Fixing edges using \"Assets/[edges]/*\", expecting words in \"Assets/[text]/\"")
                self.viewModel.fixEdges()
            }
            button("Print Fontbook") {
                print("Printing the fonts...")
                self.viewModel.printFonts()
            }
            button("Print Phrases") {
                print("Printing the words...")
                self.viewModel.printBits()
            }
            
        }
        .padding(.all, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill().foregroundColor(Color(red: 0.625, green: 0.825, blue: 0.75)))
        .background(RoundedRectangle(cornerRadius: 16).stroke(lineWidth: 2).foregroundColor(Color(red: 0.525, green: 0.625, blue: 0.65)))
    }
    
    func decoration() -> some View {
        ZStack {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 120, height: 120)
        }
        .frame(width: 160, height: 160)
        .background(Circle().fill().foregroundColor(Color(red: 0.625, green: 0.825, blue: 0.75)))
        .background(Circle().stroke(lineWidth: 2).foregroundColor(Color(red: 0.425, green: 0.65, blue: 0.55)))
    }
    
    func button(_ title: String, action: @escaping () -> Void) -> some View {
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

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: ViewModel.preview())
    }
}
