package br.unisc.api_iot.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import br.unisc.api_iot.model.LDRSensor;
import org.springframework.stereotype.Repository;

@Repository
public interface LDRRepository extends JpaRepository<LDRSensor, Integer> {
    
}
