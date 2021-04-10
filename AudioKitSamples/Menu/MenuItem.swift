//
//  MenuItem.swift
//  AudioKitSamples
//
//  Created by noboru-i on 2021/04/10.
//

import SwiftUI

struct MenuItem: View {
    var label: String

    var body: some View {
        Text(label)
    }
}

struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        MenuItem(label: "Test!!!")
    }
}
