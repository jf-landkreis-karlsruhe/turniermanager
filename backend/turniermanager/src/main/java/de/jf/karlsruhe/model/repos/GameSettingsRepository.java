package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;


public interface GameSettingsRepository extends JpaRepository<de.jf.karlsruhe.model.base.GameSettings, UUID> {

}
