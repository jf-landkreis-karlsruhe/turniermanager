package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.Team;

import java.util.List;

public interface TeamRepository extends JpaRepository<Team, Long>{
        List<Team> findByAgeGroupId(Long ageGroupId);
}
