

defmodule Alumno do
  def crear_alumno(nombre, lista) do
    spawn_link(fn -> init(nombre,lista) end)
  end

  def init(nombre,lista) do
    send lista, {self, :alumno, nombre}
    loop({nombre,[]})
  end


  def loop({nombre,consultas}) do
    receive do

      {pid, :ok } ->
          send pid, {self, :preguntar, "que hora es?"}
          loop({nombre,consultas})

      {_, :consulta, _ } ->
          loop({nombre,consultas})

      {pid, :respuesta, id, consulta} ->
          :timer.sleep(2000)
          send pid, {self, :preguntar, "que hora es?"}
          loop({nombre,consultas})


    end
  end

end
