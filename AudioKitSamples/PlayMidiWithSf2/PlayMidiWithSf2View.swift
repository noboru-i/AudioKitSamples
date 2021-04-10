//
//  PlayMidiWithSf2View.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI
import AudioKit

struct PlayMidiWithSf2View: View {
    var controller = PlayMidiController()

    @State private var noteNumber: Double = 60

    var body: some View {
        VStack {
            Text("Play MIDI. Note Number: \(String(format: "%.0f", noteNumber))")
            Slider(
                value: $noteNumber,
                in: 0...127,
                onEditingChanged: {_ in }
            )
            Button(action: playNote) {
                Text("Play note")
            }
        }.onAppear {
            controller.setup()
        }.onDisappear {
            controller.dispose()
        }
    }

    func playNote() {
        controller.playNote(number: Int(noteNumber))
    }
}

struct PlayMidiWithSf2View_Previews: PreviewProvider {
    static var previews: some View {
        PlayMidiWithSf2View()
    }
}

class PlayMidiController {
    lazy private var tapSampler = AKMIDISampler(midiOutputName: nil)
    lazy private var mixier = AKMixer(tapSampler)

    let sf2FilePath = "YAMAHA_RX5"

    func setup() {
        AKManager.output = mixier
        do {
            try AKManager.start()
        } catch let error {
            print("AKManager.start error. \(error)")
            return
        }

        do {
            try tapSampler.loadSoundFont(sf2FilePath, preset: 7, bank: kAUSampler_DefaultBankLSB)
        } catch let error {
            print("File not found. \(error.localizedDescription)")
            return
        }
    }

    func dispose() {
        do {
            try AKManager.stop()
        } catch let error {
            print("AKManager.stop error. \(error)")
            return
        }
    }

    func playNote(number: Int) {
        do {
            try tapSampler.play(noteNumber: MIDINoteNumber(number), velocity: 127, channel: 0)
        } catch let error {
            print("Error in playNote. \(error)")
        }
    }
}
