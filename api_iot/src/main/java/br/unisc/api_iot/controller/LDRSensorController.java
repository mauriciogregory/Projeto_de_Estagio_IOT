package br.unisc.api_iot.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.unisc.api_iot.model.LDRSensor;
import br.unisc.api_iot.repository.LDRRepository;

@RestController
@RequestMapping("/api")
public class LDRSensorController {

    @Autowired
    private LDRRepository ldrRepository;

    @GetMapping("/ldr")
    public List<LDRSensor> getLDRSensorData() {
        return ldrRepository.findAll();
    }

    @PostMapping("/ldr")
    public LDRSensor postLDRData(@RequestBody LDRSensor ldrSensor) {
        ldrRepository.save(ldrSensor);
        return ldrSensor;
    }
    
}