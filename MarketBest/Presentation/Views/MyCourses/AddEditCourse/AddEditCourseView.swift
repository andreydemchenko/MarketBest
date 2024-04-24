//
//  AddEditCourseView.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import SwiftUI
import UniformTypeIdentifiers
import FancyScrollView

struct AddEditCourseView: View {
    
    @EnvironmentObject var viewModel: AddEditCourseViewModel
    @EnvironmentObject private var router: Router
    
    @State private var subcategorySearchText: String = ""
    @State private var isShowingImagePicker = false
    @State private var selectedImageData: Data?
    @FocusState private var nameFocused: Bool
    @FocusState private var videoUrlFocused: Bool
    @FocusState private var descriptionFocused: Bool
    @FocusState private var priceFocused: Bool
    @FocusState private var materialsUrlFocused: Bool
    @FocusState private var materialsDescFocused: Bool
    @FocusState private var categoryFocused: Bool
    
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var focusedField: Field? = nil

    enum Field: Hashable {
        case name, videoUrl, description, price, materials, url
    }

    
    var body: some View {
        
        ScrollViewReader { scrollViewProxy in
            FancyScrollView(
                title: viewModel.course == nil ? "Создать курс" : "Редактирование",
                titleColor: Color.primaryColor,
                headerHeight: 120,
                scrollUpHeaderBehavior: .sticky,
                scrollDownHeaderBehavior: .offset,
                header: {
                    Spacer()
                }
            ) {
                VStack {
                    let isVisibleSaving = (viewModel.course == nil || viewModel.course?.status == .uncompleted) && !viewModel.name.isEmpty && !viewModel.description.isEmpty && viewModel.selectedCategoryId != nil && !viewModel.price.isEmpty && !viewModel.materialsUrl.isEmpty
                    if isVisibleSaving {
                        HStack {
                            Spacer()
                            Button {
                                Task {
                                    await viewModel.saveToDrafts()
                                    router.path.pop()
                                }
                            } label: {
                                Text("Сохранить и выйти")
                                    .font(.mulishRegularFont(size: 16))
                                    .foregroundStyle(Color.primaryColor)
                            }
                        }
                        .padding()
                    }
                    VStack(alignment: .leading, spacing: 18) {
                        CustomTextField(
                            placeholder: "Название",
                            text: $viewModel.name,
                            returnKeyType: .next,
                            onReturn: {
                                DispatchQueue.main.async {
                                    nameFocused = false
                                }
                            }
                        )
                        .focused($nameFocused)
                        .id(Field.name)
                        
                        VStack(alignment: .leading) {
                            Text("Выбери категорию")
                                .font(.mulishBoldFont(size: 14))
                                .foregroundStyle(Color.backgroundColor)
                                .padding([.top, .leading], 8)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.categories, id: \.id) { category in
                                        CategoryButton(category: category.name, iconUrl: category.iconUrl, isSelected: viewModel.selectedCategoryId == category.id) {
                                            viewModel.selectCategory(category.id)
                                        }
                                    }
                                }
                            }
                            
                            if !viewModel.subcategories.isEmpty {
                                Text("Выбери направление")
                                    .font(.mulishBoldFont(size: 14))
                                    .foregroundStyle(Color.backgroundColor)
                                    .padding([.top, .leading], 8)
                                
                                TextField("Искать", text: $subcategorySearchText)
                                    .background(Color.primaryColor)
                                    .foregroundStyle(Color.backgroundColor)
                                    .font(.mulishRegularFont(size: 14))
                                    .padding(8)
                                //                                    .overlay(
                                //                                        RoundedRectangle(cornerRadius: 12)
                                //                                            .stroke(Color.backgroundColor, lineWidth: 1)
                                //                                    )
                                    .focused($categoryFocused)
                                
                                let filteredSubcategories = viewModel.subcategories.filter { subcategory in
                                    subcategorySearchText.isEmpty || subcategory.name.localizedCaseInsensitiveContains(subcategorySearchText)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(filteredSubcategories, id: \.id) { subcategory in
                                            CategoryButton(category: subcategory.name, iconUrl: subcategory.iconUrl, isSelected: viewModel.selectedSubcategoryId == subcategory.id) {
                                                viewModel.selectSubcategory(subcategory.id)
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        .padding(8)
                        .background(Color.primaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Фотографии и видео")
                                .font(.mulishLightFont(size: 14))
                                .foregroundStyle(Color.primaryColor)
                                .padding(.leading, 8)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(Array(viewModel.mediaItems.enumerated()), id: \.element.id) { index, item in
                                        mediaItemRow(for: item)
                                            .onDrag {
                                                viewModel.currentDragIndex = index
                                                return NSItemProvider(object: String(index) as NSString)
                                            }
                                            .onDrop(of: [.plainText], delegate: DropViewDelegate(index: index, viewModel: viewModel))
                                    }
                                    
                                    if viewModel.mediaItems.count < viewModel.maxMediaItemCount {
                                        Button {
                                            withAnimation {
                                                isShowingImagePicker = true
                                            }
                                        } label: {
                                            VStack {
                                                Image(systemName: "camera.fill")
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .frame(width: 36, height: 30)
                                                    .foregroundColor(Color.backgroundColor)
                                                    .padding()
                                                Text("Добавить фото")
                                                    .font(.mulishRegularFont(size: 16))
                                                    .foregroundStyle(Color.backgroundColor)
                                            }
                                            .frame(width: 160, height: 160)
                                            .background(Color.primaryColor)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                        }
                        
                        CustomTextField(
                            placeholder: "Ссылка на видео из YouTube",
                            text: $viewModel.videoURL,
                            returnKeyType: .next,
                            onReturn: {
                                DispatchQueue.main.async {
                                    videoUrlFocused = false
                                }
                            }
                        )
                        .focused($videoUrlFocused)
                        .id(Field.videoUrl)
                        .padding(.top, 12)
                        
                        if viewModel.isLoadingVideo {
                            ProgressView()
                        } else if !viewModel.isValidURL {
                            Text("Неизвестный видео-хостинг")
                                .frame(height: 130)
                                .frame(maxWidth: .infinity)
                                .font(.mulishMediumFont(size: 18))
                                .foregroundColor(Color.accentColor)
                                .background(Color.red.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .animation(.default, value: viewModel.isValidURL)
                        } else if let videoThumbnailURL = viewModel.videoThumbnailURL {
                            VideoPreview(videoTitle: viewModel.videoTitle, videoThumbnailURL: videoThumbnailURL)
                                .transition(.opacity.combined(with: .slide))
                        }
                        
                        CustomTextField(
                            placeholder: "Описание",
                            text: $viewModel.description,
                            isMultiline: true,
                            returnKeyType: .next,
                            onReturn: {
                                DispatchQueue.main.async {
                                    descriptionFocused = false
                                    priceFocused = true
                                }
                            }
                        )
                        .focused($descriptionFocused)
                        .id(Field.description)
                        
                        CustomTextField(
                            placeholder: "Цена",
                            text: $viewModel.price,
                            isNumber: true,
                            returnKeyType: .next,
                            onReturn: {
                                DispatchQueue.main.async {
                                    priceFocused = false
                                    materialsDescFocused = true
                                }
                            }
                        )
                        .focused($priceFocused)
                        .id(Field.price)
                        
                        CustomTextField(
                            placeholder: "Материалы",
                            text: $viewModel.materialsText,
                            returnKeyType: .next,
                            onReturn: {
                                DispatchQueue.main.async {
                                    materialsDescFocused = false
                                    materialsUrlFocused = true
                                }
                            }
                        )
                        .focused($materialsDescFocused)
                        .id(Field.materials)
                        
                        CustomTextField(
                            placeholder: "Ссылка",
                            text: $viewModel.materialsUrl,
                            returnKeyType: .next,
                            onReturn: {
                                DispatchQueue.main.async {
                                    materialsUrlFocused = false
                                }
                            }
                        )
                        .focused($materialsUrlFocused)
                        .id(Field.url)
                    }
                    .padding(.bottom)
                    Spacer()
                        .frame(height: 20)
                    Button {
                        Task {
                            if let model = viewModel.course {
                                await viewModel.editCourse(model: model)
                            } else {
                                await viewModel.createCourse()
                            }
                            router.path.pop()
                        }
                    } label: {
                        Text(viewModel.course == nil ? "Опубликовать" : "Изменить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondaryColor)
                            .foregroundStyle(.white)
                            .font(.headline)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    }
                    Spacer()
                        .frame(height: 80)
                }
                .padding()
                .background(Color.backgroundColor)
            }
            .padding(.bottom, keyboardManager.currentHeight - 30)
            .animation(.easeOut(duration: 0.16), value: keyboardManager.currentHeight)
            .onChange(of: focusedField) { field in
                scrollToField(field, with: scrollViewProxy)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            resignFocus()
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: uploadImage) {
            ImagePicker(selectedImageData: $selectedImageData)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .ignoresSafeArea()
    }
    
    private func scrollToField(_ field: Field?, with scrollViewProxy: ScrollViewProxy) {
        guard let field else { return }
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollViewProxy.scrollTo(field, anchor: .bottom)
            }
        }
    }
    
    private func uploadImage() {
        guard let imageData = selectedImageData else { return }
        Task {
            await viewModel.uploadMediaItem(imageData: imageData)
        }
    }
    
    private func resignFocus() {
        nameFocused = false
        videoUrlFocused = false
        descriptionFocused = false
        priceFocused = false
        materialsUrlFocused = false
        materialsUrlFocused = false
        categoryFocused = false
    }
    
    @ViewBuilder
    private func mediaItemRow(for item: CourseMediaItem) -> some View {
        ZStack(alignment: .topTrailing) {
            if viewModel.uploadingItems.contains(item.id) {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.primaryColor, lineWidth: 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(Color.primaryColor)
            } else {
                GeometryReader { geo in
                    ZStack {
                        // Blurred image fills the entire space
                        AsyncImage(url: URL(string: item.url)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .blur(radius: 10)
                                .clipped()
                        } placeholder: {
                            Image("image_placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .blur(radius: 10)
                        }
                        
                        AsyncImage(url: URL(string: item.url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width, height: geo.size.height)
                        } placeholder: {
                            Image("image_placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                }
            }
            
            if item.order == 0 {
                HStack {
                    Text("Главная")
                        .font(.mulishLightFont(size: 12))
                        .foregroundStyle(Color.backgroundColor)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(Color.primaryColor.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Spacer()
                }
                .padding(8)
            }
            
            Button(action: {
                if let index = viewModel.mediaItems.firstIndex(where: { $0.id == item.id }) {
                    viewModel.removeMediaItem(at: IndexSet(integer: index))
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.trailing)
    }
}

struct CategoryButton: View {
    var category: String
    var iconUrl: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let iconUrl = iconUrl, let url = URL(string: iconUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .renderingMode(.template)
                            .foregroundStyle(isSelected ? Color.backgroundColor : Color.primaryColor)
                    } placeholder: {
                        Spacer()
                    }
                    .frame(width: 20, height: 20)
                }
                Text(category)
                    .font(.mulishLightFont(size: 14))
                    .foregroundStyle(isSelected ? Color.backgroundColor : Color.primaryColor)
            }
            .padding(8)
            .background(isSelected ? Color.accentColor : Color.backgroundColor)
            .cornerRadius(20)
            .padding(2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.backgroundColor : Color.clear, lineWidth: 2)
            )
        }
        .animation(.easeInOut, value: isSelected)
        .padding(2)
    }
}

class DropViewDelegate: DropDelegate {
    var index: Int
    var viewModel: AddEditCourseViewModel

    init(index: Int, viewModel: AddEditCourseViewModel) {
        self.index = index
        self.viewModel = viewModel
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let provider = info.itemProviders(for: [.plainText]).first else {
            return false
        }
        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
            DispatchQueue.main.async {
                guard let fromIndex = self.viewModel.currentDragIndex, fromIndex != self.index else { return }
                
                // Adjusting indices based on drag direction
                let toIndex = self.index > fromIndex ? self.index - 1 : self.index
                if fromIndex != toIndex {
                    self.viewModel.mediaItems.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
                    self.viewModel.reorderMediaItems()
                }
            }
        }
        return true
    }
}

struct VideoPreview: View {
    var videoTitle: String
    var videoThumbnailURL: URL

    var body: some View {
         GeometryReader { geometry in
             HStack(spacing: 10) {
                 AsyncImage(url: videoThumbnailURL) { image in
                     image.resizable()
                         .aspectRatio(contentMode: .fit)
                 } placeholder: {
                     Color.gray
                 }
                 .frame(width: geometry.size.width / 2 - 10)
                 .clipShape(RoundedRectangle(cornerRadius: 12))
                 
                 Text(videoTitle)
                     .font(.mulishBoldFont(size: 14))
                    .foregroundStyle(Color.backgroundColor)
             }
             .padding()
             .frame(maxWidth: .infinity, maxHeight: 130, alignment: .leading)
             .background(Color.primaryColor)
             .clipShape(RoundedRectangle(cornerRadius: 12))
         }
         .frame(height: 130)
     }
}


#Preview(body: {
    VideoPreview(videoTitle: "title", videoThumbnailURL: URL(string: "https://avatars.mds.yandex.net/i?id=754ade5b37821430c71c4e8a4e37d4f4c63651d4-4824750-images-thumbs&n=13")!)
})

//#Preview {
//    AddEditCourseView()
//        .environmentObject(AddEditCourseViewModel(createCourseUseCase: DependencyContainer().createCourseUseCase, editCourseUseCase: DependencyContainer().editCourseUseCase, fetchCategoriesUseCase: DependencyContainer().fetchCategoriesUseCase, courseMediaUseCases: DependencyContainer().courseMediaUseCases, fetchVideoDetailsUseCase: DependencyContainer().fetchVideoDetailsUseCase, authStateManager: DependencyContainer().authStateManager))
//}
