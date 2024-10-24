import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct Order: Identifiable {
    var id: String = UUID().uuidString
    var userName: String?
    var date: String?
    var userText: String?
    var typeExpertiza: Int?
    var price: Int?
    var pay: Int?
    var expertID: String?
    var result: Int?
    var userID: String?
    var expertAnswer: String?
}

class TypeViewController: UIViewController {
    
    var types: [String] = ["ДТП", "Окон", "Заливов", "Обуви", "Одежды", "Строительная", "Бытовая техника", "Шуб", "Телефонов", "Мебель"]
    var selectedType: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        let H1 = UITextView()
        let fullText = "Шаг третий"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let orangeColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        let rangeForOrangeText = (fullText as NSString).range(of: "Шаг")
        attributedString.addAttribute(.foregroundColor, value: orangeColor, range: rangeForOrangeText)
        
        let rangeForWhiteText = (fullText as NSString).range(of: "третий")
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: rangeForWhiteText)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSMakeRange(0, attributedString.length))
        
        H1.attributedText = attributedString
        H1.backgroundColor = .clear
        H1.isScrollEnabled = false
        H1.isEditable = false
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        let text1 = UITextView()
        text1.text = "Укажите вид желаемой экспертизы"
        text1.font = UIFont.systemFont(ofSize: 20)
        text1.textColor = .white
        text1.backgroundColor = .clear
        text1.isScrollEnabled = false
        text1.isEditable = false
        text1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text1)
        
        NSLayoutConstraint.activate([
            H1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text1.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 20),
            text1.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        var previousLeftButton: UIButton? = nil
        var previousRightButton: UIButton? = nil
        
        let buttonSpacing: CGFloat = 20.0
        
        for (index, type) in types.enumerated() {
            let button = createButton(title: type)
            button.tag = index + 1
            button.addTarget(self, action: #selector(typeExpertiza(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            if index % 2 == 0 {
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
                if let previous = previousLeftButton {
                    button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: buttonSpacing).isActive = true
                } else {
                    button.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 40).isActive = true
                }
                previousLeftButton = button
            } else {
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
                if let previous = previousRightButton {
                    button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: buttonSpacing).isActive = true
                } else {
                    button.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 40).isActive = true
                }
                previousRightButton = button
            }
        }
        
        let prevButton = createButton(title: "Назад")
        prevButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(prevButton)
        
        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prevButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            prevButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            prevButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func typeExpertiza(_ sender: UIButton) {
        selectedType = sender.tag
        UserOrder.shared.userType = selectedType

        // Получаем изображения
        let imagesToUpload: [UIImage] = [
                UserOrder.shared.userPhoto1.flatMap { UIImage(data: $0) },
                UserOrder.shared.userPhoto2.flatMap { UIImage(data: $0) },
                UserOrder.shared.userPhoto3.flatMap { UIImage(data: $0) },
                UserOrder.shared.userPhoto4.flatMap { UIImage(data: $0) }
            ].compactMap { $0 }

        uploadImagesToStorage(images: imagesToUpload) { [weak self] imageUrls in
            guard let self = self else { return }
            if let imageUrls = imageUrls {
                self.saveOrder(imageUrls: imageUrls)
            } else {
                print("Не удалось загрузить изображения.")
            }
        }
    }
    
    func uploadImagesToStorage(images: [UIImage], completion: @escaping ([String]?) -> Void) {
        var imageUrls = [String]()
        let dispatchGroup = DispatchGroup()

        for image in images {
            dispatchGroup.enter()

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                dispatchGroup.leave()
                continue
            }

            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")

            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Ошибка при загрузке изображения: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Ошибка при получении ссылки: \(error.localizedDescription)")
                    } else if let imageUrl = url?.absoluteString {
                        imageUrls.append(imageUrl)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(imageUrls.isEmpty ? nil : imageUrls)
        }
    }

    func saveOrder(imageUrls: [String]) {
        let db = Firestore.firestore()
        
        guard let name = UserOrder.shared.userName,
              let text = UserOrder.shared.userText,
              let type = UserOrder.shared.userType,
              let uid = Auth.auth().currentUser?.uid else {
            print("Ошибка: отсутствуют обязательные данные для сохранения заказа.")
            return
        }

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)

        let order = Order(
            id: UUID().uuidString,
            userName: name,
            date: formattedDate,
            userText: text,
            typeExpertiza: type,
            price: 0,
            pay: 0,
            expertID: "",
            result: 0,
            userID: uid,
            expertAnswer: ""
        )
        
        let orderData: [String: Any] = [
            "id": order.id,
            "userName": order.userName ?? "",
            "date": order.date ?? "",
            "userText": order.userText ?? "",
            "typeExpertiza": order.typeExpertiza ?? 0,
            "price": order.price ?? 0,
            "pay": order.pay ?? 0,
            "expertID": order.expertID ?? "None",
            "result": order.result ?? 0,
            "imageUrls": imageUrls, // Сохраняем массив ссылок на изображения
            "userID": uid,
            "expertAnswer": ""
        ]

        db.collection("users")
            .document(uid)
            .collection("orders")
            .document(order.id)
            .setData(orderData) { error in
                if let error = error {
                    print("Ошибка при сохранении заказа: \(error.localizedDescription)")
                } else {
                    print("Заказ успешно сохранен!")
                    let alertController = UIAlertController(title: "Заказ сохранен", message: "Ваш заказ был успешно сохранен.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        var presentingVC = self.presentingViewController
                        var count = 0
                        while presentingVC?.presentingViewController != nil && count < 2 {
                            presentingVC = presentingVC?.presentingViewController
                            count += 1
                        }
                        presentingVC?.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
    }

    @objc func backTapped() {
        self.dismiss(animated: true)
    }
}
