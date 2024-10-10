import UIKit

class EntrViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Задний фон окна
        view.backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        
        // Лого
        let mainLogo = UIImageView()
        mainLogo.image = UIImage(named: "logo_final")
        mainLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLogo)
        
        // Кнопки
        let firstButton = createButton(text: "Новые заказы")
        let secondButton = createButton(text: "Активные заказы")
        firstButton.isUserInteractionEnabled = true
        secondButton.isUserInteractionEnabled = true
        
        let firstAction = UITapGestureRecognizer(target: self, action: #selector(firstTapped))
        firstButton.addGestureRecognizer(firstAction)
        
        let secondAction = UITapGestureRecognizer(target: self, action: #selector(secondTapped))
        secondButton.addGestureRecognizer(secondAction)
        
        view.addSubview(firstButton)
        view.addSubview(secondButton)
        
        NSLayoutConstraint.activate([
            // Логотип
            mainLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            mainLogo.widthAnchor.constraint(equalToConstant: 100),
            mainLogo.heightAnchor.constraint(equalToConstant: 100),
            // Кнопки
            firstButton.topAnchor.constraint(equalTo: mainLogo.bottomAnchor, constant: 30),
            firstButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstButton.widthAnchor.constraint(equalToConstant: 200),
            firstButton.heightAnchor.constraint(equalToConstant: 50),
            
            secondButton.topAnchor.constraint(equalTo: firstButton.bottomAnchor, constant: 30),
            secondButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondButton.widthAnchor.constraint(equalToConstant: 200),
            secondButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Метод создания кнопки
    func createButton(text: String) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.backgroundColor = UIColor(red: 251/255, green: 109/255, blue: 16/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    // Метод обработки нажатия на первую кнопку
    @objc func firstTapped() {
        let storyboard = UIStoryboard(name: "NewViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "NewViewController")as! NewViewController
        present(vsa,animated: true)
    }
    
    // Метод обработки нажатия на вторую кнопку
    @objc func secondTapped() {
        let storyboard = UIStoryboard(name: "NewExpertizViewController", bundle: nil)
        let vsa = storyboard.instantiateViewController(withIdentifier: "NewExpertizViewController")as! NewExpertizViewController
        present(vsa,animated:true)
    }
}
