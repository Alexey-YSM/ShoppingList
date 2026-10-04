import SwiftUI


enum Filter: String, CaseIterable {
    case all = "Все"
    case needToBuy = "Нужно купить"
    case purchased = "Куплено"
}


struct ContentView: View {
    @State private var items = ShoppingItem.samples
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var filter: Filter = .all

    private var visibleItems: [ShoppingItem] {
        var result = items

        //  Фильтр по статусу
        switch filter {
        case .all:
            break
        case .needToBuy:
            result = result.filter { !$0.isPurchased }
        case .purchased:
            result = result.filter { $0.isPurchased }
        }

        //  Фильтр по поиску
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Фильтр", selection: $filter) {
                        ForEach(Filter.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if visibleItems.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(visibleItems) { item in
                        NavigationLink(value: item.id) {
                            ShoppingItemRow(item: item) {
                                toggle(item)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Покупки")
            .searchable(text: $searchText, prompt: "Название или категория")
            .toolbar {
                Button("Добавить", systemImage: "plus") {
                    showingAddItem = true
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddShoppingItemView { newItem in
                    items.append(newItem)
                }
            }
            .navigationDestination(for: UUID.self) { id in
                if let index = items.firstIndex(where: { $0.id == id }) {
                    ShoppingItemDetailView(item: $items[index])
                }
            }
        }
    }

    private func toggle(_ item: ShoppingItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        items[index].isPurchased.toggle()
    }

    private func delete(at offsets: IndexSet) {
        let ids = offsets.map { visibleItems[$0].id }
        items.removeAll { ids.contains($0.id) }
    }
}



#Preview {
    ContentView()
}
