//
//  houseCode.swift
//  myPantry
//
//  Created by Abhinav Pappu on 3/23/24.
//

import SwiftUI


let houseName = UserDefaults.standard.string(forKey: "House")



struct houseCode: View {
    var body: some View {
        Text("\(houseName)")
        
    }
}

struct housecode_preview: PreviewProvider {
    static var previews: some View {
        houseCode()
    }
}
