import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class OrderDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var order: (id: String, userName: String, date: String, typeExpertiz: Int, pay: Int, result: Int, userText: String?, price: Int, photo1: String?, photo2: String?, photo3: String?, photo4: String?)?
    
    private var collectionView: UICollectionView!
    private var photos: [String] = []
    
    private var typeLabel: UILabel!
    private var dateLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var priceLabel: UILabel!
    private var statusLabel: UILabel!
    private var expertNameLabel: UILabel!
    private var text1Answer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        setupUI()
        
        if let order = order {
            displayOrderDetails(order: order)
        }
    }
    
    func setupUI() {
        // Контейнер для текста с черным фоном
        let textContainerView = UIView()
        textContainerView.backgroundColor = .black
        textContainerView.layer.cornerRadius = 10
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textContainerView)
        
        // Добавление UILabel для отображения типа экспертизы
        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 18)
        typeLabel.textColor = .white
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(typeLabel)
        
        // Добавление UILabel для отображения даты
        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.textColor = .white
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(dateLabel)
        
        // Добавление UILabel для отображения описания заказа
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(descriptionLabel)
        
        // Добавление UILabel для отображения цены
        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 18)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(priceLabel)
        
        // Добавление UILabel для отображения статуса
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 18)
        statusLabel.textColor = .white
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(statusLabel)
        
        // Добавление UILabel для отображения имени эксперта
        expertNameLabel = UILabel()
        expertNameLabel.font = UIFont.systemFont(ofSize: 18)
        expertNameLabel.textColor = .white
        expertNameLabel.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.addSubview(expertNameLabel)
        
        // Настройка UICollectionView для фотографий
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 150)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        view.addSubview(collectionView)
        
        // Контейнер для ответа эксперта
        let answerFromExpert = UIView()
        answerFromExpert.backgroundColor = .black
        answerFromExpert.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.layer.cornerRadius = 10
        view.addSubview(answerFromExpert)
        
         text1Answer = UILabel()
        text1Answer.font = UIFont.systemFont(ofSize: 18)
        text1Answer.textColor = .white
        text1Answer.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.addSubview(text1Answer)
        
        let answerExpertText = UILabel()
        answerExpertText.font = UIFont.systemFont(ofSize: 16)
        answerExpertText.textColor = .white
        answerExpertText.numberOfLines = 0
        answerExpertText.translatesAutoresizingMaskIntoConstraints = false
        answerFromExpert.addSubview(answerExpertText)
        
        // Установка constraint для элементов интерфейса
        NSLayoutConstraint.activate([
            textContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            typeLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 10),
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

            statusLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),

            expertNameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            expertNameLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: 10),
            expertNameLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -10),
            expertNameLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -10),

            collectionView.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 150),

            answerFromExpert.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            answerFromExpert.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answerFromExpert.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            text1Answer.topAnchor.constraint(equalTo: answerFromExpert.topAnchor, constant: 10),
            text1Answer.leadingAnchor.constraint(equalTo: answerFromExpert.leadingAnchor, constant: 10),
            text1Answer.trailingAnchor.constraint(equalTo: answerFromExpert.trailingAnchor, constant: -10),

            answerExpertText.topAnchor.constraint(equalTo: text1Answer.bottomAnchor, constant: 10),
            answerExpertText.leadingAnchor.constraint(equalTo: answerFromExpert.leadingAnchor, constant: 10),
            answerExpertText.trailingAnchor.constraint(equalTo: answerFromExpert.trailingAnchor, constant: -10),
            answerExpertText.bottomAnchor.constraint(equalTo: answerFromExpert.bottomAnchor, constant: -10)
        ])
    }
    
    func displayOrderDetails(order: (id: String, price: Int, userName: String, date: String, typeExpertiz: Int, pay: Int, result: Int, userText: String?, photo1: String?, photo2: String?, photo3: String?, photo4: String?)) {
        // Заполнение данных в UILabel
        if order.typeExpertiz == 1 {
            typeLabel.text = "Тип экспертизы: ДТП"
        } else if order.typeExpertiz == 2 {
            typeLabel.text = "Тип экспертизы: Окон"
        } else if order.typeExpertiz == 3 {
            typeLabel.text = "Тип экспертизы: Заливов"
        } else if order.typeExpertiz == 4 {
            typeLabel.text = "Тип экспертизы: Обуви"
        } else if order.typeExpertiz == 5 {
            typeLabel.text = "Тип экспертизы: Одежды"
        } else if order.typeExpertiz == 6 {
            typeLabel.text = "Тип экспертизы: Строительная"
        } else if order.typeExpertiz == 7 {
            typeLabel.text = "Тип экспертизы: Бытовая"
        } else if order.typeExpertiz == 8 {
            typeLabel.text = "Тип экспертизы: На заказ"
        } else {
            typeLabel.text = "Тип экспертизы: Неизвестен"
        }
        
        dateLabel.text = "Дата заказа: \(order.date)"
        descriptionLabel.text = "Описание: \(order.userText ?? "Нет описания")"
        priceLabel.text = "Цена: \(order.price)₽"
        
        // Установка статуса заказа
        switch order.result {
        case 0:
            statusLabel.text = "Статус: На рассмотрении"
            text1Answer.text = "Ответ эксперта отсутсвует. Ожидайте подтверждения заказа от администратора"
        case 1:
            statusLabel.text = "Статус: В работе"
            text1Answer.text = "Ответ эксперта отсутсвует. Ожидайте готовности заказа, сразу после завершения работы мы отправим Вам Ваше заключение"
        case 2:
            statusLabel.text = "Статус: Готов"
        default:
            statusLabel.text = "Статус: Отменен"
        }
        
        expertNameLabel.text = "Эксперт: Не назначен"

        // Загружаем фотографии
        if let photo1 = order.photo1 {
            photos.append(photo1)
        }
        if let photo2 = order.photo2 {
            photos.append(photo2)
        }
        if let photo3 = order.photo3 {
            photos.append(photo3)
        }
        if let photo4 = order.photo4 {
            photos.append(photo4)
        }
        
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photoUrl = photos[indexPath.item]

        // Загрузка изображения с Firebase Storage
        loadImage(from: photoUrl, into: cell.imageView)

        return cell
    }

    // MARK: - Image Loading

    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                    imageView.layer.cornerRadius = 10
                    imageView.clipsToBounds = true
                }
            }
        }.resume()
    }
}

// MARK: - PhotoCell

class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true

        // Установка constraint для imageView
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
