//
//  Translator.swift
//  WeatherApp
//
//  Created by Иван on 26.11.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

public class Translator {
    class func translateString(phrase: String) -> String {
        var outString = ""
        
        for symbol in phrase.characters {
            switch symbol {
                case Character("А"): outString += "%d0%90"; break
                case Character("Б"): outString += "%d0%91"; break
                case Character("В"): outString += "%d0%92"; break
                
                default: outString += ""; break
            }
        }
        
        return outString
    }
    
}
