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
        time=$1;
        date0=$((`date +%s`));
        date1=$((`date +%s` + $time));
        totalTime=$(date -u --date @$(($time)) +%M:%S);
        secsTot=$(date -u --date @$(($time)) +%s);
        progressBarSize=50;
        pomoTypeStr=$2; #pode ser pomodoro, short break ou long break
        completedPomodoroCounter=$3;

        LC_NUMERIC="en_US.UTF-8";

        printf '%s \033[38;5;9m %s \033[0m\n' "-- `date +"%Y-%m-%d %H:%M:%S"` --" "$pomoTypeStr Running ($totalTime)";

        #printf 'here is text with \033[38;5;9m color \033[0m and  without\n'

#        echo -n "Completed pomodoros: $completedPomodoroCounter";
        printf 'Completed pomodoros: \033[38;5;9m%s\033[0m' $completedPomodoroCounter;

        if [ $completedPomodoroCounter -gt 0 ]; then
            j=0
            while [ $j -lt $completedPomodoroCounter ]; do
                echo -ne " \U1F345";
                j=$(( j + 1 ))
            done
        fi

        echo "";

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

#            strProgress=$strProgress">";

            #2, 28, 34, 128, 154
#            strProgress=$strProgress`printf '\033[38;5;9m=\033[0m\033[38;5;34m>\033[0m'`;
            # /progress bar

#            pomoImgBlink="  ";
#            if [ `echo "$secsElapsed % 2" | bc` -eq 0 ]; then
#                pomoImgBlink="\U1F345";
#            fi

#            echo -ne "$pomoTypeStr $timeElapsed $perc%[$strProgress] -$reverseTime \r";
#            pad=$(printf '%*s' "$progressBarSize");
            printf '\033[38;5;9m%s\033[0m %s %s[%-*s] %s\r' "$pomoTypeStr" "$timeElapsed" "$perc%" $progressBarSize "$strProgress>" "-$reverseTime";

            sleep 1
        done

        echo "";
        echo "";
        echo "`date +"%Y-%m-%d %H:%M:%S"`  -  $pomoTypeStr finished [$timeElapsed/$totalTime]";
        echo "";
    fi
}

function pomoget()
{
#    clear;

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
        echo "-c [C]ontinue interrupted pomodoro (not implemented)";
        return;
    fi

    if [ "${1}" == "" ] || [ "${1}" == "-w" ]; then
#        pomoTimer 1
        pomoTimer $((25*60)) "POMODORO" $completedPomodoroCounter;

        ( xmessage "### pomodoro $((completedPomodoroCounter+1)) finished ###" & ) > /dev/null 2>&1;
        aplay -q "$soundFile";

        completedPomodoroCounter=$((completedPomodoroCounter+1));
        echo $completedPomodoroCounter > $pomoCounterFile;

        if [ "${1}" == "-w" ]; then
            return;
        fi

        pomoget -b; # inicia o contador de tempo de descanso imediatamente
    else
        if [ "${1}" == "-b" ]; then
            if [ $completedPomodoroCounter -lt 4 ]; then
                pomoget -sb; # 5 minutos de descanso
            else
                pomoget -lb; # após 5 pomodoros, 15 minutos de descanso
            fi
        elif [ "${1}" == "-sb" ]; then
            pomoTimer $((5*60)) "SHORT BREAK" $completedPomodoroCounter; # 5 minutos de descanso

            ( xmessage "### End of the rest, to work! ###" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        elif [ "${1}" == "-lb" ]; then
            pomoTimer $((15*60)) "LONG BREAK" $completedPomodoroCounter; # após 5 pomodoros, 15 minutos de descanso

            ( xmessage "### End of the rest, to work! ###" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        fi

    fi
}

pomoget $1;
