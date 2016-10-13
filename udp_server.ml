open Lwt_unix
open Lwt

type ('v, 'error_msg) result = Ok of 'v | Error of 'error_msg
type 'req parser = string -> ('req, string) result
type 'res serializer = 'res -> Bytes.t
type ('req, 'res) request_handler = 'req -> 'res

type ('req, 'res) t = (int * 'req parser * 'res serializer * (('req, 'res) request_handler))

let create_server port parser serializer handler = (port, parser, serializer, handler)

let buffer_size = 30 * 1024

let sendto_error_msg written_count expected_count =
  Printf.sprintf "Could only send %d/%d bytes when calling sendto\n" written_count expected_count

let start_server (port, parser, serializer, handler) =
  let socket_fd = socket Lwt_unix.PF_INET Lwt_unix.SOCK_DGRAM 0 in
  let socket_addr = ADDR_INET (Unix.inet_addr_any, port) in
  let buffer = Bytes.init buffer_size (fun _ -> Char.chr 0) in
  let rec serve () =
    recvfrom socket_fd buffer 0 buffer_size [] >>= fun (read_count, sender_addr) ->
    let read_string = Bytes.sub_string buffer 0 read_count in
    match parser read_string with
      | Ok parsed_request ->
        let response = serializer (handler parsed_request) in
        let response_length = Bytes.length response in
        sendto socket_fd response 0 response_length [] sender_addr >>= fun written_count ->
        if written_count != response_length
         then Lwt_io.write Lwt_io.stdout (sendto_error_msg written_count response_length) >>= serve
         else serve ()
      | Error msg -> (Lwt_io.write Lwt_io.stdout (msg ^ "\n")) >>= serve in
  Lwt_unix.bind socket_fd socket_addr;
  serve ()
