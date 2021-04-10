//
//  MetronomeView.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI
import AudioKit

struct MetronomeView: View {
    var controller = MetronomeController()

    @State private var isPlaying: Bool = false
    @State private var currentSetting: MetronomeSetting = MetronomeSetting(
        tempo: 60,
        subdivision: 4,
        frequency1: 2000,
        frequency2: 1000
    )

    var body: some View {
        VStack {
            Slider(
                value: $currentSetting.tempo,
                in: 1...280,
                onEditingChanged: {_ in }
            )
            Text("Tempo: \(currentSetting.tempo)")

//            Slider(
//                value: $currentSetting.subdivision,
//                in: 1...8,
//                onEditingChanged: {_ in }
//            )
//            Text("Subdivision: \(currentSetting.subdivision)")

            Slider(
                value: $currentSetting.frequency1,
                in: 1...8000,
                onEditingChanged: {_ in }
            )
            Text("Frequency1: \(currentSetting.frequency1)")

            Slider(
                value: $currentSetting.frequency2,
                in: 1...8000,
                onEditingChanged: {_ in }
            )
            Text("Frequency1: \(currentSetting.frequency2)")

            Button("Start / Stop") {
                if (isPlaying) {
                    controller.stop()
                } else {
                    controller.start()
                }
                isPlaying = !isPlaying
            }
        }
        .onChange(of: currentSetting, perform: { value in
            controller.updateSetting(currentSetting)
        })
        .padding()
        .onAppear {
            controller.setup(setting: currentSetting)
        }
        .onDisappear {
            controller.dispose()
        }
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView()
    }
}

class MetronomeController {
    lazy private var metronome = AKMetronome()
    lazy private var mixier = AKMixer(metronome)

    func setup(setting: MetronomeSetting) {
        AKManager.output = mixier
        do {
            try AKManager.start()
        } catch let error {
            print("AKManager.start error. \(error)")
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
    
    func start() {
        metronome.reset()
        metronome.restart()
    }
    
    func stop() {
        metronome.stop()
        metronome.reset()
    }
    
    func updateSetting(_ setting: MetronomeSetting) {
        metronome.tempo = setting.tempo
        metronome.subdivision = setting.subdivision
        metronome.frequency1 = setting.frequency1
        metronome.frequency2 = setting.frequency2
    }
}

struct MetronomeSetting: Equatable {
    var tempo: Double
    var subdivision: Int
    var frequency1: Double
    var frequency2: Double
}
