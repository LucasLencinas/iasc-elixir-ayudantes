import_file "./lib/lista.ex"
import_file "./lib/alumno.ex"
import_file "./lib/docente.ex"

l = Lista.crear_lista()

send l, {self, :alumno, "lucass"}
pablo = Alumno.crear_alumno("pablo", l)
zafa = Docente.crear_docente("zafa", l)


