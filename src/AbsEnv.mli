
(** Various functions and types to represent environment in a shell scripting setting.*)



(** {1 Environment variables} *)


type name = string 
type value = string list

type environment
(** The type of an Unix environment.
    You can convert the current process environement (representend in OCaml as an array of string) to this type, and conversely.*)

val empty : environment
(** An environment that contains no variables.*)
    

val exists_version : name -> environment -> bool
(** [exists_version name env] returns true if any version of variable with a specific name exists in the environment, it could returns true if a variable has been removed ! Use [exist] if you don't want that. *)

val exists : name -> environment -> bool
(** [exists name env] returns true if a variable exists in the current environment, false otherwise. 
    You should know that the non-existence of a varialbe in the environment doesn't mean that no version of it exists ! Use [exists_version] if you wnat to check if versions exists.*)

val get : name -> environment -> value option 
(* [get name env] returns [Some value] if a variable name exists in the environment, where value is its value.*)

val get_version : name -> int -> environment -> value option
(** [get_version name version env] returns [Some value] if a variable associated with name of a specific version (versionb are 0-indexed, version 0 is the initial version (or first) of a value) exist in the environment.
    Returns None if there is no value associated with the variable, the version, or if the value associated with the version is []*)

val version_count : name -> environment -> int
(** [version_count name env] get the number of version of a specific variable in an environment.*)


val set : name -> value -> environment -> environment
(** [set name value env] returns an environment, where the value associated with name was modified, and the precedent value added into "versions" of the name variable.
    If a variable doesn't exist, create it, so "set_value" also serves as "add_value". *)

val remove : name -> environment -> environment
(** [remove name env] returns an environment without the variable associated with name, value of this variable are always accessible with [get_version].*)

val environment_of_array : string array -> environment
(** [environment_of_array env] convert an array of "name=value" strings to an environment. For an example of such array, see Unix.environment ()*)

val array_of_environment : environment -> string array
(** [array_of_environment arr] convert an environment to an array of "name=value", note that value are sorted in the returned array.*)

val get_current_environment : unit -> environment
(** [get_current_environment ()] convert the current process environment to an Absente environment, and returns it.*)

val get_current_environment : environment -> unit
(** [set_current_environment env] takes an Absente environment, and modify the current process environment according to what is set in input the Absente environment.*)
