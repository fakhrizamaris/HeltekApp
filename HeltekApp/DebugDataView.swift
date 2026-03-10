//
//  DebugDataView.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 10/03/26.
//

import SwiftUI
import SwiftData

struct DebugDataView: View {
    @Environment(\.modelContext) private var data
    
    @Query private var semuaProgress: [DailyProgress]
    
    var body: some View {
        VStack (spacing: 20) {
            Text("Tester SwiftData Heltek")
                .font(.title)
                .bold()
            
            Button(action: {
                tambahBaterai()
            }
            ) {
                Text("Simulasikan: Selesai Peregangan")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Divider()
            
            // Tampilkan data yang ada di database ke layar
            List(semuaProgress) { progress in
                VStack(alignment: .leading) {
                    Text("Tanggal: \(progress.date.formatted(date: .abbreviated, time: .omitted))")
                    Text("Isi Baterai (Selesai): \(progress.completedStretches) kali"
                        .font(.headline)
                        .foregroundColor(progress.completedStretches > 0 ? .green : .red)
                    Text("Target tercapai: \(progress.isGoalMet ? "Ya" : "Belum")")
                }
            }
        }
        .padding()
    }
    
    // fungsi nambah data
    private func tambahBaterai() {
        if let catatanHariIni = semuaProgress.first(where:  {Calendar.current.isDateInToday($0.date) }) {
            catatanHariIni.completedStretches += 1
            catatanHariIni.lastUpdated = Date()
            
            // cek apakah target 3 kali sehari sudah tercapai
            if catatanHariIni.completedStretches >= 3 {
                catatanHariIni.isGoalMet = true
            }
        } else {
            // kalau hari ini belum ada catatan sama sekali, buat catatan baru!
            let catatanBaru = DailyProgress(date: Date(), lasUpdated: Date())
            catatanBaru.completedStretches = 1 // langsung hitung 1
            
            // simpan ke SwiftData
            context.insert(catatanBaru)
        }
    }
}
