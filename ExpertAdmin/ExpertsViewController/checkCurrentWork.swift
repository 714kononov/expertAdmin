import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAppCheck

class checkCurrentWork: UIViewController {
    
    var orders: [(id: String, userName: String,expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photo1: String?, photo2: String?, photo3: String?, photo4: String?)] = []

    var types: [String] = ["ДТП", "Окон", "Заливов", "Обуви", "Одежды", "Строительная", "Бытовая техника", "Шуб", "Телефонов", "Мебель"]
    var selectedStatus: Int = 0 // По умолчанию статус "На рассмотрении"
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтр", for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let ordersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        setupUI()
        fetchOrders(with: selectedStatus)
    }
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(filterButton)
        contentView.addSubview(ordersStackView)
        
        // Настройка кнопки фильтра
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        
        // Устанавливаем Constraints для scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            filterButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            filterButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            filterButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            
            ordersStackView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
            ordersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ordersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ordersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func filterTapped() {
        let alert = UIAlertController(title: "Выберите статус", message: nil, preferredStyle: .actionSheet)
        
        let statuses = ["На рассмотрении", "В разработке", "Готов", "Отменен"]
        for (index, status) in statuses.enumerated() {
            alert.addAction(UIAlertAction(title: status, style: .default, handler: { _ in
                self.selectedStatus = index
                self.fetchOrders(with: self.selectedStatus)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    func fetchOrders(with status: Int) {
        let db = Firestore.firestore()
        
        // Очищаем стек представлений заказов
        self.ordersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Получаем все user IDs
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Ошибка при получении пользователей: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("Нет доступных пользователей")
                return
            }
            
            for document in documents {
                let userId = document.documentID
                
                // Получаем все заказы для данного пользователя
                db.collection("users").document(userId).collection("orders")
                    .whereField("status", isEqualTo: status)
                    .whereField("expertID", isEqualTo: MoreDetailID.share.id)
                    .getDocuments { (orderSnapshot, orderError) in
                        if let orderError = orderError {
                            print("Ошибка при получении заказов: \(orderError)")
                            return
                        }
                        
                        guard let orderSnapshot = orderSnapshot else { return }
                        
                        for orderDocument in orderSnapshot.documents {
                            // Извлечение данных из документа
                            guard let data = orderDocument.data() as? [String: Any] else {
                                print("Ошибка при извлечении данных из документа")
                                continue
                            }

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
                            let order = (id: orderDocument.documentID,
                                          userName: userName,
                                         expertName: expertName,
                                          date: date,
                                          typeExpertiz: typeExpertiz,
                                          pay: pay,
                                          status: status,
                                          userText: userText,
                                          price: price,
                                          photo1: photo1,
                                          photo2: photo2,
                                          photo3: photo3,
                                          photo4: photo4)

                            MoreDetailID.share.userID = userID
                            self.orders.append(order) // Добавление заказа в массив

                            // Создание визуального представления заказа
                            self.createOrderBox(with: order)
                        }
                    }
            }
        }
    }
    
    func createOrderBox(with order: (id: String, userName: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photo1: String?, photo2: String?, photo3: String?, photo4: String?)) {
        let orderView = UIView()
        orderView.backgroundColor = UIColor.black
        orderView.layer.cornerRadius = 10
        
        let orderLabel = UILabel()
        orderLabel.text = "Имя: \(order.userName)\nТип: \(order.typeExpertiz)\nДата заказа: \(order.date)"
        orderLabel.numberOfLines = 0
        orderLabel.textColor = .white
        
        let detailsButton = UIButton()
        detailsButton.setTitle("Подробнее", for: .normal)
        detailsButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        detailsButton.layer.cornerRadius = 5
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
        detailsButton.accessibilityIdentifier = order.id
        
        orderView.addSubview(orderLabel)
        orderView.addSubview(detailsButton)
        
        orderLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            orderLabel.topAnchor.constraint(equalTo: orderView.topAnchor, constant: 10),
            orderLabel.leadingAnchor.constraint(equalTo: orderView.leadingAnchor, constant: 10),
            orderLabel.trailingAnchor.constraint(equalTo: orderView.trailingAnchor, constant: -10),
            
            detailsButton.topAnchor.constraint(equalTo: orderLabel.bottomAnchor, constant: 10),
            detailsButton.leadingAnchor.constraint(equalTo: orderView.leadingAnchor, constant: 10),
            detailsButton.trailingAnchor.constraint(equalTo: orderView.trailingAnchor, constant: -10),
            detailsButton.bottomAnchor.constraint(equalTo: orderView.bottomAnchor, constant: -10),
            detailsButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        ordersStackView.addArrangedSubview(orderView)
    }
    
    @objc func detailsTapped(sender: UIButton) {
        if let orderId = sender.accessibilityIdentifier {
            MoreDetailID.share.id = orderId
            print("ID заказа: \(orderId)")
            
            // Переход на экран с детальной информацией
            let storyboard = UIStoryboard(name: "DetailsOrderViewController", bundle: nil) // Замените на ваш основной storyboard
            let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsOrderViewController") as! DetailsOrderViewController
            
            // Передача массива заказов
            detailsVC.orders = self.orders.filter { $0.id == orderId } // Передаем только выбранный заказ
            
            present(detailsVC, animated: true)
        } else {
            print("ID заказа не найден")
        }
    }
}
