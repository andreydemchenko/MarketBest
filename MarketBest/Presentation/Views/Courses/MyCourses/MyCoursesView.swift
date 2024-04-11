//
//  MyCoursesView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI
import NavigationBackport

struct MyCoursesView: View {
    
    @EnvironmentObject var viewModel: MyCoursesViewModel
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                ForEach(viewModel.courses, id: \.self) { course in
                    MyCourseItemView(item: course, onEdit: {  }, onOpenDetails: { })
                }
            }
            Button {
                router.path.append(.addCourse)
            } label: {
                Text("Add course")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.primaryColor)
    }
}

#Preview {
    MyCoursesView()
}
