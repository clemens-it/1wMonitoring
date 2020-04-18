# 1wMonitoring
1-Wire Monitoring

This is a collection of scripts to record and monitor (multiple) values which
are read out from
[1-Wire(R)](https://www.maximintegrated.com/en/products/ibutton-one-wire/one-wire.html)
devices. Values can either be sensor values (e.g. temperatures, humidity, etc.)
or counter values. Data is saved into tab separated text files and are also fed
into an RRD database.

Values can be monitored using nagios or icinga by deploying the script in
`lib/nagios/plugins` and the corresponding configuration file in
`share/1wMonitoring/check\_temperature.nagios.cfg` (usually to be copied to
`/etc/nagios-plugins/config/temperature.cfg`)


## Installing
Get code from github

    # change into the directory where you want to download the files.
    # cd xxx
    git clone --depth=1 https://github.com/clemens-it/1wMonitoring.git

I recommend the use of `stow` for the script's deployment.

    mkdir -p /usr/local/stow/1wMonitoring
    cp -r 1wMonitoring/* /usr/local/stow/1wMonitoring
    rm /usr/local/stow/1wMonitoring/README.md
    cd /usr/local/stow
    mv 1wMonitoring/bin/1wMonConfig.pl.sample 1wMonitoring/bin/1wMonConfig.pl
    stow 1wMonitoring


## Setup and configuration
Have a look at the scripts mentioned below before you execute them. First of
all to make sure they do what you want and furthermore because many scripts
have their own configuration values at their beginning. You may need to adjust
those values to fit your needs and configuration.

A list of required Debian packages can be found in
`share/doc/1wMonitoring/required\_Debian\_packages`.

Have a look at the sample configuration file, which was renamed from
`bin/1wMonConfig.pl.sample` to `bin/1wMonConfig.pl` before running stow. It is
just another perl script defining a bunch of variables. Edit the file and fill
in the sensors you want to monitor. Set up the path to store the TXT and RRD
files. Create the corresponding directories.

Execute the command `1wgetValues.pl` to test your configuration. It should
enlist your configured sensors with the corresponding values.

Assuming you left the suggested path values in the configuration file untouched
create the directory `/srv/1wMonitoring`. Afterwards execute the monitoring
scripts (`1wSensorMon.pl` and/or `1wCounterMon.pl` depending on your
configuration). They will complain about not being able to find the
corresponding RRD database, which is fine at this moment. However, they will
also write the sensor values into the configured text file, which are required
by the script that helps you to create the RRD databases.

    mkdir /srv/1wMonitoring
    1wSensorMon.pl
    1wCounterMon.pl

Create the RRD databases using the script
`libexec/1wMonitoring/gen_rrd_create.pl`. Note that this script does not create
the database but merely produces and displays the corresponding shell command.
Copy the script's output and paste it into the shell.

Execute `1wSensorMon.pl` again to test the read out and writing of the sensor
values into the TXT file as well as into the RRD database.
Do the same with `1wCounterMon.pl` to test it for counter values.

An example of a cron script to call the monitoring process can be found in
`share/doc/1wMonitoring/1wMonitoring.cron` for automatic recording.

For counter values there exists another script which acts as a daemon
(`bin/1wCounterMonContinous.pl`). This daemon will however not update the RRD
database. For transferring the values into the RRD database two scripts can be
used (`fill_txt_into_rrd_logtail.sh` and `update_txt_into_rrd.sh`). The daemon
has also another feature: to play an alert sound if a counter has increased
more than a configured limit since the last read. To play the sound the command
`aplay` is used.
The initial idea of this daemon was to read out counter values with a higher
frequency than sensor values without causing too many I/O writes for memory
cards (e.g. when deployed on a Raspberry Pi).
To start this daemon at system startup it can be inserted into the file
`/etc/rc.local` (just add the command `/usr/local/bin/1wCounterMonContinous.pl`
at the end of the file). Keep in mind to check and adjust the value of the
parameter `step` for the RRD database creation.
