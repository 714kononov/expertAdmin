import UIKit
import FirebaseStorage

class FullImageViewController: UIViewController {
    var imageUrl: String?
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
        loadImage()
    }

    private func setupImageView() {
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)

        // Добавим возможность закрыть изображение по нажатию
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
        imageView.addGestureRecognizer(tapGesture)
    }

    private func loadImage() {
        guard let imageUrl = imageUrl else { return }
        let storageRef = Storage.storage().reference(forURL: imageUrl)

        // Загружаем изображение
        storageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if let error = error {
                print("Ошибка загрузки изображения: \(error)")
                self.imageView.image = UIImage(named: "placeholder")
            } else if let data = data {
                self.imageView.image = UIImage(data: data)
            }
        }
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
