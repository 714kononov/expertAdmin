import UIKit
import SQLite3

class ChangeOrderViewController: UIViewController {
    
    var db: OpaquePointer?
    
    // Элементы интерфейса для отображения данных
    var descriptionLabel: UILabel!
    var dateLabel: UILabel!
    var imageView1: UIImageView!
    var imageView2: UIImageView!
    var imageView3: UIImageView!
    var imageView4: UIImageView!
    var priceTextField: UITextField!
    
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
        // Создание контейнера для даты и описания
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Настройка лейбла даты
        dateLabel = UILabel()
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        // Настройка лейбла описания
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Настройка констрейнтов для контейнера
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Констрейнты для даты и описания внутри контейнера
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        // Настройка изображений
        imageView1 = createImageView()
        imageView2 = createImageView()
        imageView3 = createImageView()
        imageView4 = createImageView()
        
        let stackView = UIStackView(arrangedSubviews: [imageView1, imageView2, imageView3, imageView4])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Настройка кнопок
        let confirmButton = UIButton()
        confirmButton.setTitle("Подтвердить заказ", for: .normal)
        confirmButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        confirmButton.layer.cornerRadius = 10
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmOrder), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Отменить заказ", for: .normal)
        cancelButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        cancelButton.layer.cornerRadius = 10
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelOrder), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        let buttonStackView = UIStackView(arrangedSubviews: [confirmButton, cancelButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        // Поле для ввода цены
        priceTextField = UITextField()
        priceTextField.placeholder = "Введите цену"
        priceTextField.borderStyle = .roundedRect
        priceTextField.keyboardType = .numberPad
        priceTextField.textColor = .white       // Текст будет белым
        priceTextField.backgroundColor = .black // Фон текстового поля будет черным
        priceTextField.attributedPlaceholder = NSAttributedString(string: "Введите цену", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]) // Плейсхолдер светло-серый
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceTextField)
        
        //Кнопка назначить цену
        let assignButton = UIButton(type: .system)
        assignButton.setTitle("Назначить цену", for: .normal)
        assignButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        assignButton.setTitleColor(.white, for: .normal)
        assignButton.layer.cornerRadius = 10
        assignButton.translatesAutoresizingMaskIntoConstraints = false
        assignButton.addTarget(self, action: #selector(assignPrice), for: .touchUpInside)
        view.addSubview(assignButton)
        
        //Кнопка закрыть
        let closeWindowsButton = UIButton()
        closeWindowsButton.setTitle("Записать изменения", for: .normal)
        closeWindowsButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        closeWindowsButton.setTitleColor(.white, for: .normal)
        closeWindowsButton.layer.cornerRadius = 10
        closeWindowsButton.translatesAutoresizingMaskIntoConstraints = false
        closeWindowsButton.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        view.addSubview(closeWindowsButton)
        
        // Центрирование элементов и установка констрейнтов
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 170),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.widthAnchor.constraint(equalToConstant: 170),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            priceTextField.topAnchor.constraint(equalTo: cancelButton.bottomAnchor,constant: 30),
            priceTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceTextField.widthAnchor.constraint(equalToConstant: 200),
            priceTextField.heightAnchor.constraint(equalToConstant: 40),
            assignButton.topAnchor.constraint(equalTo: priceTextField.bottomAnchor,constant: 20),
            assignButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assignButton.widthAnchor.constraint(equalToConstant: 200),
            assignButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeWindowsButton.topAnchor.constraint(equalTo: assignButton.bottomAnchor,constant: 150),
            closeWindowsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeWindowsButton.widthAnchor.constraint(equalToConstant: 250),
            closeWindowsButton.heightAnchor.constraint(equalToConstant: 70)
            
            
        ])
    }

    
    // Метод для создания ImageView
    func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true // Включаем взаимодействие
        view.addSubview(imageView)
        
        // Добавляем жест для увеличения изображения при нажатии
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }
    
    // Обработчик нажатия на изображение
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView, let image = imageView.image {
            let imageVC = UIViewController()
            imageVC.view.backgroundColor = .black
            let enlargedImageView = UIImageView(image: image)
            enlargedImageView.contentMode = .scaleAspectFit
            enlargedImageView.frame = imageVC.view.frame
            imageVC.view.addSubview(enlargedImageView)
            
            let closeGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
            imageVC.view.addGestureRecognizer(closeGesture)
            
            self.present(imageVC, animated: true, completion: nil)
        }
    }
    
    @objc func dismissImage() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Загрузка данных о заказе
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
            let photo1 = sqlite3_column_text(statement, 2).map { String(cString: $0) }
            let photo2 = sqlite3_column_text(statement, 3).map { String(cString: $0) }
            let photo3 = sqlite3_column_text(statement, 4).map { String(cString: $0) }
            let photo4 = sqlite3_column_text(statement, 5).map { String(cString: $0) }
            
            dateLabel.text = "Дата: \(date)"
            descriptionLabel.text = description
            
            // Загрузка фотографий
            if let photo1 = photo1, !photo1.isEmpty {
                imageView1.isHidden = false
                loadImage(from: photo1, into: imageView1)
            }
            if let photo2 = photo2, !photo2.isEmpty {
                imageView2.isHidden = false
                loadImage(from: photo2, into: imageView2)
            }
            if let photo3 = photo3, !photo3.isEmpty {
                imageView3.isHidden = false
                loadImage(from: photo3, into: imageView3)
            }
            if let photo4 = photo4, !photo4.isEmpty {
                imageView4.isHidden = false
                loadImage(from: photo4, into: imageView4)
            }
        } else {
            print("Заказ не найден.")
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            imageView.image = UIImage(data: data)
        }
    }
    
    // Обработчик для кнопки "Подтвердить"
    @objc func confirmOrder() {
        guard let id = MoreActualDetailID.share.id else { return }
        let confirmMessage = "Здравствуйте! Мы сможем вам помочь вам необходимо оплатить экспертизу нажав по кнопке снизу, после оплаты мы сразу же перейдем созданию экспертизы"
        updateOrderAnswer(with: confirmMessage, for: id)
        updateOrderResult(with: 2, for: id) // Меняем result на 2
        let action = UIAlertController(title: "Подтверждение заказа", message: "Вы подтвердили заказ на экспертизу", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        action.addAction(OKAction)
        present(action,animated: true)
    }
    
    // Обработчик для кнопки "Отменить"
    @objc func cancelOrder() {
        guard let id = MoreActualDetailID.share.id else { return }
        let cancelMessage = "Здравствуйте! К сожалению мы не сможем вам помочь"
        updateOrderAnswer(with: cancelMessage, for: id)
        updateOrderResult(with: 3, for: id) // Меняем result на 3
        let action = UIAlertController(title: "Отмена заказа", message: "Вы отменили заказ на экспертизу", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        action.addAction(OKAction)
        present(action,animated: true)
    }
    
    // Метод для обновления поля answer в базе данных
    func updateOrderAnswer(with message: String, for orderId: Int) {
        let query = "UPDATE orders SET answerExpert = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(statement, 1, message, -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 2, Int32(orderId)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра: \(errmsg)")
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при выполнении SQL-запроса: \(errmsg)")
            return
        }
        
        print("Поле 'answerExpert' успешно обновлено")
        sqlite3_finalize(statement)
    }
    
    func updateOrderResult(with result: Int, for orderId: Int) {
        let query = "UPDATE orders SET result = ? WHERE id = ?"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }

        if sqlite3_bind_int(statement, 1, Int32(result)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра result: \(errmsg)")
            return
        }

        if sqlite3_bind_int(statement, 2, Int32(orderId)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке параметра id: \(errmsg)")
            return
        }

        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при выполнении SQL-запроса для изменения result: \(errmsg)")
            return
        }

        print("Поле 'result' успешно обновлено на \(result)")
        sqlite3_finalize(statement)
    }
    
    @objc func assignPrice() {
        guard let priceText = priceTextField.text, !priceText.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Поле не должно быть пустым! Введите цену за экспертизу", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            present(alert,animated: true)
            return
        }
        
        // Проверяем, что введены только цифры
        guard let price = Int(priceText) else {
            let alert = UIAlertController(title: "Ошибка", message: "Введите необходимую сумму для оплаты экспертизы", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            present(alert,animated: true)
            
            return
        }
        
        // Обновление значения в базе данных
        updatePayField(price: price)
    }
    
    func updatePayField(price: Int) {
        guard let id = MoreActualDetailID.share.id else {
            print("ID заказа не найден.")
            return
        }
        
        let query = "UPDATE orders SET pay = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при подготовке SQL-запроса: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 1, Int32(price)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке значения цены: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 2, Int32(id)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при привязке ID заказа: \(errmsg)")
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("Ошибка при обновлении поля pay: \(errmsg)")
            return
        }
        
        print("Поле 'pay' успешно обновлено на \(price).")
        sqlite3_finalize(statement)
    }
    @objc func closeWindow()
    {
        self.dismiss(animated: true)
    }
}
