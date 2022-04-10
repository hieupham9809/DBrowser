//
//  HeaderItemView.swift
//  DBrowser
//
//  Created by Harley Pham on 09/04/2022.
//

import SwiftUI

struct HeaderItemView<Content: View>: View {
    @ViewBuilder let content: Content
    @Binding var currentOrderColumn: String?
    let itemValue: String
    let orderAction: ((_ column: String) -> Void)

    init(
        @ViewBuilder content: () -> Content,
        itemValue: String,
        currentOrderColumn: Binding<String?>,
        action: @escaping (_ column: String) -> Void
    ) {
        self.content = content()
        self.itemValue = itemValue
        self._currentOrderColumn = currentOrderColumn
        self.orderAction = action
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack { content }
                .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 0))

            if currentOrderColumn == itemValue {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .renderingMode(.template)
                    .foregroundColor(.white)
            }
            Image("").resizable().onTapGesture { // using button didn't work as expected
                orderAction(itemValue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(4)
        .border(Color.gray)
    }
}

struct HeaderItemView_Previews: PreviewProvider {
    @State static var currentOrderColumn: String? = "column2"
    static var previews: some View {
        ContentView {
            HeaderItemView(
                content: { Text("Header") },
                itemValue: "column1",
                currentOrderColumn: $currentOrderColumn,
                action: { _ in }
            )
        }
        .frame(width: 200, height: 100, alignment: .center)
    }
}

struct ContentView <Content: View>: View {

    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        VStack {
            content()  // <<: Do anything you want with your imported View here.
        }
    }
}
