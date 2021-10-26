
(** Various functions and types to represent environment in a shell scripting setting.*)



(** {1 Environment variables} *)


type name = string 
type value = string list
type variable
(** The type of a single environnement variable. *)

val new_var : name -> value -> variable option
(** [new_var name value] create a new variable, returns None if "name" is empty or contains an "=" sign. *)

val get_name : variable -> name
(** [get_name var] get the name associated with the var environment variable. *)

val get_value : variable -> value
(** [get_value var] get the value associated with the var environement variable.*)

val string_of_variable : variable -> string option
(** [string_of_variable var] convert var to a "name=value" string. 
    It returns None if name is empty or if it contains an '=' sign. *)

val variable_of_string : string -> variable option
(** [variable_of_string str] convert a string of the form "name=value" to a variable. 
    It return None if the left-hand side of the string is empty or contains an "=" sign or if the right-hand side of the variable is empty.*)

(** {2 Environments} *)

type environment
(** The type of an Unix environment.
    You can convert the current process environement (representend in OCaml as an array of string) to this type, and conversely.
    
    Note that adding two variable with the same name is a legal operation, and do not erase the modified variable in the returned environment.
    When converted to an array that can be used with exec, only the last variable will be available.*)

val empty : environment
(** An environment that contains no variables.*)

val add_var : variable -> environment -> environment
(** [add_var var env] add an environment variable to the environment.*)

val rem_var : name -> environment -> environment
(** [rem_var name env] remove an environment variable from the environment. 
    Note that it check if the name of the variable is valid, if not, it returns the environment unmodified, otherwise, it add a variable with the same name and an empty value to the environment. *)

val environment_of_array : string array -> environment
(** [environment_of_array] converts a string array of variable to an environment. (For an example of a string array of variable, see Unix.environment)*)

val array_of_environment : environment -> string array
(** [array_of_environment] converts an environment to a string array of variable. (For an example of a string array of variable, see Unix.environment) *)

val get_current_environment : unit -> environment
(** [get_current_environment] gets the current environment of the process. *)

val number_of_occurrences : environment -> name -> int
(** [number_of_occurrences env var_name] returns a positive integer corresponding to the number of occurrences of a variable with a certain name in a env. *)

val get_var_version : environment -> int -> name -> variable option
(** [get_var_version env version var_name] returns a variable, corresponding to the "version"-nth occurrence of the variable in env. *)

val get_var : environment -> name -> variable option
(** [get_var env var_name] returns the variable associated with var_name in env. *)

val get : environment -> name -> value option
(** [get env var_name] returns the value associated with var_name in env. *)

val get_first_var_version : environment -> name -> variable option
(** [get_first_var_version env var_name] get the first version of the var associated with var_name in env. Equivalent to [get_var_version env 0 var_name] *)
