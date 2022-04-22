//
//  HeaderItemView.swift
//  DBrowser
//
//  Created by Harley Pham on 09/04/2022.
//

import SwiftUI

struct HeaderItemView<Content: View>: View {
    @ViewBuilder let content: Content
    @Binding var currentOrderColumn: SortingValue?
    let itemValue: String


    init(
        @ViewBuilder content: () -> Content,
        itemValue: String,
        currentOrderColumn: Binding<SortingValue?>
    ) {
        self.content = content()
        self._currentOrderColumn = currentOrderColumn
        self.itemValue = itemValue
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack { content }
                .padding(EdgeInsets(top: 14, leading: 14, bottom: 0, trailing: 0))

            if currentOrderColumn?.columnValue == itemValue {
                Image(
                    systemName: currentOrderColumn?.order == .desc ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                )
                .renderingMode(.template)
                .foregroundColor(.white)
            }
            Image("").resizable().onTapGesture { // using button didn't work as expected
                if currentOrderColumn?.columnValue == itemValue {
                    currentOrderColumn?.toggle()
                }
                else {
                    currentOrderColumn = SortingValue(order: .asc, columnValue: itemValue)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(4)
        .border(Color.gray)
    }
}

struct HeaderItemView_Previews: PreviewProvider {
    @State static var currentOrderColumn: SortingValue? = SortingValue(order: .asc, columnValue: "column1")
    static var previews: some View {
        ContentView {
            HeaderItemView(
                content: { Text("Header") },
                itemValue: "column1",
                currentOrderColumn: $currentOrderColumn
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
