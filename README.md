# 1wMonitoring
One Wire Monitoring

This is a collection of scripts to record and monitor (multiple) values which are to be read out over One Wire devices. Values can be either sensor values (e.g. temperatures, humidity, etc.) or counter values. Data is saved into tab separated text files and are fed into an rrd database.

Values can be monitored using nagios or icinga by deploying the script in lib/nagios/plugins and the corresponding configuration file in share/1wMonitoring/check\_temperature.nagios.cfg (usually to be copied to /etc/nagios-plugins/config/temperature.cfg)


## Installing
Get code from github

    # change into the directory where you want to download the files. 
    # cd xxx
    git clone --depth=1 https://github.com/clemens-it/1wMonitoring.git

I recommend the use of stow for the script's deployment.

    mkdir -p /usr/local/stow/1wMonitoring
    cp -r 1wMonitoring/* /usr/local/stow/1wMonitoring
    rm /usr/local/stow/1wMonitoring/README.md
    cd /usr/local/stow
    stow 1wMonitoring


## Setup and configuration
Have a look at the scripts mentioned below before you execute them. First of all to make sure they do what you want and furthermore because many scripts have their own configuration values at their beginning. You may need to adjust those values to fit your needs and configuration.

A list of required Debian packages can be found in share/doc/1wMonitoring/required\_Debian\_packages.

Rename the sample configuration file (which is just another perl script defining a bunch of variables) bin/1wMonConfig.pl.sample to bin/1wMonConfig.pl, edit the file and fill in the sensors you want to monitor. Set up the path to store the txt and rrd files. Create the corresponding directories.

    mv 1wMonitoring/bin/1wMonConfig.pl.sample 1wMonitoring/bin/1wMonConfig.pl

Execute the command `1wgetValues.pl` to test your configuration. It should enlist your configured sensors with the corresponding values.

Create the rrd databases using the script `libexec/1wMonitoring/gen_rrd_create.pl`. Note that this script does not create the database but merely produces and displays the corresponding shell command. Copy the script's output and paste it into the shell.

Execute `bin/1wSensorMon.pl` to test the read out and writing of the sensor values into the txt file as well as into the rrd database.
Do the same with `bin/1wCounterMon.pl` to test it for counter values.

An example of a cron script to call the monitoring process can be found in share/doc/1wMonitoring/1wMonitoring.cron for automatic recording.

For counter values there exists another script which acts as a daemon (`bin/1wCounterMonContinous.pl`). This daemon will however not update the rrd database. For transferring the values into the rrd database two scripts can be used (`fill_txt_into_rrd_logtail.sh` and `update_txt_into_rrd.sh`).  
The initial idea of this daemon was to read out counter values with a higher frequency than sensor values without causing too many I/O writes for memory cards (e.g. when deployed on a Raspberry Pi).
To start this daemon at system startup it can be inserted into the file /etc/rc.local (just add the command /usr/local/bin/1wCounterMonContinous.pl at the end of the file).

