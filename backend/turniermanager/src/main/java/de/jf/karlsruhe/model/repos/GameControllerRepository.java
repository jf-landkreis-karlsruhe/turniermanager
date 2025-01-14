package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.game.GameControll;

public interface GameControllerRepository extends JpaRepository<GameControll, Long>{

}
