import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var authVM = AuthViewModel()

    // Warna custom sesuai desain
    let themeOrange = Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255)
        let lightOrange = Color(.sRGB, red: 255/255, green: 245/255, blue: 240/255)
    
    @State private var timeRemaining = 1800 // 30 menit dalam detik (30 * 60)
    @State private var isActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(lightOrange)
                        .frame(width: 45, height: 45)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(themeOrange)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("Good Morning,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Alex Rivera")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                Image(systemName: "bell")
                    .font(.title3)
                    .padding(10)
                    .background(Circle().fill(Color.white).shadow(radius: 1))
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // MARK: - Content Section
            VStack(spacing: 30) {
                HStack {
                    Text("Next Movement")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                // Timer Circle
                ZStack {
                    Circle()
                        .stroke(lightOrange, lineWidth: 15)
                        .frame(width: 250, height: 250)
                    
                    // Progress Indicator (Seperempat lingkaran di atas)
                    Circle()
                                            .trim(from: 0, to: CGFloat(timeRemaining) / 1800.0)
                                            .stroke(themeOrange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                            .frame(width: 260, height: 260)
                                            .rotationEffect(.degrees(-90))
                                            .animation(.easeInOut, value: timeRemaining)
                    
                    Text(timeString(from: timeRemaining))
                                            .font(.system(size: 70, weight: .bold, design: .rounded))
                                            .foregroundColor(themeOrange)
                }
                
                Text("Time to stand up and stretch those legs!")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
            }
            
            // MARK: - Streak Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(lightOrange)
                            .frame(width: 50, height: 50)
                        Image(systemName: "egg.fill") // Placeholder icon
                            .foregroundColor(themeOrange)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("CURRENT STREAK")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        // Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 8)
                                Capsule()
                                    .fill(themeOrange)
                                    .frame(width: geo.size.width * 0.8, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    VStack(alignment: .trailing) {
                        Text("12 Days")
                            .font(.title3)
                            .fontWeight(.black)
                    }
                }
                
                Text("Your pet is hatching! Keep moving.")
                    .font(.caption)
                    .foregroundColor(themeOrange)
                    .fontWeight(.medium)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 24)
            
            // MARK: - Start Button
            Button(action: {
                            if isActive {
                                
                                isActive = false
                                timeRemaining = 1800
                            } else {
                                
                                isActive = true
                            }
                        }) {
                            HStack {
                                Image(systemName: isActive ? "stop.fill" : "bolt.fill")
                                Text(isActive ? "Stop" : "Start Focus")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isActive ? themeOrange.opacity(0.75) : themeOrange)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 30)
            
        }
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.all))
        .onReceive(timer) { _ in
                    guard isActive else { return }
                    
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        isActive = false
                        // Tambahkan trigger feedback atau notifikasi di sini jika waktu habis
                    }
                }
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
