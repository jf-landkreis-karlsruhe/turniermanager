package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.Round;
import de.jf.karlsruhe.model.repos.RoundRepository;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turniersetup")
public class RoundController {

    @Autowired
    private RoundRepository roundRepository;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @PostMapping("/round")
    public ResponseEntity<Round> createRound(@RequestBody Round round) {
        if (round.getAgeGroup() != null && ageGroupRepository.existsById(round.getAgeGroup().getId())) {
            Round savedRound = roundRepository.save(round);
            return ResponseEntity.ok(savedRound);
        }
        return ResponseEntity.badRequest().build();
    }

    @DeleteMapping("/round/{id}")
    public ResponseEntity<Void> deleteRound(@PathVariable Long id) {
        if (roundRepository.existsById(id)) {
            roundRepository.deleteById(id);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
