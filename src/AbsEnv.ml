
type name = String.t

let valid_name name = not @@ CCString.is_empty name || CCString.contains name '='

module Name_module = CCString
type value = string list

let _string_of_value value = CCList.to_string ~sep:":" (CCFun.id) value
let value_of_string str = CCString.split_on_char ':' str

let variable_of_string str = 
  match CCString.Split.left ~by:"=" str with
  | None -> None
  | Some (name, value_string) ->
      if not @@ valid_name name
      then None
      else Some (name, value_of_string value_string)

module Environment = CCMap.Make(Name_module)

type environment = (int * value) list Environment.t
(* a list of version of the variable is associated with its name, the int represents the "version number"*)

let empty = Environment.empty

let get_last_version (version_list : (int * value) list) = CCList.last_opt (CCList.sort (fun (o1, _) (o2, _) -> Int.compare o1 o2) version_list)

let exists_version variable_name env = 
  Environment.mem variable_name env

let get variable_name env =
  match Environment.get variable_name env with
  | None -> None
  | Some version_list ->
    begin match get_last_version version_list with
    | None -> None
    | Some (_, []) -> None
    | Some (_, value) -> Some value
    end

let get_version variable_name version env =
  match Environment.get variable_name env with
  | None -> None
  | Some version_list ->
    begin match CCList.assoc_opt ~eq:(Int.equal) version version_list with
    | None -> None
    | Some [] -> None
    | Some value -> Some value
    end

let version_count variable_name env =
  match Environment.get variable_name env with
  | None -> 0
  | Some version_list -> CCList.length version_list

let exists variable_name env =
  match get variable_name env with
  | None -> false
  | Some _ -> true

let set variable_name value env = 
  match Environment.get variable_name env with
  | None -> Environment.add variable_name [(0, value)] env
  | Some version_list -> 
    begin match get_last_version version_list with
    | None -> Environment.add variable_name [(0, value)] env
    | Some (version, _) -> Environment.add variable_name ((version + 1, value) :: version_list) env
    end

let remove variable_name env = 
  if exists_version variable_name env
  then 
    if exists variable_name env
    then set variable_name [] env
    else env
  else 
    env  

let environment_of_array array =
  let set_if_valid s env =
    match variable_of_string s with
    | None -> env
    | Some (name, value) -> set name value env
  in
  if array = CCArray.empty then empty
  else CCArray.fold (fun env var -> set_if_valid var env ) empty array

let get_current_environment () = Unix.environment () |> environment_of_array