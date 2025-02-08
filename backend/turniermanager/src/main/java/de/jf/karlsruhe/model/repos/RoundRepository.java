package de.jf.karlsruhe.model.repos;

import de.jf.karlsruhe.model.base.League;
import de.jf.karlsruhe.model.base.Round;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface RoundRepository extends JpaRepository<Round, UUID> {
    List<Round> findByLeague(League league);
}
