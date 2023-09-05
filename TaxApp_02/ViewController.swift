

//
//  ViewController.swift
//  TaxApp_02
//  Created by 春菜森 on 2023/09/04.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - テキストなど
    @IBOutlet weak var taxSegmentedControl: UISegmentedControl! // 税率選択のためのセグメントコントロール
    @IBOutlet weak var inputValueTextField: UITextField!        // ユーザが価格を入力するテキストフィールド
    @IBOutlet weak var resultLabel: UILabel!                    // 計算結果を表示するラベル
    @IBOutlet weak var addList: UITextView!                     // 履歴リスト
    
    // MARK: - ボタン
    @IBOutlet weak var yenButton: UIImageView!                  // 円ボタン
    @IBOutlet weak var yenButton_Fill: UIImageView!             // 円ボタンフィル
    @IBOutlet weak var clearButton: UIImageView!                // 入力値クリア
    @IBOutlet weak var clearButton_Fill: UIImageView!           // 入力値クリアフィル
    @IBOutlet weak var add: UIImageView!                        // 履歴リストへ追加
    @IBOutlet weak var add_Fill: UIImageView!                   // 履歴リストへ追加フィル
    @IBOutlet weak var listClear: UIImageView!                  // 履歴クリア
    @IBOutlet weak var listClear_Fill: UIImageView!             // 履歴クリアフィル

    // MARK: -文字数規制
    // 入力できる数字の最大桁数
    let maxDigits = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    // MARK: -起動時の設定: FILLボタン非表示設定
        // 起動時の設定: 各ボタンのFILL画像を非表示に設定
        yenButton_Fill.isHidden = true
        clearButton_Fill.isHidden = true
        add_Fill.isHidden = true
        listClear_Fill.isHidden = true
        
    // MARK: -App起動時初期設定
        setupSegmentedControl()  // セグメントコントロールの初期設定を実行
        inputValueTextField.delegate = self  // テキストフィールドのデリゲートをこのクラスに設定
        
    // MARK: -ボタンをタップした時の動作指示
        setupGesture(for: yenButton, fillImageView: yenButton_Fill, action: #selector(yenButtonPressed(_:)))
        setupGesture(for: clearButton, fillImageView: clearButton_Fill, action: #selector(clearButtonPressed(_:)))
        setupGesture(for: add, fillImageView: add_Fill, action: #selector(addButtonPressed(_:)))
        setupGesture(for: listClear, fillImageView: listClear_Fill, action: #selector(listClearButtonPressed(_:)))
    }
    
    // セグメントコントロールの初期設定関数
    func setupSegmentedControl() {
        if let label8 = taxSegmentedControl.subviews[0] as? UILabel,
           let label10 = taxSegmentedControl.subviews[1] as? UILabel {
            label8.text = "8%"
            label8.textAlignment = .center
            label10.text = "10%"
            label10.textAlignment = .center
        }
    }
    
    // UIImageViewにタップジェスチャーを追加する関数
    func setupGesture(for imageView: UIImageView, fillImageView: UIImageView, action: Selector) {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: action)
        pressGesture.minimumPressDuration = 0
        imageView.addGestureRecognizer(pressGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    // 円ボタンが押されたときのアクション
    @objc func yenButtonPressed(_ gesture: UILongPressGestureRecognizer) {
        handlePress(for: yenButton, fillImageView: yenButton_Fill, gesture: gesture) {
            displayTaxResult()
        }
    }

    // クリアボタンが押されたときのアクション
    @objc func clearButtonPressed(_ gesture: UILongPressGestureRecognizer) {
        handlePress(for: clearButton, fillImageView: clearButton_Fill, gesture: gesture) {
            resultLabel.text = ""
            inputValueTextField.text = ""
        }
    }

    // 追加ボタンが押されたときのアクション
    @objc func addButtonPressed(_ gesture: UILongPressGestureRecognizer) {
        handlePress(for: add, fillImageView: add_Fill, gesture: gesture) {
            if let currentText = addList.text, let result = resultLabel.text {
                addList.text = currentText + "\n" + result
            } else if let result = resultLabel.text {
                addList.text = result
            }
            resultLabel.text = ""
            inputValueTextField.text = ""
        }
    }
    
    // 履歴クリアボタンが押されたときのアクション
    @objc func listClearButtonPressed(_ gesture: UILongPressGestureRecognizer) {
        handlePress(for: listClear, fillImageView: listClear_Fill, gesture: gesture) {
            addList.text = ""
        }
    }
    
    // ボタンが押された際の共通の挙動を扱う関数
    func handlePress(
        for imageView: UIImageView,
        fillImageView: UIImageView,
        gesture: UILongPressGestureRecognizer,
        action: () -> Void) {
        switch gesture.state {
            
        case .began:
            fillImageView.isHidden = false
        case .ended:
            fillImageView.isHidden = true
            action()
        default:
            break
        }
    }

    // 税込価格を計算して表示する関数
    func displayTaxResult() {
        guard let inputText = inputValueTextField.text,
                let inputPrice = Double(inputText) else {
            return
        }
        let taxRate = taxSegmentedControl.selectedSegmentIndex == 0 ? 0.08 : 0.10
        let resultPrice = inputPrice * (1 + taxRate)
        resultLabel.text = formatNumber(amount: resultPrice)
    }
    
    // 数値をカンマ区切りにする関数
    func formatNumber(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }
}

// UITextFieldの動作をカスタマイズ
extension ViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            
        // 入力された文字が数字のみか、かつ最大桁数を超えていないかをチェック
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet) && textField.text!.count + string.count <= maxDigits
    }
}
