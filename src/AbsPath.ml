
let path_prefix = ["./"; "../"; "/"]

type path = string list

let get_prefix path = CCList.head_opt path

let get_components path = CCList.tail_opt path

let path_length path = (CCList.length path) - 1

let get_filename path = CCList.last_opt path

let is_directory path =
  match get_filename path with
  | Some last_elem when last_elem = "" -> true
  | _ -> false

let is_absolute path =
  match get_prefix path with
  | Some "/" -> true
  | _ -> false

  let is_relative path = not (is_absolute path)

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
  | Error _ -> None
  | Ok (prefix, components) -> Some (prefix :: components)

let parse_path_unsafe path = Option.value ~default:[""] (parse_path path)

let string_of_path path = parse_path path