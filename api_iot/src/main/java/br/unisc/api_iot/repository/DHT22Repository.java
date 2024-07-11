package br.unisc.api_iot.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import br.unisc.api_iot.model.DHT22Sensor;

public interface DHT22Repository extends JpaRepository<DHT22Sensor, Integer>{
    
}
