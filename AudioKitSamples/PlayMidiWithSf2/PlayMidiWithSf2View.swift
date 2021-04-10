//
//  PlayMidiWithSf2View.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI
import AudioKit

enum BankPreset {
    case melodic7
    case melodic12
    case percussion0

    var preset: Int {
        switch self {
        case .melodic7:
            return 7
        case .melodic12:
            return 12
        case .percussion0:
            return 0
        }
    }
    var bank: Int {
        switch self {
        case .melodic7:
            return kAUSampler_DefaultBankLSB
        case .melodic12:
            return kAUSampler_DefaultBankLSB
        case .percussion0:
            return 128
        }
    }
}

struct PlayMidiWithSf2View: View {
    var controller = PlayMidiController()

    @State private var noteNumber: Double = 60
    @State private var selectedBankPreset = BankPreset.melodic7

    var body: some View {
        VStack {
            Picker("Bank, Preset",
                   selection: $selectedBankPreset) {
                Text("Melodic 7").tag(BankPreset.melodic7)
                Text("Melodic 12").tag(BankPreset.melodic12)
                Text("Percussion 0").tag(BankPreset.percussion0)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedBankPreset, perform: { value in
                controller.changeSampler(preset: value.preset, bank: value.bank)
            })
            Spacer()
                .frame(height: 50)
            Slider(
                value: $noteNumber,
                in: 0...127,
                onEditingChanged: {_ in }
            )
            Text("Note Number: \(String(format: "%.0f", noteNumber))")
            Spacer()
                .frame(height: 50)
            Button("Play note", action: playNote)
        }
        .padding()
        .onAppear {
            controller.setup()
        }
        .onDisappear {
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

    func changeSampler(preset: Int, bank: Int) {
        do {
            try tapSampler.loadSoundFont(sf2FilePath, preset: preset, bank: bank)
        } catch let error {
            print("Failed to changeSampler. \(error.localizedDescription)")
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
