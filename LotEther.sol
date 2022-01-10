// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract LotEther {

  // Lista de jugadores que participan en la lotería
  address payable[] public jugadores;
  address payable public admin;
  
  // msg.sender es la llave pública o el address de la persona que lanza el contrato
  constructor() {
      admin = payable(msg.sender);
      jugadores.push(payable(admin));
  }
  
  // Recibe el pago necesario para participar en la lotería
  receive() external payable {
  
      // La cantidad requerida para participar es 0.001 ether
      require(msg.value == 0.001 ether , "Cantidad incorrecta");
      
      // El administrador no puede participar en la lotería
      require(msg.sender != admin , "El administrador no puede participar");
      
      // Si se realiza el pago correcto, el jugador es incluído en la lista
      jugadores.push(payable(msg.sender));
  }
  
  // Devuelve el balance del contrato
  function consultarBalance() public view returns(uint) {
      return address(this).balance;
  }
  
  // Devuelve un entero aleatorio
  function numAleatorio() internal view returns(uint) {
      return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, jugadores.length)));
  }
  
  // Devuelve el ganador de la lotería y realiza el pago del premio
  function pickWinner() public {
  
      // Sólo el administrador puede llamar a esta función
      require( admin == msg.sender , "No eres el administrador");
      
      // Requiere que haya por lo menos 1000 participantes
      require( jugadores.length >= 1000 , "No hay suficientes participantes");
      
      address payable ganador;
      ganador = jugadores[numAleatorio() % jugadores.length];
      
      // Paga el premio al ganador y una comisión del 5% para el administrador
      ganador.transfer( (consultarBalance() * 95) / 100);
      payable(admin).transfer( (consultarBalance() * 5) / 100);
  }
  
  // Resetea el juego
  function reset() internal {
      jugadores = new address payable[](0);
  }
  
