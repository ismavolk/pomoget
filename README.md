# pomoget

Implementation of the pomodoro technique in shell script

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Depends on 'aplay' and xmessage

```
sudo apt-get install aplay
sudo apt-get install xmessage
```

### Installing

Unzip 
```
unzip pomoget.zip
```

Enter 
```
cd pomoget
```

Run
```
./pomoget
```

##

You can use arguments
* Without any argument starts the pomodoro and at the end starts the break(short or long based on completed pomodoros <= 4 short > 4 long)
* -w Start pomodoro [w]ithout break after pomodoro finishes
* -r [R]eset pomodoro counter
* -b start [B]reak(short or long based on completed pomodoros <=4 short  long)";
* -sb start [S]hort [B]reak
* -lb start [L]ong [B]reak

## Author

* ** Ismael Machado ** - (https://github.com/ismavolk/pomo-cmd)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

