(** Various types and functions to manipulate Unix paths. (No Windows Support currently)*)

type path 
(** The type of Unix path. *)

val get_filename : path -> string option
(** [get_filename path] returns a filename if the path is not a directory, None if it is empty or a directory.*)

val path_length : path -> int
(** [path_length path] returns the number of components of a path. It's the numbers of directory plus the filename if it exists. 
    For example "/usr/bin/opam" has length 3, and "/usr/bin/" has length 2.*) 

val is_drectory : path -> bool
(** [is_directory path] returns true if the path is a directory, false otherwise or if it is empty.*)

val is_absolute : path -> bool
(** [is_absolute path] returns true if the path is absolute, false otherwise. (it returns false for an empty path) *)

val is_relative : path -> bool
(** [is_absolute path] returns true if the path is relative, false otherwise. (it returns false for an empty path) *)

(** {2 Path parsing} *)

val parse_path : string -> path option 
(** [parse_path string] parses string and transform it into a path path if it is valid, returns None otherwise. *)

val parse_path_unsafe : string -> path
(** [parse_path_unsafe string] parses string and transform it into a path path if it is valid, returns an empty path, otherwise. (Note that an empty path shouldn't exists.) *)

val path_of_string : string -> path option
(** Same as [parse_path]. *)

val string_of_path : path -> string option
(** [string_of_path path] returns a string representation of path, if path is invalid, it returns None. *)