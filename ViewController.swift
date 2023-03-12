//
//  ViewController.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var numberTextField: UITextField! {
        didSet {
            numberTextField.keyboardType = .numberPad
            numberTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)

        }
    }
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.textColor = .systemRed
            errorLabel.text = "The number should be in range of 1 to 10"
            errorLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var viewModel: DogGeneratorInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = DogsImagesGenerator()
        viewModel?.output = self
    }

    @IBAction func didTapOnSubmit(_ sender: UIButton) {
        guard let number = Int(numberTextField.text ?? "") else { return }
        viewModel?.getImages(number: number)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validateInput(text: textField.text ?? "")
    }
    
    private func validateInput(text: String) {
        if let number = Int(text) {
            guard number > 0 && number <= 10 else { setInvalidState()
                return }
            setValidState()
        } else {
            setInvalidState()
        }
    }
    
    private func setInvalidState() {
        errorLabel.isHidden = false
        submitButton.isEnabled = false
    }
    
    private func setValidState() {
        errorLabel.isHidden = true
        submitButton.isEnabled = true
    }
}

extension ViewController: DogGeneratorOutput {
    func didGetNextImage(image: UIImage?) {
        if let image = image {
            self.dogImageView.image = image
        } else {
            nextButton.isEnabled = false
        }
    }
    
    func didGetPreviousImage(image: UIImage?) {
        if let image = image {
            self.dogImageView.image = image
        } else {
            previousButton.isEnabled = true
        }
    }
}
