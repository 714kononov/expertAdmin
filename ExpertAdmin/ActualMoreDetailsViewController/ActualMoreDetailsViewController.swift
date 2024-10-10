import UIKit
import SQLite3
import UniformTypeIdentifiers

class ActualMoreDetailsViewController: UIViewController, UIDocumentPickerDelegate {
    
    var db: OpaquePointer?
    
    // Элементы интерфейса для отображения данных
    var descriptionLabel: UILabel!
    var dateLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Подключение к базе данных
        connectToDatabase()
        
        // Настройка интерфейса
        setupInterface()
        
        // Загрузка данных о заказе
        loadOrderDetails()
    }
    
    // Подключение к базе данных
    func connectToDatabase() {
        let fileManager = FileManager.default
        let dbPath = "/Users/admin/Desktop/expert.sqlite"
        
        if !fileManager.fileExists(atPath: dbPath) {
            print("База данных не найдена по пути: \(dbPath)")
            return
        }

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при открытии базы данных: \(errmsg)")
        } else {
            print("База данных успешно открыта.")
        }
    }
    
    // Настройка интерфейса
    func setupInterface() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        dateLabel = UILabel()
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        let addFileButton = UIButton(type: .system)
        addFileButton.setTitle("Добавить экспертизу", for: .normal)
        addFileButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        addFileButton.setTitleColor(.white, for: .normal)
        addFileButton.layer.cornerRadius = 10
        addFileButton.translatesAutoresizingMaskIntoConstraints = false
        addFileButton.addTarget(self, action: #selector(openFilePicker), for: .touchUpInside)
        view.addSubview(addFileButton)
        
        let changeOrder = UIButton()
        changeOrder.setTitle("Редактировать заказ", for: .normal)
        changeOrder.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        changeOrder.setTitleColor(.white, for: .normal)
        changeOrder.layer.cornerRadius = 10
        changeOrder.translatesAutoresizingMaskIntoConstraints = false
        changeOrder.addTarget(self, action: #selector(changeOrderTapped), for: .touchUpInside)
        view.addSubview(changeOrder)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            addFileButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 40),
            addFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addFileButton.widthAnchor.constraint(equalToConstant: 200),
            addFileButton.heightAnchor.constraint(equalToConstant: 50),
            
            changeOrder.topAnchor.constraint(equalTo: addFileButton.bottomAnchor, constant: 40),
            changeOrder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeOrder.widthAnchor.constraint(equalToConstant: 200),
            changeOrder.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func openFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.image, UTType.plainText], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let filePath = selectedFileURL.path
        
        guard let targetId = MoreActualDetailID.share.id else {
            print("ID заказа не найден.")
            return
        }
        
        saveFileToDatabase(forOrderId: targetId, filePath: filePath)
        print("Выбран файл: \(selectedFileURL)")
    }

    func saveFileToDatabase(forOrderId orderId: Int, filePath: String) {
        let updateStatementString = "UPDATE orders SET file = ? WHERE id = ?;"
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, filePath, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(orderId))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Путь файла успешно сохранен.")
            } else {
                print("Ошибка при обновлении записи.")
            }
        } else {
            print("Ошибка при подготовке запроса.")
        }
        
        sqlite3_finalize(updateStatement)
    }

    func loadOrderDetails() {
        guard let id = MoreActualDetailID.share.id else {
            print("ID заказа не найден.")
            return
        }
        let query = "SELECT date, UserText, photo1, photo2, photo3, photo4 FROM orders WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 1, Int32(id)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let date = String(cString: sqlite3_column_text(statement, 0))
            let description = String(cString: sqlite3_column_text(statement, 1))
            
            dateLabel.text = "Дата: \(date)"
            descriptionLabel.text = description
           
        } else {
            print("Заказ не найден.")
        }
        
        sqlite3_finalize(statement)
    }
    
    @objc func changeOrderTapped() {
        let storyboard = UIStoryboard(name: "ChangeOrderViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "ChangeOrderViewController") as! ChangeOrderViewController
        present(vsa, animated: true)
    }

    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
}
