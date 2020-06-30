## TEAM KILL LOGGING MUTATOR FOR RISING STORM 2: VIETNAM

### FUNCTIONALITY
Log team kills (and optionally normal kills) in server logs for administrative purposes.

Has no effect on normal player experience.

### EXAMPLE LOG ENTRY
![example log entry](https://i.ibb.co/X3JXKSq/tklog.png "Example log entry")

## DISCORD WEBHOOK INTEGRATION
Integrating kill logs with Discord by using webhooks is supported and
requires [TKLServer](https://github.com/tuokri/tklserver).

### MUTATOR ARGUMENT FOR SERVER OPERATORS
```?mutator=TKLMutator.TKLMutator```

### CONFIGURATION
Team kill logging can be enabled or disabled in 'ROGame_TKLMutator.ini' by setting ```bLogTeamKills``` to either ```True``` or ```False```.
Team kill log files are of format 'FILENAME-DATE.log', where FILENAME can be set by ```TKLFileName``` in the configuration file.

Changing configuration might require map change or server restart.

### STEAM WORKSHOP
https://steamcommunity.com/sharedfiles/filedetails/?id=1858859776

Currently pending mod whitelisting by TWI.
