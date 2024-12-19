//
//  CVSImport.swift
//  Trading
//
//  Created by Cale Lane on 12/19/24.
//

//
//  CSVImportView.swift
//  Trading
//
//  Created by Cale Lane on 12/19/24.
//

import SwiftUI

struct CSVImportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("CSV Import Coming Soon")
            }
            .navigationTitle("Import CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
