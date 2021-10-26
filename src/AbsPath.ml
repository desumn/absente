
type path = string list

let get_first_component path = CCList.head_opt path

let exclude_first_component path = CCList.tail_opt path

let path_length path = (CCList.length path) - 1

let get_filename path = CCList.last_opt path

let is_directory path =
  match get_filename path with
  | Some last_elem when last_elem = "" -> true
  | _ -> false

let is_absolute path =
  match get_first_component path with
  | Some "/" -> true
  | _ -> false

let is_relative path = not (is_absolute path)

  
