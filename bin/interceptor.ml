open Core_unix

module Config : sig
  val listen_port : file_perm
  val forward_port : file_perm
  val forward_host : Inet_addr.t
end = struct
  let port_from_env env_name default_port =
    Option.map int_of_string (Sys.getenv_opt env_name)
    |> Option.value ~default:default_port

  let listen_port = port_from_env "listen_port" 8080
  let forward_port = port_from_env "forward_port" 8081

  let forward_host =
    Sys.getenv_opt "forward_host"
    |> Option.map Inet_addr.of_string
    |> Option.value ~default:Inet_addr.localhost
end

let forward_socket = socket ~domain:PF_INET ~kind:SOCK_STREAM ~protocol:0 ()
let forward_addr = ADDR_INET (Config.forward_host, Config.forward_port)
let bufsize = 8192
let buf = Bytes.create bufsize
let zone = Lazy.force Time_unix.Zone.local

let process incoming_traffic _ =
  let in_descr = descr_of_in_channel incoming_traffic in
  let read_bytes_len, _ = recvfrom in_descr ~buf ~pos:0 ~len:bufsize ~mode:[] in
  let now =
    Time_unix.(
      format (now ()) "%Y-%m-%d %H:%M:%S" ~zone)
  in
  let payload = Bytes.to_string buf in
  send forward_socket ~buf ~pos:0 ~len:read_bytes_len ~mode:[] |> ignore;
  print_string (now ^ " : " ^ payload)

let () =
  connect forward_socket ~addr:forward_addr;
  establish_server process
    ~addr:(ADDR_INET (Inet_addr.bind_any, Config.listen_port))
