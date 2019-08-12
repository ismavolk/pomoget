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
        progressBarLength=50;
        pomoTypeStr=$2; #pode ser pomodoro, short break ou long break
        completedPomodoroCounter=$3;

        LC_NUMERIC="en_US.UTF-8";

        printf 'Completed pomodoros:';
        if [ $completedPomodoroCounter -gt 0 ]; then
            j=0
            while [ $j -lt $completedPomodoroCounter ]; do
                echo -ne " \U1F345";
                j=$(( j + 1 ))
            done
        fi
        printf ' \033[38;5;9m%s\033[0m' $completedPomodoroCounter;
        echo "";

        printf '\033[38;5;9m%-11s\033[0m started   -- %s --\n' "$pomoTypeStr" "`date +"%Y-%m-%d %H:%M:%S"`";

        while [ "$date1" -ge `date +%s` ]; do
            reverseTime=$(date -u --date @$(($date1 - `date +%s`)) +%M:%S);
            timeElapsed=$(date -u --date @$((`date +%s` - $date0)) +%M:%S);
            secsElapsed=$(date -u --date @$((`date +%s` - $date0)) +%s);

            #perc number %
            perc=$(bc <<< "scale=2; ($secsElapsed/$secsTot)*100");
            perc=`printf "%0.0f\n" $perc`;

            # progress bar
            percBar=$(bc <<< "scale=2; ($perc/100*$progressBarLength)");
            percBar=`printf "%0.0f\n" $percBar`;

            strProgress="";
            if [ "$percBar" -gt 0 ]; then
                strProgress=`printf '%-.*s\n' $percBar '========================================================'`;
            fi

            if [ "$perc" -gt 0 ]; then
                strProgress=$strProgress">";
            fi

            #2, 28, 34, 128, 154
#            strProgress=$strProgress`printf '\033[38;5;9m=\033[0m\033[38;5;34m>\033[0m'`;
            # /progress bar

#            pomoImgBlink="  ";
#            if [ `echo "$secsElapsed % 2" | bc` -eq 0 ]; then
#                pomoImgBlink="\U1F345";
#            fi

#            echo -ne "$pomoTypeStr $timeElapsed $perc%[$strProgress] -$reverseTime \r";
#            pad=$(printf '%*s' "$progressBarSize");
            printf '\033[38;5;9m%-11s\033[0m %-4s[%-*s] TS: %s/\033[38;5;9m%s\033[0m TL: -%s\r' "$pomoTypeStr" "$perc%" $progressBarLength "$strProgress" "$timeElapsed" "$totalTime" "$reverseTime";

            sleep 1
        done

        echo "";

#        echo "`date +"%Y-%m-%d %H:%M:%S"`  -  $pomoTypeStr finished [$timeElapsed/$totalTime]";
#        printf '%s   -   \033[38;5;9m%s\033[0m %s\n' "`date +"%Y-%m-%d %H:%M:%S"`" "$pomoTypeStr" "finished";
        printf '\033[38;5;9m%-11s\033[0m finished  -- %s --\n\n' "$pomoTypeStr" "`date +"%Y-%m-%d %H:%M:%S"`";
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

        counter=0;

        if [ "${2}" != "" ]; then
            counter=${2};
        fi

        echo $counter > $pomoCounterFile;
        echo "Pomodoro counter reseted"
        return;
    fi

    if [ "${1}" == "--help" ] || [ "${1}" == "-h" ] || [ "${1}" == "?" ]; then
        echo "Without any argument start the pomodoro and at the end starts the break(short or long based on completed pomodoros <= 4 short > 4 long)";
        echo "-w Start pomodoro [w]ithout break after pomodoro finishes";
        echo "-r [R]eset pomodoro counter. Is possible set counter with -r 2, now completed pomodoro counter is 2!";
        echo "-b start [B]reak(short or long based on completed pomodoros <=4 short >4 long)";
        echo "-sb start [S]hort [B]reak";
        echo "-lb start [L]ong [B]reak";
        echo "-ct start [C]ustom [T]ime";
        echo "-c [C]ontinue interrupted pomodoro (not implemented)";
        return;
    fi

    if [ "${1}" == "" ] || [ "${1}" == "-w" ]; then
#        pomoTimer 4 "TEST" $completedPomodoroCounter;
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
        elif [ "${1}" == "-ct" ]; then
            pomoTimer $((${2}*60)) "CUSTOM TIME" $completedPomodoroCounter;

            ( xmessage "### End of custom time###" & ) > /dev/null 2>&1;
            aplay -q "$soundFile";
        fi

    fi
}

pomoget $1 $2;
