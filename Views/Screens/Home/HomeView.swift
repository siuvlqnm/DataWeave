//
//  ContentView.swift
//  DataWeave
//
//  Created by Meat on 2025/1/8.
//

import SwiftUI

// 如果这些视图在不同的模块中，可能需要导入相应的模块
// import DataTablesModule
// import AutomationModule
// import InsightsModule

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    // 动态颜色定义
    private let mainColor = Color(hex: "1A202C") // 深邃的午夜蓝
    private let accentColor = Color(hex: "A020F0") // 电光紫
    private let backgroundColor = Color(hex: "FAF0E6") // 米白色
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 主页面
            NavigationView {
                ZStack {
                    // 背景层
                    backgroundColor.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            DataOverviewSection()
                            QuickActionsSection()
                            InsightsSection()
                            RecentTablesSection()
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 12) {
                            Text("DataWeave")
                                .font(.system(size: 22, weight: .bold))
                            
                            Button(action: {}) {
                                Text("Track Data")
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(accentColor.opacity(0.1))
                                    .foregroundColor(accentColor)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "bell")
                                    .foregroundColor(mainColor)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "person.circle")
                                    .foregroundColor(mainColor)
                            }
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("概览")
            }
            .tag(0)
            
            // 其他标签页
            DataTablesView()
                .tabItem {
                    Image(systemName: "table")
                    Text("数据表")
                }
                .tag(1)
            
            AutomationView()
                .tabItem {
                    Image(systemName: "bolt.horizontal")
                    Text("自动化")
                }
                .tag(2)
            
            InsightsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("洞察")
                }
                .tag(3)
        }
        .accentColor(accentColor)
    }
}

// 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}