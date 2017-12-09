//
//  Translation.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/12/03.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import Foundation

struct TranslationInfo {
	public var sourceLanguage: String
	public var targetLanguage: String
	public var text: String
	
	public init(sourceLanguage: String, targetLanguage: String, text: String) {
		self.sourceLanguage = sourceLanguage
		self.targetLanguage = targetLanguage
		self.text = text
	}
}


class Translation {
	
	/// Google翻訳のAPIキー
	public var API_KEY: String
	
	public init() {
		//API_KEY = "AIzaSyBy25ZpPXYkIDHYfUAzBnbk2GUAfRSD4Ko"
		self.API_KEY = "AIzaSyC_Pr-LZAncvufc7wN_VHDY2FGgevyx4ZQ"
	}
	
	
	func translate(params: TranslationInfo, callback: @escaping (_ translatedText: String) -> ()) {
		
		guard
			let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
			let url            = URL(string: "https://www.googleapis.com/language/translate/v2?key=\(self.API_KEY)&q=\(urlEncodedText)&source=\(params.sourceLanguage)&target=\(params.targetLanguage)") else {
				return
		}
		
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
				
			} catch {
				print("Serialization failed: \(error.localizedDescription)")
			}
		})
		
		httprequest.resume()
	}
}
