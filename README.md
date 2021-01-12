## Team Kill Logging Mutator for Rising Storm 2: Vietnam

### Features
- Logs team kills (and optionally normal kills) in server logs for administrative purposes.
- (Team) kill log forwarding to a Discord text channel.
- Has no effect on normal player experience.

### Kill log examples
![example log entry](https://i.ibb.co/X3JXKSq/tklog.png "Example log entry")

## Discord Webhook integration
Integrating kill logs with Discord by using webhooks is supported and
requires [TKLServer](https://github.com/tuokri/tklserver).

### Mutator argument for server operators
```?mutator=TKLMutator.TKLMutator```

### Configuration
Team kill logging can be enabled or disabled in 'ROGame_TKLMutator.ini' by setting ```bLogTeamKills``` to either ```True``` or ```False```.
Team kill log files are of format 'FILENAME-DATE.log', where FILENAME can be set by ```TKLFileName``` in the configuration file.

Changing configuration might require map change or server restart.

### Steam Workshop
https://steamcommunity.com/sharedfiles/filedetails/?id=1858859776

