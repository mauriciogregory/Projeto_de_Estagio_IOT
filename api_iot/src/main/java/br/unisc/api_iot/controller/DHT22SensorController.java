package br.unisc.api_iot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.unisc.api_iot.model.DHT22Sensor;
import br.unisc.api_iot.repository.DHT22Repository;

@RestController
@RequestMapping("/api")
public class DHT22SensorController {

    @Autowired
    private DHT22Repository dht22Repository;
    
    @GetMapping("/dht22")
    public List<DHT22Sensor> getDHT22SensorData(){
        return dht22Repository.findAll();
    }

    @PostMapping("/dht22")
    public DHT22Sensor postDHT22Data(@RequestBody DHT22Sensor dht22Sensor) {
        dht22Repository.save(dht22Sensor);
        return dht22Sensor;
    }

}
