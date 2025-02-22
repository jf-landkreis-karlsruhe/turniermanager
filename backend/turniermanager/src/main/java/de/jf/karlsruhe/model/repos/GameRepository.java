package de.jf.karlsruhe.model.repos;

import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Round;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GameRepository extends JpaRepository<Game, UUID> {
    List<Game> findByRound(Round round);

    List<Game> findByPitchId(UUID pitchId);

    Optional<Game> findByGameNumber(long gameNumber);
}
