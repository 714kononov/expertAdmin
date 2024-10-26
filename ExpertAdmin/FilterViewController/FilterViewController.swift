import UIKit
import FirebaseFirestore

class FilterViewController: UIViewController {
    var db: Firestore!
    var filteredOrders: [(id: String, userName: String, userID: String, date: String, typeExpertiz: Int, userText: String)] = []
    var orders: [(id: String, userName: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photo1: String?, photo2: String?, photo3: String?, photo4: String?)] = []
    
    let statusPicker = UISegmentedControl(items: ["На рассмотрении","В разработке", "Готовые", "Отмененные"])
    let datePicker = UIDatePicker()
    let filterButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        
        // Инициализация Firestore
        db = Firestore.firestore()
        
        setupInterface()
    }
    
    func setupInterface() {
        // Настройка статусного селектора
        statusPicker.selectedSegmentIndex = 0
        statusPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusPicker)
        
        // Настройка выборщика даты
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        // Настройка кнопки фильтра
        filterButton.setTitle("Показать", for: .normal)
        filterButton.backgroundColor = .black
        filterButton.layer.cornerRadius = 10
        filterButton.addTarget(self, action: #selector(filterOrders), for: .touchUpInside)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        // Настройка автолейаута
        NSLayoutConstraint.activate([
            statusPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            datePicker.topAnchor.constraint(equalTo: statusPicker.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            filterButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 200),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func filterOrders() {
        print("Нажата кнопка фильтра")
        // Получение выбранного статуса и даты
        let selectedStatus = statusPicker.selectedSegmentIndex
        let selectedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        // Получение всех пользователей
        db.collection("users").getDocuments { (userSnapshot, error) in
            if let error = error {
                print("Ошибка получения пользователей: \(error)")
                return
            }
            
            guard let userDocuments = userSnapshot?.documents else { return }
            let userIDs = userDocuments.map { $0.documentID }
            
            self.filteredOrders.removeAll()
            // Получаем заказы для каждого пользователя
            self.getOrders(for: userIDs, status: selectedStatus, date: dateString)
        }
    }
    
    func getOrders(for userIDs: [String], status: Int, date: String) {
        let dispatchGroup = DispatchGroup()
        
        for userID in userIDs {
            dispatchGroup.enter()
            db.collection("users").document(userID).collection("orders")
                .whereField("status", isEqualTo: status)
                .whereField("date", isEqualTo: date)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Ошибка получения заказов для пользователя \(userID): \(error)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    for document in querySnapshot!.documents {
                        let id = document.documentID
                        let data = document.data()
                        
                        // Извлечение обязательных полей
                        guard let userName = data["userName"] as? String,
                              let date = data["date"] as? String,
                              let typeExpertiz = data["typeExpertiza"] as? Int,
                              let pay = data["pay"] as? Int,
                              let status = data["status"] as? Int,
                              let price = data["price"] as? Int,
                              let userID = data["userID"] as? String,
                              let expertName = data["expertName"] as? String,
                              let imageUrls = data["imageUrls"] as? [String] else {
                            print("Ошибка при извлечении обязательных полей")
                            continue
                        }
                        
                        // Дополнительное поле, если оно присутствует
                        let userText = data["userText"] as? String
                        
                        // Извлечение URL изображений
                        let photo1 = imageUrls.indices.contains(0) ? imageUrls[0] : nil
                        let photo2 = imageUrls.indices.contains(1) ? imageUrls[1] : nil
                        let photo3 = imageUrls.indices.contains(2) ? imageUrls[2] : nil
                        let photo4 = imageUrls.indices.contains(3) ? imageUrls[3] : nil
                        
                        // Создание объекта заказа
                        let order = (id: id,
                                     userName: userName,
                                     date: date,
                                     expertName: expertName,
                                     typeExpertiz: typeExpertiz,
                                     pay: pay,
                                     status: status,
                                     userText: userText,
                                     price: price,
                                     photo1: photo1,
                                     photo2: photo2,
                                     photo3: photo3,
                                     photo4: photo4)
                        //Очистска массивов
                        self.orders.removeAll()
                        self.filteredOrders.removeAll()
                        
                        // Добавление заказа в массив
                        self.orders.append(order)
                    
                        print("ID заказа: \(id)")
                        // Сохраняем id клиента и id заказа
                        self.filteredOrders.append((id: id, userName: userName, userID: userID, date: date, typeExpertiz: typeExpertiz, userText: userText ?? ""))
                        
                        self.setupOrderViews()
                        
                    }
                    
                    dispatchGroup.leave()
                }
        }
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupOrderViews() {
        // Удаляем старые представления заказов
        for subview in view.subviews where subview.tag == 100 {
            subview.removeFromSuperview()
        }
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .fill
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.tag = 100 // Тег для идентификации
        
        view.addSubview(mainStackView)
        
        for order in filteredOrders {
            let orderView = createOrderView(id: order.id, userID: order.userID, userName:order.userName,date: order.date, typeExpertiz: order.typeExpertiz, userText: order.userText)
            mainStackView.addArrangedSubview(orderView)
        }
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func createOrderView(id: String, userID: String, userName: String,date: String, typeExpertiz: Int, userText: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = "Экспертиза от \(date)"
        dateLabel.textColor = .white
        dateLabel.font = UIFont.boldSystemFont(ofSize: 18)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = "Тип экспертизы: \(typeExpertiz)"
        typeLabel.textColor = .lightGray
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = "Имя заказчика: \(userName)"
        nameLabel.textColor = .lightGray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let moreButton = UIButton()
        moreButton.setTitle("Подробнее", for: .normal)
        moreButton.backgroundColor = .darkGray
        moreButton.layer.cornerRadius = 5
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Передаем идентификатор как свойство кнопки
        moreButton.accessibilityIdentifier = "\(id),\(userID)" // Используем accessibilityIdentifier для хранения id
        
        // Добавляем действие на кнопку
        moreButton.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        
        containerView.addSubview(dateLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            typeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            moreButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            moreButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            moreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        return containerView
    }
    
    //Обработчик нажатия на кнопку
    @objc func moreButtonTapped(_ sender: UIButton) {
        if let identifier = sender.accessibilityIdentifier {
            let identifiers = identifier.split(separator: ",").map { String($0) }
            if identifiers.count == 2 {
                let orderID = identifiers[0] // ID заказа
                let userID = identifiers[1]   // ID пользователя
                print("Нажата кнопка для заказа с ID: \(orderID), ID пользователя: \(userID)")
                MoreDetailID.share.userID = userID
                MoreDetailID.share.id = orderID
                
                let storyboard = UIStoryboard(name: "DetailsOrderViewController", bundle: nil) // Замените на ваш основной storyboard, если необходимо
                let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsOrderViewController") as! DetailsOrderViewController
                
                // Передача массива заказов
                detailsVC.orders = orders
                
                present(detailsVC, animated: true)
                // Здесь можно добавить переход к подробной информации о заказе
            }
        }
        
    }
}
    
//    @objc func filterOrders() {
//        // Получение выбранного статуса и даты
//        let selectedStatus = statusPicker.selectedSegmentIndex + 1
//        let selectedDate = datePicker.date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let dateString = dateFormatter.string(from: selectedDate)
//
//        // Получение всех пользователей
//        db.collection("users").getDocuments { (userSnapshot, error) in
//            if let error = error {
//                print("Ошибка получения пользователей: \(error)")
//                return
//            }
//
//            guard let userDocuments = userSnapshot?.documents else { return }
//            let userIDs = userDocuments.map { $0.documentID }
//
//            self.filteredOrders.removeAll()
//            // Получаем заказы для каждого пользователя
//            self.getOrders(for: userIDs, status: selectedStatus, date: dateString)
//        }
//    }
//
//    func getOrders(for userIDs: [String], status: Int, date: String) {
//        let dispatchGroup = DispatchGroup()
//
//        for userID in userIDs {
//            dispatchGroup.enter()
//            db.collection("users").document(userID).collection("orders")
//                .whereField("status", isEqualTo: status)
//                .whereField("date", isEqualTo: date)
//                .getDocuments { (querySnapshot, error) in
//                    if let error = error {
//                        print("Ошибка получения заказов для пользователя \(userID): \(error)")
//                        dispatchGroup.leave()
//                        return
//                    }
//
//                    for document in querySnapshot!.documents {
//                        let id = document.documentID
//                        let data = document.data()
//
//                        // Извлечение обязательных полей
//                        guard let userName = data["userName"] as? String,
//                              let date = data["date"] as? String,
//                              let typeExpertiz = data["typeExpertiza"] as? Int,
//                              let pay = data["pay"] as? Int,
//                              let status = data["status"] as? Int,
//                              let price = data["price"] as? Int,
//                              let userID = data["userID"] as? String,
//                              let imageUrls = data["imageUrls"] as? [String] else {
//                            print("Ошибка при извлечении обязательных полей")
//                            continue
//                        }
//
//                        // Дополнительное поле, если оно присутствует
//                        let userText = data["userText"] as? String
//
//                        // Извлечение URL изображений
//                        let photo1 = imageUrls.indices.contains(0) ? imageUrls[0] : nil
//                        let photo2 = imageUrls.indices.contains(1) ? imageUrls[1] : nil
//                        let photo3 = imageUrls.indices.contains(2) ? imageUrls[2] : nil
//                        let photo4 = imageUrls.indices.contains(3) ? imageUrls[3] : nil
//
//                        // Создание объекта заказа
//                        let order = (id: id,
//                                     userName: userName,
//                                     date: date,
//                                     typeExpertiz: typeExpertiz,
//                                     pay: pay,
//                                     status: status,
//                                     userText: userText,
//                                     price: price,
//                                     photo1: photo1,
//                                     photo2: photo2,
//                                     photo3: photo3,
//                                     photo4: photo4)
//
//                        // Добавление заказа в массив
//                        self.orders.append(order)
//
//                        print("Тип экспертизы: \(typeExpertiz)")
//
//                        // Сохраняем id клиента и id заказа
//                        self.filteredOrders.append((id: id, userName: userName, userID: userID, date: date, typeExpertiz: typeExpertiz, userText: userText ?? ""))
//
//                        self.setupOrderViews()
//
//                    }
//
//                    dispatchGroup.leave()
//                }
//        }
//    }
    

