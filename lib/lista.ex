

defmodule Lista do
  def crear_lista do
    spawn_link(fn -> loop({[],[],Map.new,1}) end)
  end

  def loop({alumnos,docentes,consultas, id_consulta}) do
    receive do

      {pid, :alumno, nombre } ->
          send pid, {self, :ok}
          loop({alumnos ++ [{pid,nombre}],docentes, consultas, id_consulta})

      {pid, :docente, nombre } ->
          send pid, {self, "docente guardado"}
          loop({alumnos,docentes ++ [{pid,nombre}], consultas, id_consulta})

      {pid, :preguntar, pregunta } ->
          IO.puts "pregunta: " <> pregunta
          broadcast(pids_of(alumnos ++ docentes), {self, :consulta,{id_consulta, pid, pregunta}})
          loop({alumnos, docentes,
                Map.put(consultas, id_consulta, {pid,pregunta, nil}),
                id_consulta + 1 })

      {pid, :respondiendo, id_consulta } ->
          broadcast(pids_of(docentes),{self,:respondiendo, id_consulta, pid})
          IO.puts "respondiendo: " <> Integer.to_string(id_consulta)
          loop({alumnos, docentes,consultas,id_consulta})

      {pid, :responder,id_consulta, respuesta } ->
          IO.puts "respuesta: " <> respuesta
          {alumno,pregunta,_} = Map.get(consultas, id_consulta)
          consulta = {alumno, pregunta, respuesta}
          broadcast(pids_of(alumnos ++ docentes),{self,:respuesta, id_consulta, consulta})
          loop({alumnos, docentes,
                Map.put(consultas, id_consulta, consulta),
                id_consulta})

      {pid, :consultas} ->
        send pid, consultas
        loop({alumnos,docentes, consultas, id_consulta})

    end
  end

  def pids_of(list) do
    Enum.map(list, fn({pid,_}) -> pid end)
  end

  def broadcast(pids, message) do
    Enum.each(pids, fn(pid) -> send pid, message end)
  end

end
