
type name = String.t

let valid_name name = not @@ CCString.is_empty name || CCString.contains name '='

module Name_module = CCString
type value = string list

let string_of_value value = CCList.to_string ~sep:":" (CCFun.id) value
let value_of_string str = CCString.split_on_char ':' str

let variable_of_string str = 
  match CCString.Split.left ~by:"=" str with
  | None -> None
  | Some (name, value_string) ->
      if not @@ valid_name name
      then None
      else Some (name, value_of_string value_string)
      
let string_of_variable var =
  let name, value = var in
  if (not @@ valid_name name) || CCList.is_empty value
  then None
  else Some (Format.sprintf "%s=%s" name (string_of_value value))


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

let array_of_environment env =
  let add_if_valid name value_list array =
    let _, value = Option.value ~default:(0 (* does not matter *), []) (get_last_version value_list) in
    match string_of_variable (name, value) with
    | None -> array
    | Some str -> CCArray.append array [|str|]
  in
  Environment.fold (fun key value env_arr -> if exists key env then add_if_valid key value env_arr else env_arr) env CCArray.empty

let get_current_environment () = Unix.environment () |> environment_of_array

let set_current_environment env =
  Environment.iter
  begin fun key _ ->
    match get key env with
    | None -> ExtUnix.Specific.unsetenv key (* if versions of variable exists, but get returns None, it means that it has to be removed or that it was removed *)
    | Some value -> ExtUnix.Specific.setenv key (string_of_value value) true
  end
  env