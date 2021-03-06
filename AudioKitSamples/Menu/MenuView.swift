//
//  MenuView.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: PlayMidiWithSf2View()) {
                    MenuItem(label: "Play MIDI with sf2")
                }
                NavigationLink(destination: ReadMidiView()) {
                    MenuItem(label: "Read MIDI")
                }
                NavigationLink(destination: CreateMidiView()) {
                    MenuItem(label: "Create MIDI")
                }
                NavigationLink(destination: MetronomeView()) {
                    MenuItem(label: "Metronome")
                }
            }
            .navigationTitle("Menu")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
