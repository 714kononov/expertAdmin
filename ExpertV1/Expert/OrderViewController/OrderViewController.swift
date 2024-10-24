import UIKit

class OrderViewController: UIViewController {
    
    // Объявляем inputField как свойство класса
    var inputField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        let H1 = UITextView()

        // Создаем атрибутированную строку для H1
        let fullText = "Шаг первый"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Определяем диапазон для слова "Шаг" и задаем ему оранжевый цвет
        let orangeColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        let rangeForOrangeText = (fullText as NSString).range(of: "Шаг")
        attributedString.addAttribute(.foregroundColor, value: orangeColor, range: rangeForOrangeText)

        // Определяем диапазон для слова "первый" и задаем ему белый цвет
        let rangeForWhiteText = (fullText as NSString).range(of: "первый")
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: rangeForWhiteText)

        // Устанавливаем шрифт для всего текста
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 30), range: NSMakeRange(0, attributedString.length))

        // Применяем атрибутированную строку к UITextView
        H1.attributedText = attributedString
        H1.backgroundColor = .clear
        H1.isScrollEnabled = false
        H1.isEditable = false
        H1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(H1)
        
        let text1 = createText(withText: "Вам необходимо описать, что у вас случилось, но кратко, доходчиво и понятно, без всякой воды.")
        view.addSubview(text1)
        
        inputField = UITextField() // Теперь inputField объявлена как свойство класса
        inputField.placeholder = "Введите описание здесь..."
        inputField.attributedPlaceholder = NSAttributedString(
            string: "Введите описание здесь...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)]
        )
        inputField.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
        inputField.font = UIFont.systemFont(ofSize: 18)
        inputField.borderStyle = .roundedRect
        inputField.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        inputField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputField)
        
        // Кнопки "Назад" и "Далее"
        let prevButton = createButton(title: "Назад")
        let nextButton = createButton(title: "Далее")
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        
        prevButton.isUserInteractionEnabled = true
        nextButton.isUserInteractionEnabled = true
        
        let nextAction = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        nextButton.addGestureRecognizer(nextAction)
        
        let prevAction = UITapGestureRecognizer(target: self, action: #selector(prevTapped))
        prevButton.addGestureRecognizer(prevAction)
        
        NSLayoutConstraint.activate([
            H1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            H1.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            text1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text1.topAnchor.constraint(equalTo: H1.bottomAnchor, constant: 20),
            text1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            inputField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputField.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 20),
            inputField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            inputField.heightAnchor.constraint(equalToConstant: 50),
            
            // Кнопки "Назад" и "Далее" расположены ниже под UITextField и уменьшены в размере
            prevButton.leadingAnchor.constraint(equalTo: inputField.leadingAnchor),
            prevButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 60),
            prevButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            prevButton.heightAnchor.constraint(equalToConstant: 40),
            
            nextButton.trailingAnchor.constraint(equalTo: inputField.trailingAnchor),
            nextButton.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 60),
            nextButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            nextButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func createText(withText text: String) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.text = text
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
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
    
    @objc func nextTapped() {
        if let messageText = inputField.text, !messageText.isEmpty {
            UserOrder.shared.userText = messageText
            let storyboard = UIStoryboard(name: "GetPhotoViewController", bundle: nil)
            let vsa = storyboard.instantiateViewController(withIdentifier: "GetPhotoViewController")as! GetPhotoViewController
            present(vsa, animated: true)
        } else {
            // Если текстовое поле пустое, показать ошибку
            let errorAlert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите описание.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
            errorAlert.addAction(OKAction)
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    @objc func prevTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
