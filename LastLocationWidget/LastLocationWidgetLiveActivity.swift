//
//  LastLocationWidgetLiveActivity.swift
//  LastLocationWidget
//
//  Created by Pedro Antunes on 14/11/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LastLocationWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LastLocationWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LastLocationWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LastLocationWidgetAttributes {
    fileprivate static var preview: LastLocationWidgetAttributes {
        LastLocationWidgetAttributes(name: "World")
    }
}

extension LastLocationWidgetAttributes.ContentState {
    fileprivate static var smiley: LastLocationWidgetAttributes.ContentState {
        LastLocationWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LastLocationWidgetAttributes.ContentState {
         LastLocationWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LastLocationWidgetAttributes.preview) {
   LastLocationWidgetLiveActivity()
} contentStates: {
    LastLocationWidgetAttributes.ContentState.smiley
    LastLocationWidgetAttributes.ContentState.starEyes
}
