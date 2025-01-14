package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turniersetup")
public class AgeGroupController {

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @PostMapping("/agegroup")
    public ResponseEntity<AgeGroup> createAgeGroup(@RequestBody AgeGroup ageGroup) {
        AgeGroup savedAgeGroup = ageGroupRepository.save(ageGroup);
        return ResponseEntity.ok(savedAgeGroup);
    }
}
