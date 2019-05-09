#!/bin/bash

# criado por ismavolk

thisPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );
pomoCounterFile="${thisPath}/.pomoCounterFile";
soundFile="${thisPath}/sound.wav";

# uso: 0timer $((25*60)) (para 25 minutos
# uso: 0timer 20 (para 20 segundos)
function 0timer()
{
    if [ "${1}" == "--help" ] || [ "${1}" == "-h" ] || [ "${1}" == "?" ] || [ "${1}" == "" ]; then
        echo "uso: 0timer $((25*60)) && xmessage \"O pomodoro terminou\""
    else
        date1=$((`date +%s` + $1));
        while [ "$date1" -ge `date +%s` ]; do
            echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
            sleep 0.1
        done
    fi
}

function pomodoro()
{
    # se o arquivo contador não existe, cria ele
    if [ ! -f $pomoCounterFile ]; then
        echo 1 > $pomoCounterFile;
    fi

    pomodoroCounter=`cat ${pomoCounterFile}`;

    if [ "${1}" == "-r" ]; then
        echo 1 > $pomoCounterFile;
        echo "Pomodoro counter reseted"
        return;
    fi

    if [ "${1}" == "--help" ] || [ "${1}" == "-h" ] || [ "${1}" == "?" ]; then
        echo "Without any argument start the pomodoro and at the end starts the break(short or long based on completed pomodoros <= 4 short > 4 long)";
        echo "-w Start pomodoro [w]ithout break after pomodoro finishes";
        echo "-r [R]eset pomodoro counter";
        echo "-b start [B]reak(short or long based on completed pomodoros <=4 short >4 long)";
        echo "-sb start [S]hort [B]reak";
        echo "-lb start [L]ong [B]reak";
        return;
    fi

    if [ "${1}" == "" ] || [ "${1}" == "-w" ]; then
        echo "--- pomodoro ${pomodoroCounter} (completed: $((pomodoroCounter-1))) ---";
#        0timer 1
        0timer $((25*60)); # 25 minutos de pomodoro

        ( xmessage "--- pomodoro ${pomodoroCounter} finished ---" & ) > /dev/null 2>&1;
        aplay -q "$soundFile";

        pomodoroCounter=$((pomodoroCounter+1));
        echo $pomodoroCounter > $pomoCounterFile;

        if [ "${1}" == "-w" ]; then
            return;
        fi

        pomodoro -b; # inicia o contador de tempo de descanso imediatamente
    else
        if [ "${1}" == "-b" ]; then
            if [ $pomodoroCounter -lt 5 ]; then
                pomodoro -sb; # 5 minutos de descanso
            else
                pomodoro -lb; # após 5 pomodoros, 15 minutos de descanso
            fi
        elif [ "${1}" == "-sb" ]; then
            echo "--- short break ---";

            0timer $((5*60)); # 5 minutos de descanso

            ( xmessage "--- End of the rest, to work! ---" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        elif [ "${1}" == "-lb" ]; then
            echo "--- long break ---";

            0timer $((15*60)); # após 5 pomodoros, 15 minutos de descanso

            ( xmessage "--- End of the rest, to work! ---" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        fi

    fi
}

pomodoro $1;
