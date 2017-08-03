// Farben einbinden
#include "colors.inc"

// Debuging Variblen
#declare Debug_Init = 1;
#declare Debug_RotateLevel = 1;

// Statische Variablen
#declare SEITE_RECHTS = 0;
#declare SEITE_LINKS = 1;
#declare SEITE_OBEN = 2;

#declare ROTATION_CLOCK = 1;
#declare ROTATION_COUNTERCLOCK = -1;

// Bei der Rotation einer Ebene wird diese über eine Sichtbare Seite und den Abstand von dem Eck-Wuerfel in der Mitte des Bildschirmes definiert => Jede Ebene bekommt eine Nummer
// SPALTE [Seitennummer (Siehe Static SEITE_??)], [Distanze vom Eck-Wuerfel (0-2)]
#declare SPALTE = array[3][3]
    #declare SPALTE[0][0] = 0;
    #declare SPALTE[0][1] = 1;
    #declare SPALTE[0][2] = 2;

    #declare SPALTE[1][0] = 3;
    #declare SPALTE[1][1] = 4;
    #declare SPALTE[1][2] = 5;

    #declare SPALTE[2][0] = 6;
    #declare SPALTE[2][1] = 7;
    #declare SPALTE[2][2] = 8;
    
// Jede Seite hat eine Nummer, ueber die die Farbe zugewiesen wird
#declare FARBE = array[6]
    #declare FARBE[0] = pigment {Red}
    #declare FARBE[1] = pigment {Orange}
    #declare FARBE[2] = pigment {Blue}
    #declare FARBE[3] = pigment {Green}
    #declare FARBE[4] = pigment {White}
    #declare FARBE[5] = pigment {Yellow}
    
// Grundkörper
#declare Wuerfel = box {
    <-0.48,-0.48,0.48>, <0.48,0.48,-0.48>
}

#declare Seite = box {
    <-0.4,-0.04,0.4>, <0.4,0.04,-0.4>
    rotate <0,0,90>
}

// Gibt den Zeitpunkt (Clock-Wert), bei dem die Erste Rotation beginnt, an
#declare CStart = 0;

// Speicher für alle Würfel
#declare Cube = array[27]

// Speichert für jede Position die Würfel ID, des momentan dort sitzenden Würfels
#declare CubeArrangement = array[3][3][3]

// Initialisiert die Umgebung
#macro InitSetting()
    #debug "Initialisiere Setting \n"
    camera {
        //orthographic
        location <6,7,6>
        look_at <0,0,0>
    }

    background {
        color Violet
    }

    light_source {
        <5,5,0>
        color rgb <0.5,0.5,0.5>
    }

    light_source {
        <0,5,5>
        color rgb <0.5,0.5,0.5>
    }

    /*
    plane {
        <0,1,0>,-1.5
        pigment {White}
        rotate <0,0,0>
    }
    */
#end


// Schwarzen Wuerfel
#macro Erzeugen_Grundstruktur (Wuerfel, Grundstruktur)
    #for(X, 0, 2, 1)
        #for(Y, 0, 2, 1)
            #for(Z, 0, 2, 1)
                #declare Grundstruktur[X][Y][Z] = object {
                    Wuerfel
                    translate <X-1,Y-1,Z-1>
                }
            #end
        #end
    #end
#end

// Farbigen Seitenflaechen
#macro Erzeugen_Seiten (Seite, Seiten)
    #for(SeitenNr, 0, 5, 1)
        #for(A, 0, 2, 1)
            #for(B, 0, 2, 1)
                #declare Seiten[A][B][SeitenNr] = object {
                    Seite
                    pigment {FARBE[SeitenNr]}
                    
                    #switch (SeitenNr)
                        #case (5)
                        #case (4)
                            rotate <0,0,-90>
                        #break
                        #case (3)
                        #case (2)
                            rotate <0,90,0>
                        #break
                    #end
                    
                    #switch (SeitenNr)
                        #case (0)
                            translate <1.5,A-1,B-1>
                        #break
                        #case (1)
                            translate <-1.5,A-1,B-1>
                        #break
                        #case (2)
                            translate <B-1,A-1,1.5>
                        #break
                        #case (3)
                            translate <B-1,A-1,-1.5>
                        #break
                        #case (4)
                            translate <B-1,1.5,A-1>
                        #break
                        #case (5)
                            translate <B-1,-1.5,A-1>
                        #break
                    #end
                }
            #end
        #end
    #end
#end

// Zeigt den kompletten Cube an
#macro Anzeigen_Cube()
    #for(I, 0, 26, 1)
        Cube[I]
    #end
#end 

// Schreib die Würfel in das Cube Array, und speichert die IDs in dem CubeArrangement Array
#macro AssignArray(Cube, CubeArrangement, Grundstruktur)
    
    #if(Debug_Init)
        #debug " \n"
        #debug "AssignArray \n"
    #end
    
    #declare I = 0;
    #for(X, 0, 2, 1)
        #for(Y, 0, 2, 1)
            #for(Z, 0, 2, 1)
                #declare Cube[I] = Grundstruktur[X][Y][Z]
                
                #declare CubeArrangement[X][Y][Z] = I;
                
                #if(Debug_Init)
                    #debug str(X,0,0)
                    #debug "-"
                    #debug str(Y,0,0)
                    #debug "-"
                    #debug str(Z,0,0)
                    #debug " -- "
                    #debug "Cube Nr:"
                    #debug str(CubeArrangement[X][Y][Z],3,0)
                    #debug "  \n"
                #end
                
                #declare I = I + 1;
            #end
        #end
    #end
#end

// Verschmiltzt die Schwarzen Würfel mit ihren jeweiligen Seitenflaechen
#macro Binden(Cube, CubeArrangement)
    #for(SeitenNr, 0, 5, 1)
        #for(A, 0, 2, 1)
            #for(B, 0, 2, 1)
                #switch (SeitenNr)
                    #case (0)
                        #declare Grundstruktur[2][A][B] = union {
                            object {
                                Grundstruktur[2][A][B]
                            }
                            object {
                                Seiten[A][B][SeitenNr]
                            }
                        }
                    #break
                    #case (1)
                        #declare Grundstruktur[0][A][B] = union {
                            object {
                                Grundstruktur[0][A][B]
                            }
                            object {
                                Seiten[A][B][SeitenNr]
                            }
                        }
                    #break
                    #case (2)
                        #declare Grundstruktur[B][A][2] = union {
                            object {
                                Grundstruktur[B][A][2]
                            }
                            object {
                                Seiten[A][B][SeitenNr]
                            }
                        }
                    #break
                    #case (3)
                        #declare Grundstruktur[B][A][0] = union {
                            object {
                                Grundstruktur[B][A][0]
                            }
                            object {
                                Seiten[A][B][SeitenNr]
                            }
                        }
                    #break
                    #case (4)
                        #declare Grundstruktur[B][2][A] = union {
                            object {
                                Grundstruktur[B][2][A]
                            }
                            object {
                                Seiten[A][B][SeitenNr]
                            }
                        }
                    #break
                    #case (5)
                        #declare Grundstruktur[B][0][A] = union {
                            object {
                                Grundstruktur[B][0][A]
                            }
                            object {
                                Seiten[A][B][SeitenNr]
                            }
                        }
                    #break
                #end
            #end
        #end
    #end
    AssignArray(Cube,CubeArrangement, Grundstruktur)
#end

// Initialisiert die Grundwelt und den Rubiks Cube
#macro Init(Cube,CubeArrangement)
    InitSetting()
    
    #declare Grundstruktur = array[3][3][3]
    #declare Seiten = array[3][3][6]
    
    Erzeugen_Grundstruktur(Wuerfel,Grundstruktur)
    Erzeugen_Seiten(Seite,Seiten)
    Binden(Cube,CubeArrangement)
#end

// Rotiert einen Einzelnen Würfel, Benötigt dafür die Würfel ID, die Rotations-Achse und ob Mit oder Gegen den Uhrzeigersinn
#macro RotateCube(Number, Direktion, Rotation)
    #declare Cube [Number] = object {
        Cube[Number]
        #switch(Direktion)
        #case (0)
            rotate <0,0,Rotation * 90>
        #break
        #case (1)
            rotate <Rotation * 90,0,0>
        #break
        #case (2)
            rotate <0,Rotation * 90,0>
        #break
        #end
    }
#end

// Liefert den X,Y,Z Array-Index eines Würfels bei Angaben von A,B, der Seite und Entfernung zum 2,2,2 Eck-Würfel der in der Mitte des Bildschirmes liegt
#macro Location(X,Y,Z,A,B,Seite,Entfernung)
    #switch (SPALTE[Seite][Entfernung])
            #case (0)
                #declare X = A;
                #declare Y = B;
                #declare Z = 2;
            #break
            #case (1)
                #declare X = A;
                #declare Y = B;
                #declare Z = 1;
            #break
                #case (2)
                #declare X = A;
                #declare Y = B;
                #declare Z = 0;
            #break
            
            #case (3)
                #declare X = 2;
                #declare Y = A;
                #declare Z = B;
            #break
            #case (4)
                #declare X = 1;
                #declare Y = A;
                #declare Z = B;
            #break
            #case (5)
                #declare X = 0;
                #declare Y = A;
                #declare Z = B;
            #break
            
            #case (6)
                #declare X = A;
                #declare Y = 2;
                #declare Z = B;
            #break
            #case (7)
                #declare X = A;
                #declare Y = 1;
                #declare Z = B;
            #break
            #case (8)
                #declare X = A;
                #declare Y = 0;
                #declare Z = B;
            #break
        #end
#end

// Rotiert eine komplette Ebene
#macro RotateLevel(Seite,Entfernung, Rotation, CubeArrangement)
    #debug "\n"
    #debug "Rotation: \n"
    #for(A, 0, 2, 1)
        #for(B, 0, 2, 1)
            #declare X = -1;
            #declare Y = -1;
            #declare Z = -1;
            Location(X,Y,Z,A,B,Seite,Entfernung)
            
            #if(Debug_RotateLevel)
                #debug str(X,0,0)
                #debug "-"
                #debug str(Y,0,0)
                #debug "-"
                #debug str(Z,0,0)
                #debug " -- "
                #debug "Cube Nr: "
                #debug str(CubeArrangement[X][Y][Z],0,0)
                #debug "\n"
            #end
            
            RotateCube(CubeArrangement[X][Y][Z],Seite, Rotation)
        #end
    #end
    //#debug "\n"
    //UpdateCubeArrangement(Seite, Entfernung,Rotation,CubeArrangement)
    //#debug "\n\n"
#end

// Rotiert eine komplette Ebene, in Abhängigkeit von der Zeit (Clock)
#macro RotateLevelTime(Seite,Entfernung,Rotation,CubeArrangement,CStart,Clock)
    #if(Clock >= CStart & Clock < (CStart + 1))
        #declare RotationNew = Rotation * (Clock - CStart);
        RotateLevel(Seite,Entfernung,RotationNew,CubeArrangement)
    #else
        #if(Clock >= (CStart + 1))
            RotateLevel(Seite,Entfernung,Rotation,CubeArrangement)
        #end
    #end
    #declare CStart = CStart + 1;
#end

Init(Cube,CubeArrangement)

#declare X = -1;
#declare Y = -1;
#declare Z = -1;

RotateLevelTime(SEITE_RECHTS,0,ROTATION_COUNTERCLOCK,CubeArrangement, CStart, clock)
Anzeigen_Cube()



