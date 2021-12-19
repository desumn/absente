

# What is an environment

A Unix environment associates, simply put, a string value with another string value.
It provides to programs that needs it "environment variables", that are association of a name (string value) with a certain value. Programs are able to retrieves theses variables, and locally modify them: an environment is inherited from the parent process of a program, and if a child can effectively modify an environment variable, it can only modify it for its own purpose, or for his child process purposes.

The Unix environment is an array (in OCaml, but globally a collection) of "name=value" string, associating a name with a value, programs can access this array, or use "getenv" to indirectly access it. 

In a shell scripting setting, the user can get every environment variable that he inherited, modify them, and pass them ("export" them) to the program he invokes. Note that there is a number of "standard" variables, defined to have a special purposes. (such as HOME or PATH...)


# What is an Absente environment ?

An Absente environment module should consequently provides differents features:
    
    - A way to get an environment variable from an environment.
    - A way to set an environment variable in an environment.
    - A way to remove a variable from an environment.
    - A way to get the current process environment, in the form of an Absente environment.
    - A way to modify a variable in the current environment, maps it from an Absente environment to the process environment.
  
A basic interface should provide theses features, but an interesting features would be to have an history of change in the current program environment, so that we can potentially reverse a failed modification, for instance.

From this, some features should be added: 

    - When modifying a variable in a given environment, the Absente function should not erase it.
    - We should be able to get all versions of a specific variable, or only a specific version of a variable.

An easy way to know if a variable exists should also be added.


This is the basic "low-level" interface, more features could be added in the future, for example some special cases functions for "standards" variables.


#