(** This module contains a simple function for creating a server instance that uses UDP to listen for messages,
    parses them and handles them. To use this module, first create a server using create_server providing it
    with the port number to listen on, a function for parsing a string into some sort of message, a function
    that takes a message and returns a response, and finally a function that serializes the response value to
    a string. After that you can use the function start_server to start the server. The start_server will
    return a function that can be called with unit to stop the server from listening for more messages.
*)

type ('req, 'res, 'game_state) t
type ('v, 'error_msg) result = Ok of 'v | Error of 'error_msg

(*val 'req 'res create_server : int -> (string -> 'req) -> ('res -> string) -> ('req -> 'res) -> 'req 'res t*)
val create_server : int -> (string -> ('req, string) result) -> ('res -> Bytes.t) -> ('req -> ('game_state, 'res)) -> ('req, 'res) t

(* val start_server *)
(*val start_server : ('a, 'b) t -> (unit -> unit Lwt.t) Lwt.t*)
val start_server : ('req, 'res, 'game_state) t -> 'game_state -> unit Lwt.t
