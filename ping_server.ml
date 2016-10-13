open Yojson.Safe
open Udp_server

type request = Ping | Unknown
type response = Pong | Unknown

let port = 3456
let parser s =
  try
    match from_string s with
    | `Assoc [("type", `String "ping")] -> Ok Ping
    | otherwise -> Error ("Could not parse " ^ s ^ " into a valid request type")
  with Yojson.Json_error _ -> Error ("Could not parse " ^ s ^ " into a valid JSON value")
let serializer res = match res with
  | Pong -> to_string @@ `Assoc [("type", `String "pong")]
  | Unknown -> to_string @@ `Assoc [("type", `String "you suck")]
let handler req = match req with
  | Ping -> Pong
  | otherwise -> Unknown

(*let ping_server = Udp_server.create_server port parser serializer handler in*)
(*() = Lwt_main.run @@ Udp_server.start_server ping_server*)
let () = Lwt_main.run @@ Udp_server.start_server (Udp_server.create_server port parser serializer handler)
