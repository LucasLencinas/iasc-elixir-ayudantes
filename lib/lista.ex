

defmodule Lista do
  def crear_lista do
    spawn_link(fn -> loop({[],[],Map.new,1}) end)
  end

  def loop({alumnos,docentes,consultas, next_id}) do
    IO.puts "id_consulta: " <> Integer.to_string(next_id)
    receive do

      {pid, :alumno, nombre } ->
          send pid, {self, :ok}
          loop({alumnos ++ [{pid,nombre}],docentes, consultas, next_id})

      {pid, :docente, nombre } ->
          send pid, {self, "docente guardado"}
          loop({alumnos,docentes ++ [{pid,nombre}], consultas, next_id})

      {pid, :preguntar, pregunta } ->
          IO.puts "pregunta: " <> pregunta
          broadcast(pids_of(alumnos ++ docentes), {self, :consulta,{next_id, pid, pregunta}})
          loop({alumnos, docentes,
                Map.put(consultas, next_id, {pid,pregunta, nil}),
                next_id + 1 })

      {pid, :respondiendo, id_consulta } ->
          broadcast(pids_of(docentes),{self,:respondiendo, id_consulta, pid})
          IO.puts "respondiendo: " <> Integer.to_string(id_consulta)
          loop({alumnos, docentes,consultas,next_id})

      {pid, :responder,id_consulta, respuesta } ->

          IO.puts "respuesta: " <> respuesta
          case Map.get(consultas, id_consulta) do
            {alumno,pregunta,nil} ->
              consulta = {alumno, pregunta, respuesta}
              broadcast(pids_of(alumnos ++ docentes),{self,:respuesta, id_consulta, consulta})
              loop({alumnos, docentes,
                    Map.put(consultas, id_consulta, consulta),
                    next_id})
            _ ->
              IO.puts "Ya respondieron"
              loop({alumnos, docentes,consultas,next_id})

          end

      {pid, :consultas} ->
        send pid, consultas
        loop({alumnos,docentes, consultas, next_id})

    end
  end

  def pids_of(list) do
    Enum.map(list, fn({pid,_}) -> pid end)
  end

  def broadcast(pids, message) do
    Enum.each(pids, fn(pid) -> send pid, message end)
  end

end
