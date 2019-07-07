# Syssm

Syssm is a SYStem Service Manager for ComputerCraft. Its purpose is to allow you to write service files (or functions) that run in the background, in the most literal sense behind the shell. 

## Syssm API
This API is contained in the global environment. Call any of the functions by using `syssm.<function>`

`inject`: Put a function in the background as a service

- **Parameters**
  - _string_: Name of the service
  - _function_: Function to use as service, gets somewhat limited access to Lua/CC
- **Returns**
  - _table_: Service API functions

`getServices`: Get a list with the name of the service as the key, and the service API as the value

- **Parameters**
  - _none_
- **Returns**
  - _table_: key-value table: name-service API

### Service API
This API is returned when a service is injected, and started. 

`status`: returns one of five status modes indicating what state the service is in

- **Parameters**
  - _none_
- **Returns**
  - _string_: status (Running, Initializing, Paused, Stopped, Terminated)

`toggle`: pauses/resumes the service

- **Parameters**
  - _[boolean]_: Optional value, if left empty state of service will swap
- **Returns**
  - _none_

`getLogs`: get a string of output provided by the service

- **Parameters**
  - _number_: maximum amount of lines to provide
- **Returns**
  - _string_: Logged data

`getError`: get the error the service provided on halting

- **Parameters**
  - _none_
- **Returns**
  - _string_: error message, blank string if nothing was provided.

## Writing a Service

For the sake of the end user, default means of getting output from the user have been revoked. Those APIs and functions would be: io, term, paintutils, window, print, write, printError. The alternative function for all forms of output is called `log`

`log`: Log information directly related to the service

- **Parameters**
  - _string_: information. Multiple comma seperated strings can be provided
- **Returns**
  - _none_

Services can either be provided as standalone files, placed in the `init.d` directory. On startup these will be loaded. Each file is treated like a service, no need to call `syssm.inject`! Of course if you don't want to do that, `inject` is your other option.

## Syssm CLI Utility
All of the following commands can be performed by prefacing with `syssm` and then following the command with the name of a service. 

`status`: Provides a brief overview of the state of the service
`save`: Saves the logs or error of a service. Following the name of the service to target, use the word `logs` or `error` to select what to save.
`pause`: Pauses execution of the thread
`resume`: Resumes execution of the thread