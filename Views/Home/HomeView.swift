//
//  ContentView.swift
//  DataWeave
//
//  Created by Meat on 2025/1/8.
//

import SwiftUI

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
                            // 顶部数据概览
                            DataOverviewSection()
                            
                            // 快捷操作区
                            QuickActionsSection()
                            
                            // 数据洞察
                            InsightsSection()
                            
                            // 最近的数据表
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

// 顶部数据概览部分
struct DataOverviewSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // 核心数据指标卡片组
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DataMetricCard(title: "活跃数据表", value: "12", trend: .up, trendValue: "+3")
                DataMetricCard(title: "本周新增记录", value: "156", trend: .up, trendValue: "+22%")
                DataMetricCard(title: "数据完整度", value: "94%", trend: .up, trendValue: "+5%")
                DataMetricCard(title: "自动化任务", value: "8", trend: .neutral, trendValue: "运行中")
            }
        }
        .padding(.top)
    }
}

// 快捷操作区
struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "快捷操作")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickActionButton(icon: "plus.circle.fill", title: "新建数据表", color: .purple)
                    QuickActionButton(icon: "square.and.arrow.up.fill", title: "导入数据", color: .blue)
                    QuickActionButton(icon: "wand.and.stars", title: "数据分析", color: .orange)
                    QuickActionButton(icon: "bolt.horizontal.fill", title: "自动化", color: .green)
                }
            }
        }
    }
}

// 数据洞察部分
struct InsightsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "数据洞察")
            
            InsightCard(
                title: "支出趋势分析",
                description: "本月餐饮支出较上月增长15%",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            
            InsightCard(
                title: "数据质量提醒",
                description: "发现3个可能的重复记录",
                icon: "exclamationmark.triangle",
                color: .red
            )
        }
    }
}

// 最近的数据表部分
struct RecentTablesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "最近的数据表")
            
            ForEach(0..<3) { index in
                DataTableCard(
                    title: ["电影记录", "记账本", "读书笔记"][index],
                    description: ["本周新增 3 条记录", "支出分析已生成", "完成度 85%"][index],
                    icon: ["film", "creditcard", "book"][index],
                    color: [.purple, .blue, .green][index]
                )
            }
        }
    }
}

// 辅助视图组件
struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(hex: "1A202C"))
    }
}

struct DataMetricCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let trendValue: String
    
    enum TrendDirection {
        case up, down, neutral
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            HStack {
                Image(systemName: trend == .up ? "arrow.up.right" : 
                                trend == .down ? "arrow.down.right" : "minus")
                Text(trendValue)
                    .font(.system(size: 12))
            }
            .foregroundColor(trend == .up ? .green : 
                           trend == .down ? .red : .gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

// 快捷操作按钮
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                )
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.primary)
        }
        .frame(width: 100)
    }
}

// 数据洞察卡片
struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

// 数据表格卡片
struct DataTableCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

// 占位视图
struct DataTablesView: View {
    var body: some View {
        Text("数据表视图")
    }
}

struct AutomationView: View {
    var body: some View {
        Text("自动化视图")
    }
}

struct InsightsView: View {
    var body: some View {
        Text("数据洞察视图")
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