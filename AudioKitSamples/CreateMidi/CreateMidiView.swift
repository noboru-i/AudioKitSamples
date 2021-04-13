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
    
    func setup(path: String) {
    }

    func dispose() {
    }
    
    func create1() -> Data? {
        let noteInfoList: [AKMIDINoteData] = [
            AKMIDINoteData(noteNumber: 60, velocity: 100, channel: 0, duration: AKDuration(beats: 0.2), position: AKDuration(beats: 1))
        ]
        let bpm = 61.0

        // create MIDI for output
        let outputSequncer = AKAppleSequencer()
        outputSequncer.setTempo(bpm)
        outputSequncer.setLength(AKDuration(beats: 16))

        // save input data
        let trackMeta = outputSequncer.newTrack()
        let track = outputSequncer.newTrack()
        print("track \(track.debugDescription)")
        track?.setLength(AKDuration(beats: 16))
        noteInfoList.forEach { info in
            track?.add(midiNoteData: info)
        }
        
        // test control data
        track?.addController(AKMIDIControl.cc32.rawValue, value: 1, position: AKDuration(beats: 0.01))

        guard let data = outputSequncer.genData() else {
            print("error in genData")
            return nil
        }
        print("data.count \(data.count)")
        return data
    }
}
