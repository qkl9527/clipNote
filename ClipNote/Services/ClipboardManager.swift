import Foundation
import Combine
import KeyboardShortcuts

/// 剪贴板管理器 - 统一管理剪贴板监听和存储
class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var clips: [ClipItem] = []
    @Published var filteredClips: [ClipItem] = []
    @Published var selectedCategory: ClipCategory? = nil
    @Published var searchText: String = ""
    
    let clipboardMonitor: ClipboardMonitor
    let storageManager: StorageManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(storageManager: StorageManager = .shared) {
        self.storageManager = storageManager
        self.clipboardMonitor = ClipboardMonitor(storageManager: storageManager)
        
        setupBindings()
    }
    
    private func setupBindings() {
        // 监听剪贴板变化
        clipboardMonitor.$latestItem
            .compactMap { $0 }
            .sink { [weak self] item in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // 监听存储变化
        storageManager.$clips
            .receive(on: DispatchQueue.main)
            .sink { [weak self] clips in
                self?.clips = clips
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // 监听搜索和分类变化
        $searchText
            .combineLatest($selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    /// 应用筛选条件
    private func applyFilters() {
        var result = clips
        
        // 按分类筛选
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // 按搜索关键词筛选
        if !searchText.isEmpty {
            result = result.filter { item in
                item.content.localizedCaseInsensitiveContains(searchText) ||
                (item.sourceApp?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        filteredClips = result
    }
    
    /// 开始监听
    func startMonitoring() {
        clipboardMonitor.startMonitoring()
    }
    
    /// 停止监听
    func stopMonitoring() {
        clipboardMonitor.stopMonitoring()
    }
    
    /// 粘贴内容
    func paste(_ item: ClipItem) {
        PasteService.shared.pasteToActiveApp(item: item)
    }
    
    /// 切换分类
    func selectCategory(_ category: ClipCategory?) {
        selectedCategory = category
    }
    
    /// 清空搜索
    func clearSearch() {
        searchText = ""
    }
    
    /// 获取分类统计
    func categoryCounts() -> [ClipCategory: Int] {
        return storageManager.categoryCounts()
    }
}
