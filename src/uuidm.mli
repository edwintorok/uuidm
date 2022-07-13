(*---------------------------------------------------------------------------
   Copyright (c) 2008 The uuidm programmers. All rights reserved.
   SPDX-License-Identifier: ISC
  ---------------------------------------------------------------------------*)

(** Universally unique identifiers (UUIDs).

    [Uuidm] implements 128 bits universally unique identifiers version
    3, 5 (name based with MD5, SHA-1 hashing) 4, (random based) and 7 (random
    and timestamp based) according to
    {{:https://www.rfc-editor.org/rfc/rfc9562}RFC 9562}.

    See the {{!page-index.quick}quick start}. *)

(** {1:uuids UUIDs} *)

type t
(** The type for UUIDs. *)

val v3 : t -> string -> t
(** [v3 ns n] is a V3 UUID (named based with MD5 hashing) named by [n] and
    namespaced by [ns]. *)

val v5 : t -> string -> t
(** [v5 ns n] is a V5 UUID (named based with SHA-1 hashing) named by [n] and
    namespaced by [ns]. *)

val v4 : bytes -> t
(** [v4 b] is a V4 UUID (random based) that uses the first 16 bytes of
    [b] for randomness.

    {b Warning.} Most of the random 16 bytes of randomness are seen literally
    in the result. *)

val v4_gen : Random.State.t -> (unit -> t)
(** [v4_gen seed] is a function that generates random V4 UUIDs (random
    based) with the given [seed].

    {b Warning.} Sequences of UUIDs generated using {!Stdlib.Random} are
    suitably random but {e predictable} by an observer. If that is an
    issue for you, use {!v4} with random bytes generated by a CSPRNG. *)

val v7 : t_ms:int64 -> rand_a:int -> rand_b:int64 -> t
(** [v7 t_ms:int ~rand_a ~rand_b] is a V7 UUID (time and random
    based) that uses 48 low bits of the POSIX timestamp [t_ms] the 12
    lower bits of of [rand_a] and the 62 lower bits of [rand_b]. *)

val v7_ns : t_ns:int64 -> rand_b:bytes -> t
(** [v7_ns ts b] is a V7 UUID (time and random ased) that uses the
    first 8 bytes of [b] for randomness and takes [ts] to be the
    {e unsigned} number of nanoseconds since midnight 1 Jan 1970 UTC, leap
    seconds excluded. The timestamp will be represented in the UUID -
    with a resolution of about 244 nanoseconds - such that the
    ordering of UUIDs will match the ordering of timestamps.

    {b Warning.} Most of the 8 bytes of randomness are seen literally
    in the result. *)

(** {1:constants Constants} *)

val nil : t
(** [nil] is the
    {{:https://www.rfc-editor.org/rfc/rfc9562#name-nil-uuid}nil} UUID. *)

val max : t
(** [max] is the {{:https://www.rfc-editor.org/rfc/rfc9562#name-max-uuid}max}
    UUID. *)

val ns_dns : t
(** [ns_dns] is the DNS namespace UUID. *)

val ns_url : t
(** [ns_url] is the URL namespace UUID. *)

val ns_oid : t
(** [ns_oid] is the ISO OID namespace UUID. *)

val ns_X500 : t
(** [ns_dn] is the X.500 DN namespace UUID. *)

(** {1:comparing Comparing} *)

val equal : t -> t -> bool
(** [equal u u'] is [true] iff [u] and [u'] are equal. *)

val compare : t -> t -> int
(** [compare] is the total binary order on UUIDs. *)

(** {1:fmt_binary Standard binary format}

    This is the binary format mandated by
    {{:http://tools.ietf.org/html/rfc4122}RFC 4122}. *)

val of_bytes : ?pos:int -> string -> t option
(** [of_bytes pos s] is the UUID represented by the 16 bytes starting
    at [pos] (defaults to [0]) in [s]. The result is [None] if the
    string is not long enough. *)

val to_bytes : t -> string
(** [to_bytes u] is [u] as a 16 bytes long string. *)

(** {1:fmt_binary_mixed Mixed-endian binary format}

    This is the binary format in which the three first fields of UUIDs
    (which are oblivious to this module) are read and written in
    little-endian. This corresponds to how UEFI or Microsoft formats
    UUIDs. *)

val of_mixed_endian_bytes : ?pos:int -> string -> t option
(** [of_mixed_endian_bytes] is like {!of_bytes} but decodes
    the mixed endian serialization. *)

val to_mixed_endian_bytes : t -> string
(** [to_mixed_endian_bytes] is like {!to_bytes} but encodes
    the mixed endian serialization. *)

(**/**)
val unsafe_of_bytes : string -> t
val unsafe_to_bytes : t -> string
(**/**)

(** {1:fmt_ascii US-ASCII format} *)

val of_string : ?pos:int -> string -> t option
(** [of_string pos s] converts the substring of [s] starting at [pos]
    (defaults to [0]) of the form ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"]
    where X is a lower or upper case hexadecimal number to an
    UUID. The result is [None] if a parse error occurs. Any extra
    characters after are ignored. *)

val to_string : ?upper:bool -> t -> string
(** [to_string u] is [u] as a string of the form
    ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"] where X is a lower
    (or upper if [upper] is [true]) case hexadecimal number. *)

(** {1:fmt Formatting} *)

val pp : Format.formatter -> t -> unit
(** [pp ppf u] formats a representation based on {!to_string}
    of [u] on [ppf]. *)

val pp_string : ?upper:bool -> Format.formatter -> t -> unit
(** [pp_string ?upper ppf u] formats [u] on [ppf] like {!to_string} would
    do. *)

(** {1:deprecated Deprecated} *)

type version =
[ `V3 of t * string (** Name based with MD5 hashing *)
| `V4 (** Random based *)
| `V5 of t * string (** Name based with SHA-1 hasing *) ]
[@ocaml.deprecated "Use the version specific Uuidm.v* functions."]
(** The type for UUID versions and generation parameters.
    {ul
    {- [`V3] and [`V5] specify a namespace and a name for the generation.}
    {- [`V4] is random based with a private state seeded with
       {!Stdlib.Random.State.make_self_init}. Use {!v4_gen} to specify
       your own seed. Use {!v4} to specify your own randomness.

       {b Warning.} The sequence resulting from repeatedly calling
       [v `V4] is random but predictable see {!v4_gen}.}} *)

val v : version -> t
[@@ocaml.deprecated "Use the version specific Uuidm.v* functions."]
[@@ocaml.warning "-3"]

(**/**)
val print : ?upper:bool -> Format.formatter -> t -> unit (* deprecated *)
[@@ocaml.deprecated "Use Uuidm.pp_string instead"]

val create : version -> t (* deprecated *)
[@@ocaml.deprecated "Use Uuidm.v instead"]
[@@ocaml.warning "-3"]
(**/**)
