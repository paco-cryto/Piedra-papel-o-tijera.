math.randomseed(os.time() + math.floor(os.clock() * 1000000))
math.random()
math.random()

local JUGADAS_INICIALES <const> = 15
local MAX_REPETICIONES <const> = 255

local opciones <const> = { "piedra", "papel", "tijera" }
local ganaA <const> = {
  piedra = "tijera",
  papel = "piedra",
  tijera = "papel"
}
-- Qué jugada pierde frente a la elección del jugador:
local pierdeContra <const> = {
  piedra = "tijera",
  papel = "piedra",
  tijera = "papel"
}

local palabrasValidas <const> = {
  ["piedra"] = true,
  ["papel"] = true,
  ["tijera"] = true,
  ["PIEDRA"] = true,
  ["PAPEL"] = true,
  ["TIJERA"] = true
}

local function elegirMaquina(jugadaMinuscula)
  if math.random() < 0.70 then
    return pierdeContra[jugadaMinuscula]
  else
    return opciones[math.random(#opciones)]
  end
end

local function pedirReiniciar()
  while true do
    io.write("\n¿Quieres jugar de nuevo? (s/n): ")
    local resp = io.read()
    if not resp then
      return false
    end
    local limpia = resp:lower():gsub("%s+", "")
    if limpia == "s" or limpia == "si" or limpia == "sí" then
      return true
    elseif limpia == "n" or limpia == "no" then
      return false
    else
      print("Responde con 's' para sí o 'n' para no.")
    end
  end
end

local repeticion = 1
local limiteJugadas = JUGADAS_INICIALES

print("=== PIEDRA, PAPEL O TIJERA (Lua 5.4.8) ===")
print("Escribe: piedra, papel, tijera o PIEDRA, PAPEL, TIJERA (o 'salir').")

while true do
  local puntosJugador = 0
  local puntosMaquina = 0
  local jugadas = 0

  print(string.format("\n--- REPETICIÓN #%d/%d | Jugadas de esta partida: %d ---", repeticion, MAX_REPETICIONES, limiteJugadas))

  while jugadas < limiteJugadas do
    io.write(string.format("[Jugada %d/%d] Tu elección: ", jugadas + 1, limiteJugadas))
    local entrada = io.read()

    if not entrada then
      break
    end

    local limpia = entrada:gsub("%s+", "")

    if limpia == "salir" or limpia == "SALIR" then
      break
    end

    jugadas = jugadas + 1

    if not palabrasValidas[limpia] then
      puntosJugador = puntosJugador - 1
      print("Penalización: solo vale todo en minúsculas o todo en MAYÚSCULAS. (-1 punto)")
      print(string.format("Marcador -> Tú: %d | Máquina: %d\n", puntosJugador, puntosMaquina))
    else
      local jugador = limpia:lower()
      local maquina = elegirMaquina(jugador)
      print("La máquina eligió: " .. maquina)

      if jugador == maquina then
        print("Resultado: Empate.")
      elseif ganaA[jugador] == maquina then
        puntosJugador = puntosJugador + 1
        print("Resultado: Ganaste esta jugada.")
      else
        puntosMaquina = puntosMaquina + 1
        print("Resultado: Perdiste esta jugada.")
      end

      print(string.format("Marcador -> Tú: %d | Máquina: %d\n", puntosJugador, puntosMaquina))
    end
  end

  print("=== RESULTADOS DE LA REPETICIÓN " .. repeticion .. " ===")
  print(string.format("Jugadas completadas: %d/%d", jugadas, limiteJugadas))
  print(string.format("Puntos finales -> Tú: %d | Máquina: %d", puntosJugador, puntosMaquina))

  if puntosJugador > puntosMaquina then
    print("Ganaste la partida. La máquina perdió.")
  elseif puntosMaquina > puntosJugador then
    print("Tú perdiste la partida. La máquina ganó.")
  else
    print("Empate total en puntos.")
  end

  if repeticion >= MAX_REPETICIONES then
    print(string.format("\nLlegaste a la repetición número %d. La partida termina aquí.", MAX_REPETICIONES))
    if pedirReiniciar() then
      repeticion = 1
      limiteJugadas = JUGADAS_INICIALES
      print("Reiniciando desde el principio (Repetición 1 con 15 jugadas)...")
    else
      break
    end
  else
    if pedirReiniciar() then
      repeticion = repeticion + 1
      limiteJugadas = limiteJugadas + 1
    else
      break
    end
  end
end

print("\n=== FIN ===")
