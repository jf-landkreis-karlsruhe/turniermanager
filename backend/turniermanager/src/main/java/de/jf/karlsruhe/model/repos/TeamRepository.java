package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.Team;

import java.util.List;
import java.util.UUID;

public interface TeamRepository extends JpaRepository<Team, UUID>{
        List<Team> findByAgeGroupId(UUID ageGroupId);
}
