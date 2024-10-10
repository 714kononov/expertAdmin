import UIKit
import SQLite3

class RegViewController: UIViewController {
    
    let usernameForm = UITextField()
    let H2 = UILabel()
    let userpasswordForm = UITextField()
    let userphoneForm = UITextField()
    let button1 = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.gray.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Создаем первый заголовок
        let H1 = UILabel()
        H1.text = "Добро пожаловать!"
        H1.textColor = .white
        H1.font = UIFont.systemFont(ofSize: 16)
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        // Создаем второй заголовок
        H2.textColor = .white
        H2.font = UIFont.systemFont(ofSize: 14)
        H2.translatesAutoresizingMaskIntoConstraints = false
        
        let text = "Заполните все поля для регистрации"
        let attributedString = NSMutableAttributedString(string: text)
        
        if let range = text.range(of: "все") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: nsRange)
        }
        
        H2.attributedText = attributedString
        view.addSubview(H2)
        
        // Поля ввода
        usernameForm.backgroundColor = .black
        usernameForm.textColor = .white
        usernameForm.borderStyle = .roundedRect
        usernameForm.translatesAutoresizingMaskIntoConstraints = false
        usernameForm.attributedPlaceholder = NSAttributedString(string: "Имя пользователя", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(usernameForm)
        
        userpasswordForm.backgroundColor = .black
        userpasswordForm.textColor = .white
        userpasswordForm.borderStyle = .roundedRect
        userpasswordForm.translatesAutoresizingMaskIntoConstraints = false
        userpasswordForm.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(userpasswordForm)
        
        userphoneForm.backgroundColor = .black
        userphoneForm.textColor = .white
        userphoneForm.borderStyle = .roundedRect
        userphoneForm.translatesAutoresizingMaskIntoConstraints = false
        userphoneForm.attributedPlaceholder = NSAttributedString(string: "Номер телефона", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.addSubview(userphoneForm)
        
        // Кнопка регистрации
        button1.setTitle("Зарегистрироваться", for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button1.backgroundColor = UIColor.orange
        button1.setTitleColor(.white, for: .normal)
        button1.layer.cornerRadius = 10
        button1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button1)
        
        // Используем addTarget для кнопки
        button1.addTarget(self, action: #selector(safedatabase), for: .touchUpInside)
        
        // Устанавливаем Auto Layout Constraints
        NSLayoutConstraint.activate([
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H1.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            H2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H2.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 10),
            usernameForm.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameForm.topAnchor.constraint(equalTo: H2.bottomAnchor, constant: 10),
            usernameForm.widthAnchor.constraint(equalToConstant: 250),
            usernameForm.heightAnchor.constraint(equalToConstant: 40),
            userpasswordForm.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userpasswordForm.topAnchor.constraint(equalTo: usernameForm.bottomAnchor, constant: 10),
            userpasswordForm.widthAnchor.constraint(equalToConstant: 250),
            userpasswordForm.heightAnchor.constraint(equalToConstant: 40),
            userphoneForm.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userphoneForm.topAnchor.constraint(equalTo: userpasswordForm.bottomAnchor, constant: 10),
            userphoneForm.widthAnchor.constraint(equalToConstant: 250),
            userphoneForm.heightAnchor.constraint(equalToConstant: 40),
            button1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button1.topAnchor.constraint(equalTo: userphoneForm.bottomAnchor, constant: 10),
            button1.widthAnchor.constraint(equalToConstant: 170),
            button1.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func safedatabase() {
        guard let usernameText = usernameForm.text, !usernameText.isEmpty,
              let userpasswordText = userpasswordForm.text, !userpasswordText.isEmpty,
              let userphoneText = userphoneForm.text, !userphoneText.isEmpty else {
            let errorAlert = UIAlertController(title: "Ошибка", message: "Все поля должны быть заполнены!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default)
            errorAlert.addAction(okAction)
            present(errorAlert, animated: true)
            return
        }
        
        let phoneSet = CharacterSet.decimalDigits.inverted
        if userphoneText.rangeOfCharacter(from: phoneSet) != nil || userphoneText.count < 1 {
            let errorAlert = UIAlertController(title: "Ошибка", message: "Телефон должен содержать только цифры и быть не менее 1 символа!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default)
            errorAlert.addAction(okAction)
            present(errorAlert, animated: true)
            return
        }
        
        // Подключение к базе данных SQLite
        var db: OpaquePointer?
        let dbPath = "/Users/admin/Desktop/expert.sqlite"
        
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Ошибка открытия базы данных.")
            return
        }
        
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Experts(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT,
            Access INT,
            password TEXT,
            phone TEXT
        );
        """
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Ошибка создания таблицы.")
            sqlite3_close(db)
            return
        }
        
        let insertQuery = "INSERT INTO Experts (Name, Access, password, phone) VALUES (?, 0, ?, ?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (usernameText as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (userpasswordText as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (userphoneText as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let successAlert = UIAlertController(title: "Успешно!", message: "Вы успешно зарегистрировались!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ОК", style: .default) { _ in
                    self.dismiss(animated: true, completion: nil)
                }
                successAlert.addAction(okAction)
                present(successAlert, animated: true)
            } else {
                print("Ошибка вставки данных.")
            }
        }
        
        sqlite3_finalize(statement)
        sqlite3_close(db)
    }
}
