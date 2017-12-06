//
//  Caption.swift
//  enPiT2SUProduct
//
//  Created by 池崎雄介 on 2017/11/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import SpeechToTextV1

class Caption {
    
    var sentences: [Sentence]!
    
    init(_ results: SpeechRecognitionResults) {
        sentences = [Sentence]()
        
        let result = results.results[0]
        
        print("Results count = \(results.results.count)")
        print("Alternatives count = \(result.alternatives.count)")
        
        for result in results.results {
            let sentence = result.alternatives[0].transcript
            let startTime = result.alternatives[0].timestamps![0].startTime
            let endTime = result.alternatives[0].timestamps![result.alternatives[0].timestamps!.count-1].endTime
            
            sentences.append(Sentence(sentence, startTime, endTime))
        }
    }
    
    class Sentence {
        var sentence: String!
        var startTime: Double!
        var endTime: Double!
        
        init(_ sentence: String, _ startTime: Double, _ endTime: Double) {
            self.sentence = sentence
            self.startTime = startTime
            self.endTime = endTime
        }
    }
    
}
