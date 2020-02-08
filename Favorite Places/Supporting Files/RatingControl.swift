//
//  RatingControl.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 08.02.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {//отображаем кнопки, созданные в коде, в interfaceBuilder
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    //MARK: Propeties
    private var ratingButtons = [UIButton]()
    //переносим свойства в interfaceBuilder. необходимо явно типизировать каждое свойство
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButton()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButton()
        }
    }
    
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    //MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {//действие при нажатии
        
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        
        //вычисляем рейтинг выбранной кнопки
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    //MARK: Private Methods
    
    private func setupButton() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)//удаляем элементы из stackView
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        //загрузка изображений для кнопок
        
        let bundle = Bundle(for: type(of: self))
        
        let justStar = UIImage(named: "filledStar",
                               in: bundle,
                               compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let fullStar = UIImage(named: "highlightedStar",
                               in: bundle,
                               compatibleWith: self.traitCollection)
        
        
        
        for _ in 0..<starCount {
            //создание кнопки
            let button = UIButton()

            //задаём изображения для кнопок
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(justStar, for: .selected)
            button.setImage(justStar, for: .highlighted)
           // button.setImage(fullStar, for: .selected)
            
            //constraints
            button.translatesAutoresizingMaskIntoConstraints = false//отлючает автоматически-сгенерированные ограничения
            button.heightAnchor.constraint(equalToConstant: starSize.height ).isActive = true//ограничения высоты и ширины
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)//обработчик нажатия
            
            //добавляем кнопку в stackView
            addArrangedSubview(button)
            //добавление кнопки в массив
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
