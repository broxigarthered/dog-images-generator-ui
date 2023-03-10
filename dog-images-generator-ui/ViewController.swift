//
//  ViewController.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import UIKit
import dogs_images_generator

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
    @IBOutlet weak var previousButton: UIButton! {
        didSet {
            previousButton.isEnabled = false
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
             nextButton.isEnabled = false
        }
    }
    
    private lazy var dogsImagesGenerator: DogsImagesGenerator = DogsImagesGenerator()
    


    @IBAction func didTapOnSubmit(_ sender: UIButton) {
        guard let number = Int(numberTextField.text ?? "") else { return }
        
        dogsImagesGenerator.getImages(number: number) { [unowned self] result in
            updateButtonState(currentIndex: self.dogsImagesGenerator.currentIndex,
                              limitIndex: self.dogsImagesGenerator.imageURLs.count)
            switch result {
            case .success(_):
                self.getFirstImage()
            case .failure(let error):
                displayError(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func didTapOnNext(_ sender: UIButton) {
        
        dogsImagesGenerator.getNextImage(completion: { [unowned self] result in
            updateButtonState(currentIndex: self.dogsImagesGenerator.currentIndex,
                              limitIndex: self.dogsImagesGenerator.imageURLs.count)
            self.displayResult(result: result)
        })
    }
    
    @IBAction func didTapOnPrevious(_ sender: UIButton) {
        dogsImagesGenerator.getPreviousImage(completion: { [unowned self] result in
            updateButtonState(currentIndex: self.dogsImagesGenerator.currentIndex,
                              limitIndex: self.dogsImagesGenerator.imageURLs.count)
            
            self.displayResult(result: result)
        })
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validateInput(text: textField.text ?? "")
    }
    
    
    private func getFirstImage() {
        dogsImagesGenerator.getImage { [weak self] result in
            self?.displayResult(result: result)
        }
    }
    
    private func displayResult(result: Result<UIImage, Error>) {
        switch result {
        case .success(let image):
            dogImageView.image = image
        case .failure(let error):
            displayError(message: error.localizedDescription)
        }
    }
    
    private func displayError(message: String) {
        let alert = UIAlertController(title: "Ops we have a problem!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func validateInput(text: String) {
        if let number = Int(text) {
            guard number > 0 && number <= 10 else {
                setInvalidState()
                return
            }
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
    
    // TODO: Move to a view model
    private func updateButtonState(currentIndex: Int, limitIndex: Int) {
        DispatchQueue.main.async {
            // lower bound
            if currentIndex == 0 {
                self.previousButton.isEnabled = false
            } else if currentIndex > 0 {
                self.previousButton.isEnabled = true
            }
            
            // upper bound
            if currentIndex == limitIndex - 1 {
                self.nextButton.isEnabled = false
            } else {
                self.nextButton.isEnabled = true
            }
        }
    }
}
