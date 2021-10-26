

type name = string
type value = string list
let string_of_value value = CCList.to_string ~sep:":" (CCFun.id) value
let value_of_string str = CCString.split_on_char ':' str

type variable = name * value

let valid_name name = not @@ CCString.is_empty name || CCString.contains name '='

let get_name var = fst var

let get_value var = snd var

let var_equal var1 var2 = String.equal (get_name var1) (get_name var2)

let string_of_variable var =
  let name, value = get_name var, get_value var in
  if (not @@ valid_name name) || CCList.is_empty value
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


type entry = (int * variable)
type environment = entry CCFQueue.t
(* the first int of this tuple is the "order", a variable with least order was added first in the environment*)

let get_order (order, _var) = order
let get_var (_order, var) = var

let cmp_entry e2 e1 = 
  if var_equal (get_var e1) (get_var e2) then 0 else
  Int.compare (get_order e1) (get_order e2)

let empty = CCFQueue.empty

let add_var var env = 
  let last_order = 
    match CCFQueue.last env with 
    | None -> 0
    | Some var -> get_order var
  in CCFQueue.snoc env (last_order + 1, var)

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
    | Some var -> CCArray.append env_arr [|var|] 
  in
  if env = empty then CCArray.empty
  else 
    let env_list = CCFQueue.to_seq env |> CCSeq.to_list in (* probably inneficient, but it works *)
    let deduplicated_env = List.rev env_list |> List.sort_uniq cmp_entry |> CCSeq.of_list |> CCFQueue.of_seq in
    CCFQueue.fold (fun env_arr var -> add_opt_var (string_of_variable (get_var var)) env_arr) CCArray.empty deduplicated_env

let get_current_environment () = Unix.environment () |> environment_of_array


let var_occurrence env var_name = 
  CCFQueue.fold (fun env var -> if (get_name @@ get_var var) = var_name then (var :: env) else env) [] env

let number_of_occurrences env var_name = var_occurrence env var_name |> List.length

let get_var_version_occ version occurrence =
  (List.nth_opt (List.rev occurrence) version) |> (fun opt -> Option.bind opt (fun entry -> Some(get_var entry))) 
  (* the list is reversed to preserve order, if it was not, the first version of variable would be last, and the last version of a variable would be first.*)
  
let get_var_version env version var_name =
  get_var_version_occ version (var_occurrence env var_name)

let get_var env var_name =
  let input_var_occurrence = var_occurrence env var_name in
  let input_number_of_occurrences = List.length input_var_occurrence in
  let last_version = 
    if input_number_of_occurrences > 0 
    then get_var_version_occ (input_number_of_occurrences - 1) input_var_occurrence
    else None 
  in last_version

let get env var_name = Option.bind (get_var env var_name) (fun var -> Some (get_value var))

let get_first_var_version env var_name = get_var_version env 0 var_name