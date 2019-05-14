#!/bin/bash

# By ismavolk

thisPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );
pomoCounterFile="${thisPath}/.pomoCounterFile";
soundFile="${thisPath}/sound.wav";

# uso: pomoTimer $((25*60)) (para 25 minutos
# uso: pomoTimer 20 (para 20 segundos)
function pomoTimer()
{
    if [ "${1}" == "--help" ] || [ "${1}" == "-h" ] || [ "${1}" == "?" ] || [ "${1}" == "" ]; then
        echo "uso: pomoTimer $((25*60)) && xmessage \"O pomodoro terminou\""
    else
        date0=$((`date +%s`));
        date1=$((`date +%s` + $1));
        totalTime=$(date -u --date @$(($1)) +%M:%S);
        secsTot=$(date -u --date @$(($1)) +%s);
        progressBarSize=50;

        LC_NUMERIC="en_US.UTF-8";

        while [ "$date1" -ge `date +%s` ]; do
            reverseTime=$(date -u --date @$(($date1 - `date +%s`)) +%M:%S);
            timeElapsed=$(date -u --date @$((`date +%s` - $date0)) +%M:%S);
            secsElapsed=$(date -u --date @$((`date +%s` - $date0)) +%s);

            #perc number %
            perc=$(bc <<< "scale=2; ($secsElapsed/$secsTot)*100");
            perc=`printf "%0.0f\n" $perc`;

            # progress bar
            percBar=$(bc <<< "scale=2; ($perc/100*$progressBarSize)");
            percBar=`printf "%0.0f\n" $percBar`;

            len=0;
            strProgress=""
            while [ $len -lt $percBar ];
            do
                strProgress=$strProgress"=";
                let len=len+1;
            done


            strProgress=$strProgress">";

            len=`echo ${#strProgress}`
            while [ $len -lt $progressBarSize ];
            do
                strProgress=$strProgress" ";
                let len=len+1;
            done
            # /progress bar

#            pomoImgBlink="  ";
#            if [ `echo "$secsElapsed % 2" | bc` -eq 0 ]; then
#                pomoImgBlink="\U1F345";
#            fi

            echo -ne "$2: $timeElapsed $perc%[$strProgress] -$reverseTime / $totalTime\r";

            sleep 1
        done
    fi
}

function pomodoro()
{
    clear;

    # se o arquivo contador não existe, cria ele
    if [ ! -f $pomoCounterFile ]; then
        echo 0 > $pomoCounterFile;
    fi

    completedPomodoroCounter=`cat ${pomoCounterFile}`;

    if [ "${1}" == "-r" ]; then
        echo 0 > $pomoCounterFile;
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

    echo -n "Completed: $completedPomodoroCounter";
    if [ $completedPomodoroCounter -gt 0 ]; then

        j=0
        while [ $j -lt $completedPomodoroCounter ]; do
            echo -ne " \U1F345 ";
            j=$(( j + 1 ))
        done
    fi

    echo "";

    if [ "${1}" == "" ] || [ "${1}" == "-w" ]; then
#        pomoTimer 1
        pomoTimer $((25*60)) "Pomodoro";

        ( xmessage "### pomodoro $((completedPomodoroCounter+1)) finished ###" & ) > /dev/null 2>&1;
        aplay -q "$soundFile";

        completedPomodoroCounter=$((completedPomodoroCounter+1));
        echo $completedPomodoroCounter > $pomoCounterFile;

        if [ "${1}" == "-w" ]; then
            return;
        fi

        pomodoro -b; # inicia o contador de tempo de descanso imediatamente
    else
        if [ "${1}" == "-b" ]; then
            if [ $completedPomodoroCounter -lt 4 ]; then
                pomodoro -sb; # 5 minutos de descanso
            else
                pomodoro -lb; # após 5 pomodoros, 15 minutos de descanso
            fi
        elif [ "${1}" == "-sb" ]; then
            pomoTimer $((5*60)) "Short break"; # 5 minutos de descanso

            ( xmessage "### End of the rest, to work! ###" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        elif [ "${1}" == "-lb" ]; then
            pomoTimer $((15*60)) "Long break"; # após 5 pomodoros, 15 minutos de descanso

            ( xmessage "### End of the rest, to work! ###" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        fi

    fi
}

pomodoro $1;
