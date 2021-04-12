//
//  CreateMidiView.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/12.
//

import SwiftUI
import AudioKit

struct CreateMidiView: View {
    var controller = CreateMidiController()
    
    var body: some View {
        VStack {
            Button("Export") {
                let outputData = controller.create1()
                let av = UIActivityViewController(activityItems: [outputData!], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)

            }
        }
    }
}

struct CreateMidiView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMidiView()
    }
}

class CreateMidiController {
    private var sequencer: AKAppleSequencer!
    
    func setup(path: String) -> MidiData {
        sequencer = AKAppleSequencer(fromURL: URL(fileURLWithPath: path))
        print("tempo \(Int(sequencer.getTempo(at: 0)))")

        return MidiData(
            bpm: Int(sequencer.getTempo(at: 0)),
            tracks: sequencer.tracks
        )
    }

    func dispose() {
    }
    
    func create1() -> Data? {
        let noteInfoList: [AKMIDINoteData] = [
            AKMIDINoteData(noteNumber: 60, velocity: 128, channel: 0, duration: AKDuration(beats: 1), position: AKDuration(beats: 0))
        ]
        let bpm = 60.0

        // create MIDI for output
        let outputSequncer = AKAppleSequencer()
        outputSequncer.setTempo(bpm)
        outputSequncer.setLength(AKDuration(beats: 8))

        // save input data
        let track = outputSequncer.newTrack()
        noteInfoList.forEach { info in
            track?.add(midiNoteData: info)
        }

        guard let data = outputSequncer.genData() else {
            print("error in genData")
            return nil
        }
        print("data.count \(data.count)")
        return data
    }
}
