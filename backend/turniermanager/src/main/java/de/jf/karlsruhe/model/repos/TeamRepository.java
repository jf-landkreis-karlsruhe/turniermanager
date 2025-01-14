package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.Team;

public interface TeamRepository extends JpaRepository<Team, Long>{

}
