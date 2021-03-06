
let path_prefix = ["./"; "../"; "/"]

let expandable_components = ["./" ; "../" ; "i." ; ".." ; "."]

let non_prefix_expandable_components = ["." ; ".."]

type path = string list

let get_prefix path = CCList.head_opt path

let get_components path = CCList.tail_opt path

let get_last_component path = CCList.last_opt path

let path_length path = (CCList.length path) - 1

let get_filename path = CCList.last_opt path

let is_directory path =
  match get_filename path with
  | Some last_elem when last_elem = "" -> true
  | _ -> false

let is_file path =
  match get_filename path with 
  | Some last_elem when last_elem <> "" -> true
  | _ -> false

let is_absolute path =
  match get_prefix path with
  | Some "/" -> true
  | _ -> false

let is_relative path = not (is_absolute path)

let is_implicit path =
  match get_prefix path with
  | Some "i." -> true
  | _ -> false


(* Path parser *)


let prefix_parsers = List.map (CCParse.exact) path_prefix

let prefix_failer = 
  CCParse.fail @@
  Printf.sprintf "excepted %s at the beginning of the string."
  (CCList.to_string (Fun.id) path_prefix ~start:"[" ~stop:"]")

let prefix_parser = 
  List.fold_right
  (fun parser accumulator -> CCParse.or_ parser accumulator) 
  prefix_parsers
  prefix_failer

let components_parser = 
  (CCParse.sep ~by:(CCParse.char '/') (CCParse.many @@ CCParse.char_if (fun c -> c <> '/') ~descr:"'/' not accepted in path"))
  |> 
  CCParse.map (fun char_list_list -> CCList.map (fun char_list -> CCString.of_list char_list) char_list_list)

let path_parser =
  CCParse.both prefix_parser components_parser

let parse_path path_string =
  match CCParse.parse_string path_parser path_string with
  | Error _ ->
    begin match CCParse.parse_string components_parser path_string with
    | Error _ -> None
    | Ok components -> Some ("i." :: components) (* "i." is a special "implicit prefix", equivalent to "." *)
    end
  | Ok (prefix, components) -> 
    let comp_len = List.length components in
    let fixed_components = List.filteri (fun i comp -> i = comp_len - 1 || comp <> "") components in (* the only empty string in the path should be the last, but you can form as much empty string as you want with path like "/////" *)
    Some (prefix :: fixed_components)

let parse_path_unsafe path = Option.value ~default:[""] (parse_path path)

let path_of_string path = parse_path path

let string_of_path path = 
  match get_prefix path with
  | None -> None
  | Some prefix_ ->
    let prefix = if prefix_ = "i." then "" else prefix_ in
    match get_components path with
    | None -> None
    | Some components -> Some (CCList.to_string ~start:prefix ~sep:"/" (Fun.id) components)

(* Path manipulation *)

let current_working_directory () = parse_path_unsafe (Unix.getcwd() ^ "/") (* if the current working directory is invalid, then there's a problem with the path parser*)
  (* we add "/" at the end of getcwd so that the parser treat it as a directory.*)

let rec get_parent non_expanded_path = 
  let path = expand_path non_expanded_path in
  match path with
  | None -> None
  | Some path ->
    let path_len = path_length path in
    if path_len = 1
    then Some path (* the root path do not have any parents, he is is own parent *)
    else if is_directory path 
    then Some (CCList.take (path_len - 1) path)
    else if is_file path 
    then Some (CCList.take (path_len) path)
    else None

and expand_prefix_from dir prefix =
  match prefix with (* "." and ".." clause are added, as ".." and "." can appear in the middle of a path*)
  | "./" | "i." | "." -> Some dir 
  | "../" | ".." -> (get_parent dir)
  | "/" -> Some ["/"]
  | _ -> None

and expand_path path = 
  let expanded_prefix = 
    match get_prefix path with
    | None -> None
    | Some p ->  expand_prefix_from (current_working_directory ()) p 
  in
  if Option.is_none expanded_prefix then None else
  let components = Option.value ~default:[] (get_components path) in
  let expanded_path = 
  List.fold_left
  begin fun accumulator component ->
    
    if List.mem component expandable_components
    then Option.get ((expand_prefix_from (accumulator) component)) (* expansion will do something, as we checked input in line 131 *)
    else List.append accumulator [component]
    
  end
  (Option.get expanded_prefix) (* it cannot be None *)
  components
  in 
  if List.mem (Option.get (get_last_component path)) non_prefix_expandable_components (* we know the list cannot be empty *)
  then Some (expanded_path @ [""])
  else Some expanded_path


