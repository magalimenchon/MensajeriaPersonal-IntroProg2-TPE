Program MensajeriaPersonal;
{Este programa permite a sus usuarios crear una cuenta y comenzar a mantener conversaciones uno a uno con otros usuarios. Cada conversación contiene todos los mensajes entre los 2 usuarios. 
Un usuario puede elegir borrar su cuenta cuando lo desee, borrando toda las conversaciones en las que haya estado.}

Uses sysutils, crt;
Type 
    PArb= ^ArbUsuarios;
    ArbUsuarios= record
        nombre, password: string[8];
        menor, mayor: PArb;
    end;
    PListMens= ^ListaMens;
    ListaMens= record
        fechayhora: string;
        text: string;
        user: PArb;
        leido: boolean;
        sig: PListMens;
    end;    
    PListConvers= ^ListaConvers;
    ListaConvers= record
        cod: integer;
        user1, user2: PArb;
        mensajes: PListMens;
        sig: PListConvers;
    end;
    PListUH= ^ListUH;
    ListUH= record
        user: string[8];
        cantconvers: integer;
        sig: PListUH;
    end;    
    RegUsers= record
        nombre, password: string[8];
    end;
    RegConvers= record
        cod: integer;
        user1, user2: string[8];
    end;
    RegMens= record
        cod: integer;
        fechayhora: string;
        mens: string;
        user: string[8];
        leido: boolean;
    end;
    ArchUsuarios= File of RegUsers;
    ArchConversaciones= File of RegConvers;
    ArchMensajes= File of RegMens;
    
Function ExisteUser(arbol: PArb; nom: string): PArb;
{Esta función busca al usuario en el árbol a partir del string, y devuelve un puntero, asignado con nil si es que no existe.}
    begin
        if arbol = nil then
            ExisteUser:= nil
        else begin
            if arbol^.nombre = nom then
                ExisteUser:= arbol
            else begin
                if arbol^.nombre < nom then
                    ExisteUser:= ExisteUser(arbol^.mayor, nom)
                else
                    ExisteUser:= ExisteUser(arbol^.menor, nom);
            end;
        end;
    end;  
    
Procedure ImprimirDatosConver(lista: PListConvers; cantnoleidos: integer; userlogueado: string); 
{Este procedimiento imprime los datos pertinentes de cada conversación.}
    begin
        if ((lista^.user1^.nombre) <> (userlogueado)) then
            writeln('♦ Código: ', lista^.cod, ' |Usuario: ', lista^.user1^.nombre, ' |Cantidad de mensajes no leídos: ', cantnoleidos, '.')
        else
            writeln('♦ Código: ', lista^.cod, ' |Usuario: ', lista^.user2^.nombre, ' |Cantidad de mensajes no leídos: ', cantnoleidos, '.');
    end;
    
Function CantMensNoLeidosPorConvers(lista: PListMens; userlogueado: string): integer;
{Esta función devuelve la cantidad de mensajes no leidos de una conversación.}
    begin
        if lista <> nil then begin
            if (not lista^.leido) and (lista^.user^.nombre <> userlogueado) then
                CantMensNoLeidosPorConvers:= CantMensNoLeidosPorConvers(lista^.sig, userlogueado) +1
            else
                CantMensNoLeidosPorConvers:= CantMensNoLeidosPorConvers(lista^.sig, userlogueado);
        end
        else
            CantMensNoLeidosPorConvers:= 0;
    end;        
    
Function CantTotalMensNoLeidos(lista: PListConvers; userlogueado: string): integer; 
{Esta función devuelve la cantidad de mensajes no leídos de todas las conversaciones en las que participa el usuario.}
    begin
        if lista = nil then 
            CantTotalMensNoLeidos:= 0
        else begin
            if (lista^.user1^.nombre = userlogueado) or (lista^.user2^.nombre = userlogueado) then 
                CantTotalMensNoLeidos:= CantTotalMensNoLeidos(lista^.sig, userlogueado) +(CantMensNoLeidosPorConvers(lista^.mensajes, userlogueado))
            else
                CantTotalMensNoLeidos:= CantTotalMensNoLeidos(lista^.sig, userlogueado);
        end;
    end;  
    
Procedure ListarConversacionesActivas(lista: PListConvers; userlogueado: string);
{Este procedimiento muestra por pantalla una lista de las conversaciones en las cuales el usuario logueado posee mensajes sin leer.}
    var cantnoleidos: integer;
    begin
        if CantTotalMensNoLeidos(lista, userlogueado) = 0 then
            writeln('No tiene mensajes sin leer.')
        else begin
            if lista <> nil then begin
                if (lista^.user1^.nombre = userlogueado) or (lista^.user2^.nombre = userlogueado) then begin
                    cantnoleidos:= CantMensNoLeidosPorConvers(lista^.mensajes, userlogueado);
                    if cantnoleidos <> 0 then
                        ImprimirDatosConver(lista, cantnoleidos, userlogueado);
                end
                else 
                    ListarConversacionesActivas(lista^.sig, userlogueado);
            end;
        end;    
        readln();
    end;   

Function CantTotalConvers(lista: PListConvers; userlogueado: string): integer;
{Esta función devuelve la cantidad de conversaciones que posee el usuario.}
    begin
        if lista <> nil then begin
                if (lista^.user1^.nombre = userlogueado) or (lista^.user2^.nombre = userlogueado) then 
                    CantTotalConvers:= CantTotalConvers(lista^.sig, userlogueado) +1
                else
                    CantTotalConvers:= CantTotalConvers(lista^.sig, userlogueado);
        end
        else
            CantTotalConvers:= 0;
    end;        
    
Procedure MostrarDatosMenu2(lista: PListConvers; nom: string);
{Este procedimiento muestra los datos del usuario cada vez que se accede al menú 2.}
    begin
        writeln('Usuario: ',nom);
        writeln('Cantidad de mensajes no leídos: ', CantTotalMensNoLeidos(lista, nom));
        writeln('Cantidad total de conversaciones: ', CantTotalConvers(lista, nom));
    end; 

Procedure TodasLasConversaciones(lista: PListConvers; userlogueado: string);
{Este procedimiento imprime un listado con los códigos y nombres de usuarios de las conversaciones en las que participa el usuario logueado.}
    begin
        if lista = nil then begin
            writeln(' ');
            writeln('No tiene conversaciones.');
        end;
        while lista <> nil do begin
            if (lista^.user1^.nombre = userlogueado) or (lista^.user2^.nombre = userlogueado) then begin
                if lista^.user1^.nombre = userlogueado then 
                    writeln('♦ ', 'cod: ', lista^.cod, ', ', lista^.user2^.nombre)
                else 
                    writeln('♦ ', 'cod: ', lista^.cod, ', ', lista^.user1^.nombre);
            end;        
            lista:= lista^.sig;
        end;
        readln();
    end; 
    
Function ExisteConvers(lista: PListConvers; userlogueado, nombre: string): PListConvers;
{Esta función devulve un puntero a una conversación si ésta existe. De lo contrario devuelve el puntero en nil.}
    begin
        ExisteConvers:= nil;
        if lista <> nil then begin
            if ((lista^.user1^.nombre = userlogueado) and (lista^.user2^.nombre = nombre)) or
                ((lista^.user1^.nombre = nombre) and (lista^.user2^.nombre = userlogueado)) then
                    ExisteConvers:= lista
            else
                ExisteConvers:= ExisteConvers(lista^.sig, userlogueado, nombre);
        end;        
    end;
    
Procedure InsertarConvers(var plista: PListConvers; nombre, userlogueado: string; arbol: PArb; codigo: integer);
{Este procedimiento crea una nueva conversación en la lista.}
    begin
        new(plista);
        plista^.cod:= codigo;
        plista^.mensajes:= nil;
        plista^.user1:= ExisteUser(arbol, userlogueado);
        plista^.user2:= ExisteUser(arbol, nombre);
        plista^.sig:= nil;
    end;
    
Procedure NuevaConversacion(arbol: PArb; var lista: PListConvers; userlogueado: string);
{Este procedimiento crea nuevas conversaciones, controlando que no hayan sido creadas previamente. A todas las conversaciones
se les asigna un código a partir de la última conversación creada. Por lo tanto, si un usuario crea una conversación y luego
es eliminado, a menos de que esté al final de la lista, su código no volverá a ser utilizado.}
    var nombre: string[8]; codigo: integer; cursor, aux: PListConvers; sigue: string;
    begin
        sigue:= 'si';
        codigo:= 1;
        cursor:= lista;
        aux:= nil;
        while sigue = 'si' do begin
            write('Ingrese el nombre del usuario con el que quiere iniciar una nueva conversación.');
            readln(nombre);
            if  (ExisteUser(arbol, nombre) <> nil) then begin
                if lista = nil then begin
                    InsertarConvers(lista, nombre, userlogueado, arbol, codigo);
                    sigue:= 'no';
                    write('Su conversación fue creada con éxito. Código: ', codigo, '.');
                    readln();
                end    
                else begin
                    if  (ExisteConvers(lista, userlogueado, nombre) = nil) then begin
                        while not (cursor = nil) do begin
                            codigo:= cursor^.cod;
                            aux:= cursor;
                            cursor:= cursor^.sig;
                        end;
                        InsertarConvers(cursor, nombre, userlogueado, arbol, (codigo +1));
                        aux^.sig:= cursor;
                        sigue:= 'no';
                        write('Su conversación fue creada con éxito. Código: ', (codigo +1), '.');
                        readln();
                    end    
                    else begin
                        writeln('Ya tiene una conversación con ', nombre, '.'); 
                        writeln('Si desea elegir otro usuario ingrese "si", de lo contrario, ingrese "no".');
                        readln(sigue);
                    end;    
                end;        
            end
            else begin
                writeln('El nombre de usuario que ingresó no existe.'); 
                writeln('Si desea elegir otro usuario ingrese "si", de lo contrario, ingrese "no".');
                readln(sigue);
            end;
        end;
    end;    
 
Procedure EliminarMens(var lista: PListMens);
{Este procedimiento elimina la lista de mensajes.}
    begin
        if lista <> nil then begin
            if (lista^.sig = nil) then begin
                lista^.user:= nil;
                dispose(lista);
                lista:= nil;
            end    
            else
                EliminarMens(lista^.sig);
        end;        
    end;        
    
Procedure EliminarConvers(var lista: PListConvers; userlogueado: string);
{Este procedimiento elimina las conversaciones en las que participa el usuario.}
    var cursor, aux: PListConvers;
    begin
        cursor:= lista;
        aux:= nil;
        while (cursor <> nil) do begin
            if (cursor^.user1^.nombre <> userlogueado) and (cursor^.user2^.nombre <> userlogueado) then begin
                aux:= cursor;
                cursor:= cursor^.sig;
            end
            else begin
                EliminarMens(cursor^.mensajes);
                cursor^.mensajes:= nil;
                if cursor = lista then begin
                    lista:= lista^.sig;
                    cursor^.user1:= nil;
                    cursor^.user2:= nil;
                    dispose(cursor);
                    cursor:= lista;

                end
                else begin
                    aux^.sig:= cursor^.sig;
                    cursor^.user1:= nil;
                    cursor^.user2:= nil;
                    dispose(cursor);
                    cursor:= aux^.sig;
                end;
            end;
        end;
    end;
    
Procedure EliminarHoja(var arbol: PArb; nodouser: PArb);
{Este procedimiento forma parte del módulo de eliminar un usuario en el árbol, y se encarga de eliminarlo en el caso en que éste
sea una hoja.}
    begin
        if (arbol^.menor = nodouser) then begin
            arbol^.menor:= nil;
            dispose(nodouser);
        end    
        else begin    
            if (arbol^.mayor = nodouser) then begin
                arbol^.mayor:= nil;
                dispose(nodouser);
            end    
            else begin
                if arbol^.nombre < nodouser^.nombre then
                    EliminarHoja(arbol^.mayor, nodouser)
                else
                    EliminarHoja(arbol^.menor, nodouser);
            end;
        end;
    end;
    
Procedure EliminarNoHoja(var arbol: PArb; nodouser: PArb);
{Este procedimiento forma parte del módulo de eliminar un usuario en el árbol, y se encarga de eliminarlo en el caso en 
que éste no sea una hoja.}
    var aux, aux2: PArb;
    begin
        aux:= nil;
        aux2:= nil;
        if (nodouser^.mayor = nil) and (nodouser^.menor <> nil) then begin
            nodouser^.nombre:= nodouser^.menor^.nombre;
            nodouser^.password:= nodouser^.menor^.password;
            nodouser^.mayor:= nodouser^.menor^.mayor;
            nodouser^.menor:= nodouser^.menor^.menor;
        end;
        if (nodouser^.mayor <> nil) and (nodouser^.menor = nil) then begin
            nodouser^.nombre:= nodouser^.mayor^.nombre;
            nodouser^.password:= nodouser^.mayor^.password;
            nodouser^.menor:= nodouser^.mayor^.menor;
            nodouser^.mayor:= nodouser^.mayor^.mayor;
        end;
        if (nodouser^.mayor <> nil) and (nodouser^.menor <> nil) then begin
            aux:= nodouser^.menor;
            while not (aux^.mayor = nil) do begin
                aux2:= aux;
                aux:= aux^.mayor;
            end;
            nodouser^.nombre:= aux^.nombre;
            nodouser^.password:= aux^.password;
            if aux2 <> nil then
                aux2^.mayor:= nil
            else
                nodouser^.menor:= aux^.menor;
            dispose(aux);
        end;
    end;
    
Procedure EliminarUsuario(var arbol: PArb; userlogueado: string);
{Este procedimiento elimina un usuario del árbol.}
    var nodouser: PArb;
    begin
        nodouser:= ExisteUser(arbol, userlogueado);
        if nodouser <> nil then begin
            if (nodouser^.mayor = nil) and (nodouser^.menor = nil) then begin {En caso en que exista sólo la raiz.}
                if nodouser = arbol then begin
                    dispose(arbol);
                    arbol:= nil;
                end
                else
                    EliminarHoja(arbol, nodouser)
            end        
            else
                EliminarNoHoja(arbol, nodouser);
        end;
    end;    

Procedure BorrarUsuario(var arbol: PArb; userlogueado: string; var lista: PListConvers; var opcion: integer);
{Este procedimiento borra un usuario, eliminándolo del árbol y borrando todas sus conversaciones con sus respectivos mensajes.}
    begin
        if CantTotalMensNoLeidos(lista, userlogueado) = 0 then begin
            EliminarConvers(lista, userlogueado);
            EliminarUsuario(arbol, userlogueado);
        end
        else begin
            writeln('No se puede eliminar el usuario porque posee mensajes no leídos.');
            opcion:= 1; 
            readln();
        end;    
    end;        

Function NuevoMensaje(userlogueado: string; arbol: PArb): PListMens;
{Esta función crea el nodo del nuevo mensaje, devolviendo el puntero.}
    var
        nodo: PListMens;
    begin
        new(nodo);
        writeln('Escriba un mensaje:');
        readln(nodo^.text);
        nodo^.user:= ExisteUser(arbol, userlogueado);
        nodo^.leido:= false;
        nodo^.fechayhora:= DateTimeToStr(Now);
        nodo^.sig:= nil;
        NuevoMensaje:= nodo;
    end;

Procedure MostrarMensajes(ListaMens: PListMens; cantope: integer; userlogueado: string);
{Este procedimiento muestra por pantalla una cantidad determinada de mensajes.}
    begin
        if ListaMens <> nil then begin
            if (cantope >= 1) then begin
                MostrarMensajes(ListaMens^.sig, (cantope -1), userlogueado);
                if (ListaMens^.user^.nombre <> userlogueado) and not (ListaMens^.leido) then
                    ListaMens^.leido:= true;
                writeln('<', ListaMens^.fechayhora, '> <', ListaMens^.user^.nombre, '>');
                if ListaMens^.leido then
                    writeln('        ✉  ', ListaMens^.text,  '   ✔ Leido');
                if not ListaMens^.leido then
                    writeln('        ✉  ', ListaMens^.text,  '    No Leido');
            end;
        end;
    end;

Procedure InsertarNuevoMensaje(var ListMens: PListMens; mensnuevo: PListMens);
{Este procedimiento agrega el nodo de nuevo mensaje a la lista, manteniéndola ordenada por fecha y hora, desde la más actual
a la más antigua.}
    begin
        if ListMens <> nil then
            mensnuevo^.sig:= ListMens;
        ListMens:= mensnuevo;
    end;

Procedure ContestarMensaje(ListaConvers: PlistConvers; userlogueado: string; arbol: PArb);
{Este procedimiento permite al usuario enviar un mensaje a partir del código de conversación de la misma.}
    var siga: string; cod, topemostrarmens: integer;
    begin
        siga:= 'si';
        topemostrarmens:= 5;
        writeln('Ingrese el código de conversación.');
        readln(cod);
        while (ListaConvers <> nil) and (ListaConvers^.cod <> cod) do
            ListaConvers:= ListaConvers^.sig;
        if ListaConvers = nil then
            writeln('No existe la conversación.')
        else begin
            if (ListaConvers^.user1^.nombre = userlogueado) or (ListaConvers^.user2^.nombre = userlogueado) then begin
                if ListaConvers^.mensajes <> nil then
                    MostrarMensajes(ListaConvers^.mensajes, topemostrarmens, userlogueado);
                while (siga = 'si') do begin
                    InsertarNuevoMensaje(ListaConvers^.mensajes, NuevoMensaje(userlogueado, arbol));
                    writeln('Si desea seguir creando nuevos mensajes, ingrese "si".'); 
                    writeln('De lo contrario ingrese "no".');
                    readln(siga);
                end;
            end
            else writeln('Usted no participa de la conversación. Imposible escribir mensaje.');
        end;
        readln();
    end;
    
Procedure VerConversacion(lista: PListConvers; userlogueado: string);
{Este procedimiento muestra todos los mensajes de una conversación.}
    var cod: integer;
    begin
        writeln('Ingrese el código de conversación.');
        readln(cod);
        while (lista <> nil) and (lista^.cod <> cod) do
            lista:= lista^.sig;
        if lista = nil then
            writeln('La conversación no existe.')
        else begin
            if lista^.mensajes = nil then
                writeln('La conversación no posee mensajes.')
            else    
                MostrarMensajes(lista^.mensajes, 20000, userlogueado); {Se envia un tope por default.}
        end;
        readln();
    end;
    
Procedure UltimosMensajes(lista: PListConvers; userlogueado: string);
{Este procedimiento muestra los últimos 10 mensajes no leídos. Si hay más de 10, muestra todos los mensajes no leídos;
si hay menos, muestra los no leídos completando con leídos.}
    var cod: integer;
    begin
        writeln('Ingrese el código de conversación.');
        readln(cod);
        while (lista <> nil) and (lista^.cod <> cod) do
            lista:= lista^.sig;
        if lista = nil then
            writeln('La conversación no existe.')
        else begin
            if lista^.mensajes = nil then
                writeln('La conversación no posee mensajes.')
            else begin
                if CantMensNoLeidosPorConvers(lista^.mensajes, userlogueado) <= 10 then
                    MostrarMensajes(lista^.mensajes, 10, userlogueado)
                else 
                    MostrarMensajes(lista^.mensajes, CantMensNoLeidosPorConvers(lista^.mensajes, userlogueado), userlogueado);
            end;
        end;
        readln();
    end;    
                
Procedure EjecutarMenu2(var arbol: PArb; var lista: PListConvers; nom: string);
{Este procedimiento permite la ejecución de todos los módulos pertenecientes al segundo nivel del menú, a partir de la variable
opción ingresada por el usuario de acuerdo con lo que quiera realizar. En los casos en que el usuario elija la opción de logout,
se retorna al nivel 1. Si no tiene mensajes no leídos y decide borrar su cuenta, también regresa. En todos los demás casos, se queda
en el nivel 2.}
    var opcion: integer;
    begin
        opcion:= 1;
        while (opcion <> 8) and (opcion <> 7) do begin
            clrscr();
            MostrarDatosMenu2(lista, nom);
            writeln(' ');
            writeln('Menu 2:');
            writeln('1|Conversaciones activas');
            writeln(' ');
            writeln('2|Todas las conversaciones');
            writeln(' ');
            writeln('3|Últimos mensajes');
            writeln(' ');
            writeln('4|Ver conversación');
            writeln(' ');
            writeln('5|Contestar mensaje/Nuevo Mensaje');
            writeln(' ');
            writeln('6|Nueva conversación');
            writeln(' ');
            writeln('7|Borrar usuario');
            writeln(' ');
            writeln('8|Logout');
            writeln(' ');
            writeln('Para seleccionar una opción del menú, ingrese el número asociado.');
            readln(opcion);
            case opcion of
                1: ListarConversacionesActivas(lista, nom);
                2: TodasLasConversaciones(lista, nom);
                3: UltimosMensajes(lista, nom);
                4: VerConversacion(lista, nom); 
                5: ContestarMensaje(lista, nom, arbol);
                6: NuevaConversacion(arbol, lista, nom);
                7: BorrarUsuario(arbol, nom, lista, opcion);
                8: ;
            end;
        end;
    end;

Procedure GuardarDatosUsuarios(var ArchUsuar: ArchUsuarios; Arbol: PArb);
{Este procedimiento archiva todos los usuarios del árbol.}
    var recnodo: RegUsers;
    begin
        if (Arbol <> nil) then begin
            recnodo.nombre := Arbol^.nombre;
            recnodo.password := Arbol^.password;
            Write(ArchUsuar, recnodo);
            GuardarDatosUsuarios(ArchUsuar, Arbol^.menor);
            GuardarDatosUsuarios(ArchUsuar, Arbol^.mayor);
        end;
    end;

Procedure GuardarDatosMensajes(var ArchMens: ArchMensajes; mensajes: PListMens; codigo: integer);
{Este procedimiento archiva todos los mensajes del sistema.}
    var rec: RegMens;
    begin
        if mensajes <> nil then begin
            rec.cod:= codigo;
            rec.user:= mensajes^.user^.nombre;
            rec.mens:= mensajes^.text;
            rec.leido:= mensajes^.leido;
            rec.fechayhora:= mensajes^.fechayhora;
            write(ArchMens, rec);
            GuardarDatosMensajes(ArchMens, mensajes^.sig, codigo);
        end;
    end;
   
Procedure GuardarDatosConversaciones(var ArchConvers: ArchConversaciones; Convers: PListConvers; var ArchMens: ArchMensajes);
{Este procedimiento archiva todas las conversaciones.}
    var recnodo: RegConvers;
    begin
        while (Convers <> nil) do begin
            GuardarDatosMensajes(ArchMens, Convers^.mensajes, Convers^.cod);
            recnodo.cod := Convers^.cod;
            recnodo.user1 := Convers^.user1^.nombre;
            recnodo.user2 := Convers^.user2^.nombre;
            write(ArchConvers, recnodo);
            Convers:= Convers^.sig;
        end;
    end;

Procedure BorrarDatosEstructuras(var arbol: PArb; var lista: PListConvers);
{Este procedimiento borra todos los datos de las estructuras, para volver a iniciarlas desde cero en una nueva ejecución del programa.}
    begin
        if arbol <> nil then begin
            BorrarDatosEstructuras(arbol^.menor, lista);
            BorrarDatosEstructuras(arbol^.mayor, lista);
            EliminarConvers(lista, arbol^.nombre);
            dispose(arbol);
            arbol:= nil;
        end;
    end;
    
Procedure Salir(var Arbol: PArb; var Convers: PListConvers; var ArchUs: ArchUsuarios; var ArchCon: ArchConversaciones; var ArchMen: ArchMensajes);
{Este procedimiento se lleva a cabo cuando termina de ejecutar el programa, y almacena todos los datos del sistema.}
   begin
        assign(ArchUs, '/ip2/AsUsuariosMMyDMP');
        assign(ArchCon, '/ip2/AsConversMMyDMP');
        assign(ArchMen, '/ip2/AsMensajesMMyDMP');
        rewrite(ArchUs);
        rewrite(ArchCon);
        rewrite(ArchMen);
        GuardarDatosUsuarios(ArchUs, Arbol);
        GuardarDatosConversaciones(ArchCon, Convers, ArchMen);
        close(ArchUs);
        close(ArchCon);
        close(ArchMen);
        BorrarDatosEstructuras(Arbol, Convers);
    end;  
    
Function PassCorrecta(nodousuario: PArb; pass: string): boolean;
{Esta función controla que la contraseña sea correcta.}
    begin
        if nodousuario^.password = pass then
            PassCorrecta:= true
        else
            PassCorrecta:= false;
    end;
    
Function DatosCorrectos(arbol: PArb; var nom: string; pass: string; stop: integer): boolean;
{Esta función controla que se ingresen los datos correctos para realizar el login. Se le da la chance al usuario
de intentar ingresar correctamente los datos una cantidad limitada de veces a partir de la variable stop, ademas presentando 
la posibilidad de no continuar.}
    var usercorrect: PArb;
    begin
        DatosCorrectos:= false;
        while (stop >= 1) do begin
            usercorrect:= ExisteUser(arbol, nom);
            if usercorrect <> nil then begin
                if PassCorrecta(usercorrect, pass) then begin
                    DatosCorrectos:= true;
                    stop:= 0;        
                end
                else begin
                    if stop <> 1 then begin
                        stop:= stop -1;
                        writeln('Contraseña incorrecta. Ingrese nuevamente la contraseña.');
                        writeln('Le quedan ', stop, ' intentos. En caso de no querer continuar, ingrese "x".');
                        readln(pass);
                        if pass = 'x' then
                            stop:= 0;
                    end
                    else 
                        stop:= 0;
                end;
            end
            else begin
                if stop <> 1 then begin
                    stop:= stop -1;
                    writeln('El usuario ingresado no existe. Ingreselo nuevamente.');
                    writeln('Le quedan ', stop,' intentos. En caso de no querer continuar, ingrese "x".');
                    readln(nom);
                    if nom = 'x' then
                            stop:= 0;
                end
                else
                    stop:= 0
            end;    
        end;        
    end;

Procedure Login(var arbol: PArb; var lista: PListConvers);
{Este procedimiento permite al usuario ingresar al nivel 2 del menú, siempre y cuando ingrese los datos correctos.}
    var nom, pass: string[8]; stop: 0..6;
    begin
        writeln('Ingrese nombre de usuario:');
        readln(nom);
        writeln('Ingrese la contraseña:');
        readln(pass);
        stop:= 6;
        if DatosCorrectos(arbol, nom, pass, stop) then 
            EjecutarMenu2(arbol, lista, nom);
    end;

Procedure InsertarUsuario(var arbol: PArb; nom, pass: string);
{Este procedimiento inserta un nuevo usuario en el árbol.}
    begin
        if arbol = nil then begin
            New(arbol);
            arbol^.nombre := nom;
            arbol^.password:= pass;
            arbol^.menor := nil;
            arbol^.mayor := nil;
        end
        else begin
            if arbol^.nombre >= nom then
                InsertarUsuario(arbol^.menor, nom, pass)
            else
                InsertarUsuario(arbol^.mayor, nom, pass);
        end;
    end;

Procedure NuevoUsuario(var arbol: PArb);
{Este procedimiento crea un nuevo usuario, solicitando los datos correspondientes.}
    var nom, pass: string[8]; siga: string;
    begin
        siga:= 'si';
        Writeln('Ingrese el nombre del nuevo usuario. (Hasta 8 caracteres.)');
        Readln(nom);
        if ExisteUser(arbol, nom) = nil then begin
            Writeln('Ingrese una contraseña (Hasta 8 caracteres.)');
            Readln(pass);
            InsertarUsuario(arbol, nom, pass);
        end
        else begin
            writeln('El usuario ya existe. Si desea ingresar otro nombre de usuario, ingrese "si", de lo contrario ingrese "no".');
            readln(siga);
            if (siga = 'si') then begin
                writeln('Por favor, ingrese otro nombre de usuario.');
                NuevoUsuario(arbol);
            end;    
        end;
    end;

Procedure InsertarEnListaUH(var lista: PListUH; nombre: string; cant: integer);
{Este procedimiento inserta un usuario con su cantidad de conversaciones, actualizando dicha cantidad de ser necesario y
manteniendo la lista ordenada de forma descendente por cantidad de conversaciones.}
    var cursor, aux: PListUH;
    begin
        if lista = nil then begin
            new(lista);
            lista^.user:= nombre;
            lista^.cantconvers:= cant;
            lista^.sig:= nil;
        end
        else begin
            cursor:= lista;
            while (cursor <> nil) and (cursor^.cantconvers > cant) do begin
                aux:= cursor;
                cursor:= cursor^.sig;
            end;
            if cursor = nil then begin
                new(cursor);
                cursor^.user:= nombre;
                cursor^.cantconvers:= cant;
                cursor^.sig:= nil;
                aux^.sig:= cursor;
            end
            else begin
                if cursor = lista then begin
                    new(cursor);
                    cursor^.user:= nombre;
                    cursor^.cantconvers:= cant;
                    cursor^.sig:= lista;
                    lista:= cursor;
                end
                else begin
                    new(cursor);
                    cursor^.user:= nombre;
                    cursor^.cantconvers:= cant;
                    cursor^.sig:= aux^.sig;
                    aux^.sig:= cursor;
                end;    
            end;
        end;
    end;

Procedure SumarCantConvers(lista: PListConvers; var listaUH: PListUH; nombre: string);
{Este procedimiento controla la cantidad de conversaciones de un usuario que será insertado en la lista de usuarios 
hiperconectados.}
    var cantconvers: integer; 
    begin
        cantconvers:= 0;
        while (lista <> nil) do begin
            if (lista^.user1^.nombre = nombre) or (lista^.user2^.nombre = nombre) then
                cantconvers:= cantconvers +1;
            lista:= lista^.sig;
        end;
        InsertarEnListaUH(listaUH, nombre, cantconvers);
    end;    

Procedure ImprimirListaUH(lista: PListUH);
{Este procedimiento imprima la lista de usuarios hiperconectados.}
    begin
        if lista <> nil then begin
            writeln('♦ ', lista^.user, ': ', lista^.cantconvers, ' conversacion/es.');
            ImprimirListaUH(lista^.sig);
        end;
    end;

Procedure RecorrerArbol(arbol: PArb; lista: PListConvers; var listaUH: PListUH);
{Este procedimiento recorre el árbol de usuarios con el fin de generar la lista UH, a partir de cada uno.}
    begin
        if arbol <> nil then begin
            SumarCantConvers(lista, listaUH, arbol^.nombre);
            RecorrerArbol(arbol^.mayor, lista, listaUH);
            RecorrerArbol(arbol^.menor, lista, listaUH);
        end;
    end;
 
Procedure LimpiarListaUH(var lista: PListUH);
{Este procemiento limpia la lista de usuarios hiperconectados, eliminando todo su contenido luego de haberse mostrado por pantalla.}
    begin
        if lista^.sig <> nil then
            LimpiarListaUH(lista^.sig);
        if lista^.sig = nil then begin
            dispose(lista);
            lista:= nil;
        end;
    end;
    
Procedure UsuarHiperconect(arbol: PArb; lista: PListConvers; var listaUH: PListUH);
{Este procedimiento crea y muestra un listado ordenado descendentemente de todos los usuarios del sistema conforme a la 
cantidad de conversaciones que posee cada uno.}
    begin
        if arbol <> nil then begin
            RecorrerArbol(arbol, lista, listaUH);
            ImprimirListaUH(listaUH);
            LimpiarListaUH(listaUH);
        end
        else
            writeln('Todavía no hay usuarios registrados en el sistema.');
        readln();
    end;    
            
Procedure EjecutarMenu1(var arbol: PArb; var lista: PListConvers; var ArchUs: ArchUsuarios; var ArchCon: ArchConversaciones; var ArchMen:ArchMensajes); 
{Este procedimiento presenta las opciones principales del programa, permitiendo el acceso a un segundo nivel con más opciones
a partir del login. En este procedimiento termina la ejecución del programa cuando los usuarios eligen la opción salir.}
    var opcion: 1..4; listaUH: PListUH;
    begin
        listaUH:= nil;
        opcion:= 2;
        while  (opcion <> 4) do begin 
            clrscr();
            writeln('Menu 1:');
            writeln('1|Login');
            writeln(' ');
            writeln('2|Nuevo Usuario');
            writeln(' ');
            writeln('3|Usuarios Hiperconectados');
            writeln(' ');
            writeln('4|Salir');
            writeln(' ');
            writeln('Para seleccionar una opción del menú, ingrese el número asociado.');
            readln(opcion);
            case opcion of
                1: Login(arbol, lista);
                2: NuevoUsuario(arbol);
                3: UsuarHiperconect(arbol, lista, listaUH);
                4: Salir(arbol, lista, ArchUs, ArchCon, ArchMen);
            end;
        end;
    end; 
 
Procedure CargarArbol(var arbol: PArb; var ArchUs: ArchUsuarios);
{Este procedimiento carga el árbol con todos los datos almacenados en el archivo actualizado por la última ejecución.}
    var regaux: RegUsers;
    begin
        while not eof(ArchUs) do begin
            read(ArchUs, regaux);
            InsertarUsuario(arbol, regaux.nombre, regaux.password);
        end;    
    end;

Procedure CargarListConvers(var lista: PListConvers; var ArchCon: ArchConversaciones; arbol: PArb);
{Este procedimiento carga la lista de conversaciones con todos los datos almacenados en el archivo actualizado por la última ejecución.}
    var regaux: RegConvers;
    begin
        if not eof(ArchCon) then begin
            read(ArchCon, regaux);
            InsertarConvers(lista, regaux.user1, regaux.user2, arbol, regaux.cod);
            CargarListConvers(lista^.sig, ArchCon, arbol);
       end;
    end;
    
Procedure InsertarMensaje(var lista: PListMens; user: PArb; cod: integer; fyh: string; texto: string; leido: boolean);
{Este procedimiento agrega un nuevo nodo a la lista de mensajes.}
    var nodo, cursor: PListMens;
    begin
        new(nodo);
        nodo^.text:= texto;
        nodo^.user:= user;
        nodo^.leido:= leido;
        nodo^.fechayhora:= fyh;
        nodo^.sig:= nil;
        if (lista = nil) then
            lista:= nodo
        else begin
            cursor:= lista;
            while (cursor^.sig <> nil) do 
                cursor:= cursor^.sig;
            cursor^.sig:= nodo;
        end; 
    end;    
        
Procedure CargarListMens(lista: PListConvers; arbol: PArb; var ArchMen: ArchMensajes);
{Este procedimiento carga la lista de mensajes con todos los datos almacenados en el archivo actualizado por la última ejecución.}
    var regaux: RegMens; cod: integer;
    begin
        if (lista <> nil) then begin
            while not eof(ArchMen) do begin
                read(ArchMen, regaux);
                cod:= regaux.cod;
                while (lista <> nil) and (lista^.cod <> cod) do 
                    lista:= lista^.sig;
                if lista^.cod = cod then
                    InsertarMensaje(lista^.mensajes, ExisteUser(arbol, regaux.user), cod, regaux.fechayhora, regaux.mens, regaux.leido);
            end;
        end;    
    end;    

Procedure abrirArchConvers(var arch: ArchConversaciones; var error: Boolean);
{Este procedimiento abre el archivo de conversaciones permitiendo que el programa no tire error si está vacío.}
    begin
        error := false;
        {$I-} 
        reset(arch); 
        {$I+} 
        if ioresult <> 0 then  
            error := true;
    end;

Procedure abrirArchUsers(var arch: ArchUsuarios; var error: Boolean);
{Este procedimiento abre el archivo de usuarios permitiendo que el programa no tire error si está vacío.}
    begin
        error := false;
        {$I-} 
        reset(arch); 
        {$I+} 
        if ioresult <> 0 then  
            error := true;
    end;

Procedure abrirArchMens(var arch: ArchMensajes; var error: Boolean);
{Este procedimiento abre el archivo de mensajes permitiendo que el programa no tire error si está vacío.}
    begin
        error := false;
        {$I-} 
        reset(arch); 
        {$I+} 
        if ioresult <> 0 then  
            error := true;
    end;

Procedure InicializarEstructuras(var arbol: PArb; var lista: PListConvers; var ArchUs: ArchUsuarios; var ArchCon: ArchConversaciones; var ArchMen:ArchMensajes);
{Este procedimiento carga todos los datos en las estrucuturas, guardados en los archivos a partir de la última ejecución.}
    var error: boolean;
    begin
        arbol:= nil;
        lista:= nil;
        assign(ArchUs, '/ip2/AsUsuariosMMyDMP');
        assign(ArchCon, '/ip2/AsConversMMyDMP');
        assign(ArchMen, '/ip2/AsMensajesMMyDMP');
        abrirArchUsers(ArchUs, error);
        if not error then begin
            reset(ArchUs);
            CargarArbol(arbol, ArchUs);
            close(ArchUs);
        end;    
        abrirArchConvers(ArchCon, error);
        if not error then begin
            reset(ArchCon);
            CargarListConvers(lista, ArchCon, arbol);
            close(ArchCon);
        end;    
        abrirArchMens(ArchMen, error);
        if not error then begin
            reset(ArchMen);
            CargarListMens(lista, arbol, ArchMen);
            close(ArchMen);
        end;
    end;
    
{Programa Principal}    
var ArbolUsuarios: PArb;
    ListaConversaciones: PListConvers;
    ArchivoUsuarios: ArchUsuarios;
    ArchivoConversaciones: ArchConversaciones; 
    ArchivoMensajes: ArchMensajes;

begin
    InicializarEstructuras(ArbolUsuarios, ListaConversaciones, ArchivoUsuarios, ArchivoConversaciones, ArchivoMensajes);
    EjecutarMenu1(ArbolUsuarios, ListaConversaciones, ArchivoUsuarios, ArchivoConversaciones, ArchivoMensajes);
end.