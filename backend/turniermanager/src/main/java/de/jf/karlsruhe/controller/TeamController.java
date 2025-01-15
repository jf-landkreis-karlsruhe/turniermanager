package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Team;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.TeamRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/turniersetup")
public class TeamController {

    @Autowired
    private TeamRepository teamRepository;
    
    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @PostMapping("/team")
    public ResponseEntity<Team> createTeam(@RequestBody Team team) {
        AgeGroup ageGroup = team.getAgegroup();
        AgeGroup savedAgeGroup = ageGroupRepository.save(ageGroup);
        team.setAgegroup(savedAgeGroup);
        Team savedTeam = teamRepository.save(team);
        return ResponseEntity.ok(savedTeam);
    }
    
    @DeleteMapping("/team/{id}")
    public ResponseEntity<Void> deleteTeam(@PathVariable Long id) {
        if (teamRepository.existsById(id)) {
            teamRepository.deleteById(id);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

}
