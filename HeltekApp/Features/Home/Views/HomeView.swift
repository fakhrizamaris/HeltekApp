import SwiftUI
import Combine

struct HomeView: View {
    // MARK: - ViewModels & AppStorage
    @StateObject private var authVM = AuthViewModel()
    @AppStorage("userName") private var userName = "User"
    
    // MARK: - UI Colors
    let themeOrange = Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255)
    let lightOrange = Color(.sRGB, red: 255/255, green: 245/255, blue: 240/255)
    
    // MARK: - Timer States
    @State private var timeRemaining = 1800 // Default 30 menit
    @State private var isActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Navigation & Sheet States
    @State private var showProfile = false
    @State private var showingBottomSheet = false
    @State private var selectedMinutes = 30
    @State private var navigateToSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header (Clickable → Profile)
                HStack {
                    Button {
                        showProfile = true
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(lightOrange)
                                .frame(width: 45, height: 45)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(themeOrange)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(greeting)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(userName.isEmpty ? "User" : userName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    .buttonStyle(.plain)
                    
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
                    
                    // Timer Circle Button
                    Button(action: {
                        showingBottomSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .stroke(lightOrange, lineWidth: 15)
                                .frame(width: 250, height: 250)
                            
                            // Progress Indicator
                            Circle()
                                .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(selectedMinutes > 0 ? selectedMinutes * 60 : 1800))
                                .stroke(themeOrange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 260, height: 260)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: timeRemaining)
                            
                            Text(timeString(from: timeRemaining))
                                .font(.system(size: 70, weight: .bold, design: .rounded))
                                .foregroundColor(themeOrange)
                        }
                    }.buttonStyle(PlainButtonStyle())
                    
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
                        timeRemaining = selectedMinutes * 60
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
            
            // MARK: - Modifiers & Destinations
            .sheet(isPresented: $showingBottomSheet) {
                ReminderSheetView(
                    isPresented: $showingBottomSheet,
                    selectedMinutes: $selectedMinutes,
                    timeRemaining: $timeRemaining
                )
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
            }
            .navigationDestination(isPresented: $navigateToSuccess) {
                ReminderView()
            }
            .onReceive(timer) { _ in
                guard isActive else { return }
                
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    isActive = false
                    timeRemaining = selectedMinutes * 60
                    navigateToSuccess = true // Otomatis pindah halaman kalau waktu abis
                }
            }
        } // NavigationStack
    }
    
    // MARK: - Helper Functions
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Selamat Pagi,"
        case 12..<15: return "Selamat Siang,"
        case 15..<18: return "Selamat Sore,"
        default:      return "Selamat Malam,"
        }
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Bottom Sheet View
struct ReminderSheetView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMinutes: Int
    @Binding var timeRemaining: Int
    
    let themeOrange = Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255)
    let lightOrange = Color(.sRGB, red: 255/255, green: 245/255, blue: 240/255)
    
    // Interval 5, 10, 15... sampai 120 menit
    let intervalOptions = Array(stride(from: 5, through: 120, by: 5))
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Reminder Interval")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Choose how often you want to be reminded\nto move")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Picker Roda
            Picker("Interval", selection: $selectedMinutes) {
                ForEach(intervalOptions, id: \.self) { minute in
                    Text("\(minute) min").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            
            // Tombol Set Time
            Button(action: {
                timeRemaining = selectedMinutes * 60
                isPresented = false
            }) {
                Text("Set Time")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeOrange)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 24)
            
            // Tombol Cancel
            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .fontWeight(.bold)
                    .foregroundColor(themeOrange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(lightOrange)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.bottom))
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
