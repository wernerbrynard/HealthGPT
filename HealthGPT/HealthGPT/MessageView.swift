//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MessageView: View {
    var message: Message

    var body: some View {
        let botBackgroundColor = Color(red: 0.8, green: 0.9, blue: 1.0)
        let userBackgroundColor = Color(red: 0.95, green: 0.95, blue: 0.95)
        let botBorderColor = Color(red: 0.6, green: 0.8, blue: 1.0)
        let userBorderColor = Color(red: 0.906, green: 0.898, blue: 0.894)

        HStack {
            Spacer()
                .frame(width: message.isBot ? 10 : 30)
            Text(message.content)
                .frame(maxWidth: .infinity)
                .padding(12)
                .foregroundColor(Color.black)
                .background(message.isBot ? botBackgroundColor : userBackgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(message.isBot ? botBorderColor : userBorderColor, lineWidth: 1)
                )
            Spacer()
                .frame(width: message.isBot ? 30 : 10)
        }
    }
}
