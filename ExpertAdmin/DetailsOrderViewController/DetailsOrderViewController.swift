import UIKit
import UniformTypeIdentifiers
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation
import MobileCoreServices

class MoreDetailID {
    static let share = MoreDetailID()
    var id: String?
    var userID: String?
    var currentStatusID: Int?
}

class changeOrder {
    static let shared = changeOrder()
    var orderID: String?
    var changeStatusId: Int?
    var price: Int?
    var experdID: String?
    var comment: String?
    var fileURL: String?
    var expertName: String?
}

class DetailsOrderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIDocumentPickerDelegate {

    var orders: [(id: String, userName: String, expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photo1: String?, photo2: String?, photo3: String?, photo4: String?)] = []
    var experts: [(id: String, expertName: String)] = []
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var collectionView: UICollectionView!
    private var photos: [String] = []

    private var typeLabel: UILabel!
    private var dateLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var priceLabel: UILabel!
    private var statusLabel: UILabel!
    private var userName: UILabel!
    private var comment: UITextField!
    private var accessbtn: UIButton!
    private var cancelbtn: UIButton!
    private var commentbtn: UIButton!
    private var price: UITextField!
    private var savebtn: UIButton!
    private var chooseExpert: UIButton!
    private var expertName: UILabel!
    private var pay:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        setupScrollView()
        setupUI()

        // Проверяем, что массив не пустой, и передаем первый элемент
        if let firstOrder = orders.first {
            displayOrderDetails(order: firstOrder)
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Это важно для вертикального скролла
        ])
    }

    func setupUI() {
        let textContainerView = UIView()
        textContainerView.backgroundColor = .black
        textContainerView.layer.cornerRadius = 10
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textContainerView)

        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 18)
        typeLabel.textColor = .white
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(typeLabel)

        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.textColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(dateLabel)

        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(descriptionLabel)

        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 18)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(priceLabel)

        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 18)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(statusLabel)

        userName = UILabel()
        userName.font = UIFont.systemFont(ofSize: 18)
        userName.textColor = .white
        userName.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(userName)
        
        expertName = UILabel()
        expertName.font = UIFont.systemFont(ofSize: 18)
        expertName.textColor = .white
        expertName.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(expertName)
        
        pay = UILabel()
        pay.font = UIFont.systemFont(ofSize: 18)
        pay.textColor = .white
        pay.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(pay)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 150)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)

        accessbtn = UIButton()
        accessbtn.setTitle("Подтвердить", for: .normal)
        accessbtn.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        accessbtn.setTitleColor(.white, for: .normal)
        accessbtn.layer.cornerRadius = 10
        accessbtn.translatesAutoresizingMaskIntoConstraints = false
        accessbtn.addTarget(self, action: #selector(accessbtnTapped), for: .touchUpInside)
        contentView.addSubview(accessbtn)

        cancelbtn = UIButton()
        cancelbtn.setTitle("Отменить", for: .normal)
        cancelbtn.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        cancelbtn.setTitleColor(.white, for: .normal)
        cancelbtn.layer.cornerRadius = 10
        cancelbtn.translatesAutoresizingMaskIntoConstraints = false
        cancelbtn.addTarget(self, action: #selector(cancelbtnTapped), for: .touchUpInside)
        contentView.addSubview(cancelbtn)

        commentbtn = UIButton()
        commentbtn.setTitle("Комментарий", for: .normal)
        commentbtn.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        commentbtn.setTitleColor(.white, for: .normal)
        commentbtn.layer.cornerRadius = 10
        commentbtn.translatesAutoresizingMaskIntoConstraints = false
        commentbtn.addTarget(self, action: #selector(commentbtnTapped), for: .touchUpInside)
        contentView.addSubview(commentbtn)

        savebtn = UIButton()
        savebtn.setTitle("Сохранить", for: .normal)
        savebtn.backgroundColor = .red
        savebtn.setTitleColor(.white, for: .normal)
        savebtn.layer.cornerRadius = 10
        savebtn.translatesAutoresizingMaskIntoConstraints = false
        savebtn.addTarget(self, action: #selector(savebtnTapped), for: .touchUpInside)
        contentView.addSubview(savebtn)

        chooseExpert = UIButton()
        chooseExpert.setTitle("Назнач Эксперта", for: .normal)
        chooseExpert.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        chooseExpert.setTitleColor(.white, for: .normal)
        chooseExpert.layer.cornerRadius = 10
        chooseExpert.translatesAutoresizingMaskIntoConstraints = false
        chooseExpert.addTarget(self, action: #selector(chooseExpertTapped), for: .touchUpInside)
        contentView.addSubview(chooseExpert)

        comment = UITextField()
        comment.attributedPlaceholder = NSAttributedString(
            string: "Комментарий",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        comment.borderStyle = .roundedRect
        comment.backgroundColor = .black
        comment.textColor = .white
        comment.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(comment)

        price = UITextField()
        price.attributedPlaceholder = NSAttributedString(
            string: "Цена",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        price.borderStyle = .roundedRect
        price.backgroundColor = .black
        price.textColor = .white
        price.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(price)
        
        let button = UIButton()
        button.setTitle("Добавить экспертизу", for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openDocumentPicker), for: .touchUpInside)
        contentView.addSubview(button)

        // Устанавливаем ограничения
        NSLayoutConstraint.activate([
            // Позиционируем основной контейнер
            textContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            textContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Элементы внутри textContainerView
            typeLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 20),
            typeLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            typeLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            dateLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            pay.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            pay.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            pay.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            statusLabel.topAnchor.constraint(equalTo: pay.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            userName.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            userName.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            expertName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10),
            expertName.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            expertName.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            expertName.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -20),

            // Коллекция изображений
            collectionView.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 150),

            // Поля "Цена" и "Комментарий"
            price.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            price.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            price.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            price.heightAnchor.constraint(equalToConstant: 40),

            comment.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 20),
            comment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            comment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            comment.heightAnchor.constraint(equalToConstant: 40),

            // Кнопки
            accessbtn.topAnchor.constraint(equalTo: comment.bottomAnchor, constant: 20),
            accessbtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            accessbtn.widthAnchor.constraint(equalToConstant: 170),
            accessbtn.heightAnchor.constraint(equalToConstant: 40),

            cancelbtn.topAnchor.constraint(equalTo: accessbtn.topAnchor),
            cancelbtn.leadingAnchor.constraint(equalTo: accessbtn.trailingAnchor, constant: 20),
            cancelbtn.widthAnchor.constraint(equalToConstant: 170),
            cancelbtn.heightAnchor.constraint(equalToConstant: 40),

            commentbtn.topAnchor.constraint(equalTo: accessbtn.bottomAnchor, constant: 20),
            commentbtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commentbtn.widthAnchor.constraint(equalToConstant: 170),
            commentbtn.heightAnchor.constraint(equalToConstant: 40),

            chooseExpert.topAnchor.constraint(equalTo: commentbtn.topAnchor),
            chooseExpert.leadingAnchor.constraint(equalTo: commentbtn.trailingAnchor, constant: 20),
            chooseExpert.widthAnchor.constraint(equalToConstant: 170),
            chooseExpert.heightAnchor.constraint(equalToConstant: 40),

            button.topAnchor.constraint(equalTo: chooseExpert.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 40),

            savebtn.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20),
            savebtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            savebtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            savebtn.heightAnchor.constraint(equalToConstant: 40),

            // Нижний констрейнт для контента
            savebtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])


    }

    func displayOrderDetails(order: (id: String, userName: String,expertName: String, date: String, typeExpertiz: Int, pay: Int, status: Int, userText: String?, price: Int, photo1: String?, photo2: String?, photo3: String?, photo4: String?)) {
        // Обновляем элементы интерфейса на основе заказа
        typeLabel.text = "Тип: \(order.typeExpertiz)"
        dateLabel.text = "Дата: \(order.date)"
        descriptionLabel.text = order.userText
        priceLabel.text = "Цена: \(order.price)"
        statusLabel.text = "Статус: \(order.status)"
        if order.pay == 0 {
            pay.text = "Оплата: Заказ не оплачен"
        } else {
            pay.text = "Оплата: Заказ оплачен"
        }

        userName.text = "Заказчик: \(order.userName)"
        expertName.text = "Эксперт: \(order.expertName)"
        MoreDetailID.share.currentStatusID = order.status

        // Загружаем фотографии
        photos = [order.photo1 ?? "", order.photo2 ?? "", order.photo3 ?? "", order.photo4 ?? ""].compactMap { $0 }
        print("Ссылка на фото 1:\(order.photo1)")
        print("Ссылка на фото 2:\(order.photo2)")
        print("Ссылка на фото 3:\(order.photo3)")
        print("Ссылка на фото 4:\(order.photo4)")
        collectionView.reloadData()
    }

    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
        
        // Удаляем предыдущие subviews (если ячейка переиспользуется)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        // Создаем UIImageView для изображения
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // Берем ссылку на фото из массива photos
        let imageUrl = photos[indexPath.row]
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        
        // Загружаем изображение из Firebase Storage
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Ошибка загрузки изображения: \(error)")
                imageView.image = UIImage(named: "placeholder") // Картинка-заглушка
            } else if let data = data {
                imageView.image = UIImage(data: data)
            }
        }
        
        // Добавляем UITapGestureRecognizer
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTap)
        
        // Добавляем UIImageView в ячейку
        cell.contentView.addSubview(imageView)
        
        return cell
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView,
           let cell = imageView.superview as? UICollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) { // Получаем indexPath ячейки
            let imageUrl = photos[indexPath.row] // Получаем URL изображения
            openFullImage(with: imageUrl) // Открываем полный просмотр изображения
        }
    }

    func openFullImage(with imageUrl: String) {
        let fullImageVC = UIStoryboard(name: "FullImageViewController", bundle: nil)
        let vsa = fullImageVC.instantiateViewController(withIdentifier: "FullImageViewController")as! FullImageViewController// Ваш контроллер для отображения полной версии
        vsa.imageUrl = imageUrl // Передаем ссылку на изображение
        self.present(vsa, animated: true, completion: nil)
    }




    @objc func accessbtnTapped() {
        let alert = UIAlertController(title: "Подтверждение", message: "Вы подтвердили заказ", preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(OKAction)
        present(alert,animated: true)
        changeOrder.shared.changeStatusId = 1
        MoreDetailID.share.currentStatusID = 1
        changeOrder.shared.comment = "Заказ подтвержден, оплатите его по кнопке снизу"
    }

    @objc func cancelbtnTapped() {
        let alert = UIAlertController(title: "Отмена", message: "Вы отменили заказ", preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(OKAction)
        present(alert,animated: true)
        changeOrder.shared.changeStatusId = 3
        MoreDetailID.share.currentStatusID = 3
        changeOrder.shared.comment = "Заказ отменен, к сожалению мы не сможем Вам помочь"
    }

    @objc func commentbtnTapped() {
        if let text = comment.text, !text.isEmpty
        {
            changeOrder.shared.comment = text
            let alert = UIAlertController(title: "Отлично!", message: "Вы записали комментарий заказчику", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            changeOrder.shared.changeStatusId = MoreDetailID.share.currentStatusID
            present(alert,animated: true)
        }else
        {
            let alert = UIAlertController(title: "Ошибка", message: "Поле комментария пустое", preferredStyle: .actionSheet)
            let OKAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(OKAction)
            present(alert,animated: true)
        }
    }

    @objc func savebtnTapped() {
        guard let orderID = MoreDetailID.share.id else {
            print("Ошибка: orderID не установлен")
            return
        }
        guard let userID = MoreDetailID.share.userID else
        {
            print("Ошибка: userID не установлен")
            return
        }

        // Создаем словарь с изменениями
        var updates: [String: Any] = [:]
        
        // Проверяем, нужно ли обновить цену
        if let newPriceText = price.text, let newPrice = Int(newPriceText) {
            updates["price"] = newPrice
        }

        // Проверяем, нужно ли назначить эксперта
        if let expertID = changeOrder.shared.experdID {
            updates["expertID"] = expertID // или другое поле для ID эксперта
            updates["expertName"] = changeOrder.shared.expertName
        }
        if let comment = changeOrder.shared.comment
        {
            updates["expertAnswer"] = comment
            updates["status"] = changeOrder.shared.changeStatusId
        }

        // Обновляем документ в Firestore
        Firestore.firestore().collection("users").document(userID).collection("orders").document(orderID).updateData(updates) { error in
            if let error = error {
                print("Ошибка обновления заказа: \(error)")
            } else {
                print("Заказ успешно обновлен")
                // Можно добавить логику для обновления UI или уведомления пользователя
            }
        }
    }


    @objc func chooseExpertTapped() {
        fetchExperts()
    }

    private func fetchExperts() {
        self.experts.removeAll()
        Firestore.firestore().collection("experts").getDocuments { (snapshot, error) in
            if let error = error {
                print("Ошибка получения документа: \(error)")
                return
            }
            for document in snapshot!.documents {
                let usrID = document.documentID
                guard let data = document.data() as? [String: Any] else {
                    print("Ошибка получения данных документа")
                    return
                }
                guard let usrName = data["expertName"] as? String else {
                    print("Ошибка получения имени эксперта")
                    return
                }
                self.experts.append((id: usrID, expertName: usrName))
            }
            
            // После загрузки экспертов отображаем UIAlertController
            self.presentExpertSelectionAlert()
        }
    }

    private func presentExpertSelectionAlert() {
        let alert = UIAlertController(title: "Выберите эксперта", message: nil, preferredStyle: .alert)

        for expert in experts {
            alert.addAction(UIAlertAction(title: expert.expertName, style: .default, handler: { _ in
                print("Эксперт: \(expert.expertName)\n ID: \(expert.id)")
                changeOrder.shared.experdID = expert.id
                changeOrder.shared.expertName = expert.expertName
            }))
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    @objc func openDocumentPicker() {
           let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item]) // Для открытия файлов
           documentPicker.delegate = self
           present(documentPicker, animated: true, completion: nil)
       }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            // Здесь можно обработать выбранный файл
            print("Выбран файл: \(url)")
        }

        // Обработка ошибки
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Выбор файла отменен")
        }

}
