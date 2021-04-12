//
//  ReadMidiView.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI
import AudioKit

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02X", $0) }.joined()
    }
}

struct ReadMidiView: View {
    var controller = ReadMidiController()

    @State private var data: MidiData = MidiData(
        bpm: 60,
        tracks: []
    )

    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                Text("\(data.bpm) bpm")
                ForEach(data.tracks.indices, id: \.self) { index in
                    let track = data.tracks[index]
                    Text("Track \(index + 1)")
                    
                    VStack(alignment: .leading) {
                        let midiData = track.getMIDINoteData()
                        ForEach(midiData.indices, id: \.self) { index in
                            let note = midiData[index]
                            let beat = String(format: "%.1f", note.position.beats)
                            Text("\(beat), Note: \(note.noteNumber), CH: \(note.channel), V: \(note.velocity)")
                        }

                        ForEach(track.programChangeEvents.indices, id: \.self) { index in
                            let pc = track.programChangeEvents[index]
                            let time = String(format: "%.1f", pc.time)
                            Text("PC \(time), Number: \(pc.number), CH: \(pc.channel)")
                        }

                        ForEach((track.eventData ?? []).indices, id: \.self) { index in
                            let event = track.eventData![index]
                            let time = String(format: "%.1f", event.time)
                            let data = Data(bytes: event.data!, count: Int(event.dataSize))
                            Text("Event \(time), \(event.type), Data: \(data.hexEncodedString()), DataSize: \(event.dataSize)")
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            data = controller.setup(path: Bundle.main.path(forResource: "sample", ofType: "mid") ?? "")
        }
        .onDisappear {
            controller.dispose()
        }

    }
}

struct ReadMidiView_Previews: PreviewProvider {
    static var previews: some View {
        ReadMidiView()
    }
}

class ReadMidiController {
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
}

struct MidiData {
    var bpm: Int
    var tracks: [AudioKit.AKMusicTrack]
}
