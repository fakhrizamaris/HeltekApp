//
//  Exercise.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import Foundation

// MARK: - 1. DATA MODELS
// Struktur data untuk Plan Utama (Card di halaman depan)
struct ExercisePlan: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String      // misal: "60 sec", "2 min"
    let calories: Int         // Estimasi kalori terbakar
    let targetArea: String    // misal: "Upper Body", "Lower Back"
    let imageName: String     // Nama gambar cover di folder Assets
    let steps: [ExerciseStep] // Daftar gerakannya
}

// Struktur data untuk detail tiap gerakan
struct ExerciseStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let instruction: String
    let function: String
    let durationOrReps: String
    let imageName: String     // Nama gambar thumbnail gerakan
}

// MARK: - 2. HARDCODED MOCK DATA
// Menyimpan data yang kamu berikan agar siap dipanggil oleh UI
extension ExercisePlan {
    static let mockData: [ExercisePlan] = [
        
        // KATEGORI A: Leher & Bahu
        ExercisePlan(
            title: "Neck & Shoulder Relief",
            description: "Mengatasi kaku akibat terlalu fokus menatap layar.",
            duration: "1 min",
            calories: 8,
            targetArea: "Upper Body",
            imageName: "cover_neck_shoulder", // Nanti siapkan gambar dengan nama ini di Assets
            steps: [
                ExerciseStep(
                    title: "Chin Tucks",
                    instruction: "Tarik dagu ke belakang (membuat double chin) tanpa menunduk.",
                    function: "Mengembalikan posisi kepala agar tidak maju ke depan.",
                    durationOrReps: "Tahan 3 detik",
                    imageName: "step_chin_tucks"
                ),
                ExerciseStep(
                    title: "Neck Side Tilt",
                    instruction: "Miringkan kepala ke kanan, bantu dengan tangan kanan. Ulangi sisi kiri.",
                    function: "Melenturkan otot leher samping yang tegang.",
                    durationOrReps: "Tahan 15 detik",
                    imageName: "step_neck_tilt"
                ),
                ExerciseStep(
                    title: "Shoulder Blade Squeezes",
                    instruction: "Tarik kedua belikat ke belakang hingga dada membusung.",
                    function: "Memperbaiki postur bahu yang membungkuk.",
                    durationOrReps: "Tahan 5 detik",
                    imageName: "step_shoulder_squeeze"
                )
            ]
        ),
        
        // KATEGORI B: Badan & Punggung
        ExercisePlan(
            title: "Torso & Back Mobility",
            description: "Mengatasi nyeri pinggang akibat duduk berjam-jam.",
            duration: "1 min",
            calories: 15,
            targetArea: "Lower Back",
            imageName: "cover_torso_back",
            steps: [
                ExerciseStep(
                    title: "Overhead Reach",
                    instruction: "Satukan jemari tangan, dorong ke atas setinggi mungkin sambil menarik napas dalam.",
                    function: "Dekompresi alami untuk ruang antar ruas tulang belakang.",
                    durationOrReps: "3-5 Repetisi",
                    imageName: "step_overhead_reach"
                ),
                ExerciseStep(
                    title: "Standing Side Reach",
                    instruction: "Berdiri, angkat satu tangan ke atas dan condongkan tubuh ke sisi berlawanan.",
                    function: "Meregangkan otot samping (obliques) yang tertekan saat duduk.",
                    durationOrReps: "10 detik per sisi",
                    imageName: "step_side_reach"
                ),
                ExerciseStep(
                    title: "Seated Cat-Cow",
                    instruction: "Tangan di lutut, busungkan dada ke depan (tarik napas), bungkukkan punggung ke belakang (buang napas).",
                    function: "Mengaktifkan setiap ruas tulang belakang agar tidak kaku.",
                    durationOrReps: "5 Repetisi",
                    imageName: "step_cat_cow"
                )
            ]
        ),
        
        // KATEGORI C: Kaki & Panggul
        ExercisePlan(
            title: "Lower Body & Circulation",
            description: "Mencegah kaki kesemutan dan memperbaiki sirkulasi.",
            duration: "1 min",
            calories: 20,
            targetArea: "Lower Body",
            imageName: "cover_lower_body",
            steps: [
                ExerciseStep(
                    title: "Ankle Pumps",
                    instruction: "Duduk, gerakkan telapak kaki naik-turun (jinjit-tumit) secara ritmis.",
                    function: "Memompa darah kembali dari kaki ke jantung.",
                    durationOrReps: "30 detik",
                    imageName: "step_ankle_pumps"
                ),
                ExerciseStep(
                    title: "Chair Squats",
                    instruction: "Berdiri dari kursi lalu duduk kembali tanpa menggunakan tangan.",
                    function: "Mengaktifkan otot terbesar di tubuh untuk membakar energi.",
                    durationOrReps: "5-10 Repetisi",
                    imageName: "step_chair_squats"
                ),
                ExerciseStep(
                    title: "Hip Flexor Lunge",
                    instruction: "Langkah satu kaki ke depan, tekan panggul sedikit ke depan hingga terasa ditarik.",
                    function: "Melawan efek duduk 90 derajat yang membuat panggul kaku.",
                    durationOrReps: "15 detik per sisi",
                    imageName: "step_hip_lunge"
                )
            ]
        )
    ]
}
