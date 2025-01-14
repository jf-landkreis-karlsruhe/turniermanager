package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.game.GameSettings;

public interface GameSettingsRepository extends JpaRepository<GameSettings, Long> {

}
