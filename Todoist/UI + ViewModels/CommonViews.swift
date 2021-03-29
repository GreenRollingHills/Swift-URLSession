//
//  CommonViews.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/27/21.
//

import SwiftUI

struct ProgressViewCommon: View {
    
    @Binding var spinner:Bool
    
    init(spinner:Binding<Bool>) {
        _spinner = spinner
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 16)
            ProgressView().opacity(spinner ? 1.0 : 0).progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                .scaleEffect(1.5, anchor: .center)
            Spacer()
        }
    }
}

struct CommonViews_Previews: PreviewProvider {
    static var previews: some View {
        ProgressViewCommon(spinner: .constant(false))
    }
}
