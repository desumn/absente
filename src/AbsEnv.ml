

type name = string
type value = string list
let string_of_value value = CCList.to_string ~sep:":" (CCFun.id) value
let value_of_string str = CCString.split_on_char ':' str

type variable = name * value

let valid_name name = not @@ CCString.is_empty name || CCString.contains name '='

let get_name var = fst var

let get_value var = snd var

let string_of_variable var =
  let name, value = get_name var, get_value var in
  if not @@ valid_name name
  then None 
  else Some (Format.sprintf "%s=%s" name (string_of_value value))

let variable_of_string str : variable option = 
  match CCString.Split.left ~by:"=" str with
  | None -> None
  | Some (name, value_string) ->
      if not @@ valid_name name
      then None
      else Some (name, value_of_string value_string)

let new_var name value : variable option = 
  if valid_name name
  then Some (name, value)
  else None   


type environment = variable CCFQueue.t

let empty = CCFQueue.empty

let add_var var env = CCFQueue.snoc env var

let add_opt_var var env =
  match var with
  | None -> env
  | Some var -> add_var var env

let rem_var name env = add_opt_var (new_var name []) env

(* Note that, to have a functionning history of variable changes, we do not remove the variable, but shadows it.*)

let environment_of_array env_arr =
  if env_arr = CCArray.empty then empty
  else CCArray.fold (fun env var -> add_opt_var (variable_of_string var) env) empty env_arr


let array_of_environment env = 
  let add_opt_var var env_arr =
    match var with
    | None -> env_arr
    | Some var -> CCArray.append env_arr [|var|] in
  if env = CCFQueue.empty then CCArray.empty
  else CCFQueue.fold (fun env_arr var -> add_opt_var (string_of_variable var) env_arr) CCArray.empty env

let get_current_environment = Unix.environment () |> environment_of_array


