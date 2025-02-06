package de.jf.karlsruhe.model.repos;

import de.jf.karlsruhe.model.base.Game;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GameRepository extends JpaRepository<Game, Long> {
    List<Game> findByLeagueId(Long id);
}
