//
//  WeatherManager.swift
//  Clima
//
//  Created by Zakaria on 11/12/19.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=4611a2a9c8ac0ba3f9d7a45573487453&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeater(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
        //print(urlString)
    }
    
    func fetchWeater(latitude: CLLocationDegrees, longitude: CLLocationDegrees ){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //1. Create a URL
        if let url = URL(string: urlString){
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
       let decoder = JSONDecoder()
        
        do{
           let decoderData = try decoder.decode(WeatherData.self, from: weatherData)
           // print(decoderData.main.temp)
            //print(decoderData.weather[0].description)
            //print(decoderData.weather[0].id)
            let id = decoderData.weather[0].id
            let temp = decoderData.main.temp
            let name = decoderData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
           // print(weather.getConditionName(weatherId: id))
            //print(weather.temperatureString)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
