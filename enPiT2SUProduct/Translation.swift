//
//  Translation.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/12/03.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import Foundation

class Translation {
	
	var API_KEY: String
	var sourceLanguage: String
    var targetLanguage: String
	var translation: String = ""
	
	init(_ sourceLanguage: String, _ targetLanguage: String) {
		self.API_KEY = Credentials.CloudTranslationApiKey
		self.sourceLanguage = sourceLanguage
		self.targetLanguage = targetLanguage
	}
	
	/* 翻訳処理 */
	func translate(_ caption: String) -> String {
		self.prepare(caption) { (result) in
			self.translation = result
		}
		return self.translation
	}
	
	/* Google翻訳APIを使って、字幕の翻訳結果を取得する */
	func prepare(_ caption: String, callback: @escaping (_ translatedText: String) -> ()) {
		
		guard
			let urlEncodedText = caption.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
			let url            = URL(string: "https://www.googleapis.com/language/translate/v2?key=\(self.API_KEY)&q=\(urlEncodedText)&source=\(self.sourceLanguage)&target=\(self.targetLanguage)") else {
				return
		}
		
		// セマフォを0で生成
		let semaphore = DispatchSemaphore(value: 0)

		// リクエストの処理内容
		let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
			
			guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
				print("Something went wrong: \(String(describing: error?.localizedDescription))")
				return
			}
			
			do {
				guard
					let data            = data,
					let json            = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
					let jsonData        = json["data"]                  as? [String : Any],
					let translations    = jsonData["translations"]      as? [NSDictionary],
					let translation     = translations.first            as? [String : Any],
					let translatedText  = translation["translatedText"] as? String
					else {
						return
				}
				callback(translatedText)
				semaphore.signal()
			} catch {
				print("Serialization failed: \(error.localizedDescription)")
			}
		})
		
		// リクエスト実行
		httprequest.resume()
		// レスポンスが返ってくるまで待つ
		semaphore.wait()
	}
}

