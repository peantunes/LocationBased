//
//  LastLocationWidgetBundle.swift
//  LastLocationWidget
//
//  Created by Pedro Antunes on 14/11/2023.
//

import WidgetKit
import SwiftUI

@main
struct LastLocationWidgetBundle: WidgetBundle {
    var body: some Widget {
        LastLocationWidget()
        LastLocationWidgetLiveActivity()
    }
}
