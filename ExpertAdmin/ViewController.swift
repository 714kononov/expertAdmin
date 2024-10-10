import UIKit
import SQLite3


class ExpertAccess
{
    static let shared = ExpertAccess()
    var status: Int?
}


class ViewController: UIViewController {
    
   
    
    let registrationLabel = UILabel()
    let loginTextField = UITextField()
    let successButton = UIButton(type: .system)
    let passwordTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Создаем слой градиента
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Добавляем логотип
        let mainLogo = UIImageView()
        mainLogo.image = UIImage(named: "logo_final")
        mainLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLogo)
        
        // Центрируем логотип по горизонтали
        NSLayoutConstraint.activate([
            mainLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            mainLogo.widthAnchor.constraint(equalToConstant: 100),
            mainLogo.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Создаем UITextField для логина
        loginTextField.placeholder = "Логин"
        loginTextField.borderStyle = .roundedRect
        loginTextField.backgroundColor = .black
        loginTextField.textColor = .white
        loginTextField.attributedPlaceholder = NSAttributedString(string: "Логин", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginTextField)
        
        // Создаем UITextField для пароля
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = .black
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // Создаем кнопку "Войти"
        successButton.setTitle("Войти", for: .normal)
        successButton.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        successButton.setTitleColor(.white, for: .normal)
        successButton.layer.cornerRadius = 10
        successButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successButton)
        
        successButton.isUserInteractionEnabled = true
        
        //Обработчик нажатия на кнопку
        let tapButton = UITapGestureRecognizer(target: self, action:#selector(buttonentryTapped))
        successButton.addGestureRecognizer(tapButton)
        
        // Создаем UILabel для регистрации
        registrationLabel.textColor = UIColor.white
        registrationLabel.text = "Зарегестрироваться"
        registrationLabel.font = UIFont.systemFont(ofSize: 14)
        registrationLabel.textAlignment = .center
        registrationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registrationLabel)
        
        // Включаем взаимодействие с пользователем для UILabel
        registrationLabel.isUserInteractionEnabled = true
        
        // Создаем распознаватель жестов нажатия
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(registrationLabelTapped))
        registrationLabel.addGestureRecognizer(tapGesture)
        
        
        // Устанавливаем констрейнты
        NSLayoutConstraint.activate([
            // UITextField для логина
            loginTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTextField.topAnchor.constraint(equalTo: mainLogo.bottomAnchor, constant: 20),
            loginTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            loginTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // UITextField для пароля
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Кнопка "Войти"
            successButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            successButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            successButton.heightAnchor.constraint(equalToConstant: 50),
            
            // UILabel для регистрации
            registrationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registrationLabel.topAnchor.constraint(equalTo: successButton.bottomAnchor, constant: 20),
            registrationLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            registrationLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func registrationLabelTapped()
    {
        let storyboard = UIStoryboard(name: "RegViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "RegViewController")as! RegViewController
        present(vsa,animated:true)
    }
    //Открытие нового окна
    @objc func buttonentryTapped() {
        // Получаем введенные логин и пароль
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, заполните все пустые поля!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
            print("Введите логин и пароль")
            return
        }

        // Работа с базой данных в фоновом потоке
        DispatchQueue.global().async {
            var db: OpaquePointer?

            // Путь к базе данных остается как был
            let fileURL = "/Users/admin/Desktop/expert.sqlite"

            // Открываем базу данных
            if sqlite3_open(fileURL, &db) != SQLITE_OK {
                print("Ошибка открытия базы данных.")
                return
            }

            // Запрос для поиска пользователя
            let queryString = "SELECT * FROM experts WHERE Name = ? AND password = ?"
            
            var statement: OpaquePointer?

            // Подготовка запроса
            if sqlite3_prepare_v2(db, queryString, -1, &statement, nil) != SQLITE_OK {
                print("Ошибка подготовки запроса.")
                sqlite3_close(db)
                return
            }

            // Привязываем параметры запроса
            sqlite3_bind_text(statement, 1, (login as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (password as NSString).utf8String, -1, nil)

            // Выполняем запрос
            if sqlite3_step(statement) == SQLITE_ROW {
                // Пользователь найден
                let access = sqlite3_column_int(statement, 2) // Уровень доступа
                
                // Сохраняем уровень доступа в глобальном классе
                ExpertAccess.shared.status = Int(access)
                
                // Переход к следующему экрану выполняется на основном потоке
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "EntrViewController", bundle: nil)
                    if let entrViewController = storyboard.instantiateViewController(withIdentifier: "EntrViewController") as? EntrViewController {
                        self.present(entrViewController, animated: true, completion: nil)
                    }
                }
            } else {
                // Пользователь не найден или пароль неверный
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message: "Логин или пароль неверный! Попробуйте еще раз!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ок", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                    print("Неверный логин или пароль.")
                }
            }

            // Очистка
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
    }
}

