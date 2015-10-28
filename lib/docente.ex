

defmodule Docente do
  def crear_docente(nombre, lista) do
    spawn_link(fn -> init(nombre,lista) end)
  end

  def init(nombre,lista) do
    send lista, {self, :docente, nombre}
    loop({nombre,[]})
  end


  def loop({nombre,consultas}) do
    receive do

      {pid, :ok } ->
          loop({nombre,consultas})

      {pid,:consulta, {id_consulta, alumno, pregunta} } ->
          send pid, {self, :respondiendo, id_consulta}
          :timer.sleep(2000)
          send pid, {self, :responder,id_consulta, "son las 10:00"}
          loop({nombre,consultas})

      {pid,:respondiendo, id_consulta, docente } ->
          loop({nombre,consultas})

      {pid, :respuesta, id, consulta} ->
          loop({nombre,consultas})


    end
  end

end
