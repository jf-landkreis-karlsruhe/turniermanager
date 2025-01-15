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

    @DeleteMapping("/agegroup/{id}")
    public ResponseEntity<Void> deleteAgeGroup(@PathVariable Long id) {
        if (ageGroupRepository.existsById(id)) {
            ageGroupRepository.deleteById(id);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
