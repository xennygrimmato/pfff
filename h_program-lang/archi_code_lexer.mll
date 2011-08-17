{
(* Yoann Padioleau
 *
 * Copyright (C) 2010 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)

open Common 

open Archi_code

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(* This code assumes we are called with a string enclosed by "/"
 * as in /foo.php/ so it's easy to specify the beginning or
 * end of a string (ocamllex does not handle ^ or $).
 * 
 * It also assumes the string has been lowercased. Note also that
 * the filenames has been reversed, for instance a/b/foo.php become
 * /foo.php/b/a/ because we want to return the most specialized category.
 * 
 * Note that ocamllex will try the longest match and we will return
 * the leftmost match so on "common.mli" for instance the
 * "common" rule will be applied before the .mli rule.
 *)

}

let b = ['/' '_' '-' '.']

(*****************************************************************************)

rule category = parse
  | ".vcproj/" { Building }
  | ".thrift/" { Ffi }

  (* pad specific, noweb *)
  | ".nw/" 
      { Doc }

  | ".texi/" 
      { Doc }

  | ".pdf/" 
  | ".rtf/"
      { Doc }

  | ".sql/"
      { Storage }

  | ".mli/"
  | ".h/"
  | ".hpp/"
  | ".hrl/"
      { Interface }

  (* ml specific ? *)
  | ".depend" { Building }
  | "ocamlmakefile" { BoilerPlate }
  (* oasis boilerplate *)
  | "setup.ml" { BoilerPlate }
  (* ocamlbuild boilerplate *)
  | "/_build" { BoilerPlate }

  | "makefile" 
  | "/configure" 
      { Building }

  (* linux specific ? *)
  | "kconfig" { Building }

  | "/changes" 
      { Doc }
  | "readme"
      { Doc }

  | "/license" 
  | "/copyright" 
  | b "copying" 
      { BoilerPlate }

  (* gnu software boilerplate *)
  | "/copying/" 
  | "/about-nls/" 
  | "/shtool/"
  | "/texinfo.tex/"
  | "/ltmain.sh/"
      { BoilerPlate }



  (* pad specific ? *)
  | "/main_" { Main }
  | "/flag_" { Configuration }
  | "/test_" { Test }
  | "/unit_" { Test }
  | "/visitor_" { AutoGenerated }
  | "/meta_ast_" { AutoGenerated }

  (* facebook specific *)
  | "/autoload_map" { AutoGenerated }


  | "/main." { Main }
  | "/init." { Init }

  | "/init/" { Init }

  (* facebook specific *)
  | "/home.php" { Main }
  | "/profile.php" { Main }


  | "core" { Core }
(*  | "/base" { Core } *)

  | "mysql" 
  | "sqlite" 
      { Storage }

  | "database" { Storage }

  | "security" { Security }

  | "lite" { MiniLite }
(* too many false positives, like mini in mono
   | "mini" { MiniLite } 
*)

  | b "tests" b
  | "/test/" 
  | "/test2/" 
  | "/t/" 
  | "/_test"
  | "/testsuite/"
  (* gnugo *) 
  | "/regression"
      { Test }

  | "/benchmarks"
      { Test }

  | "/example"
      { Test }
  | "dummy"
      { Test }
  | "/demos"
      { Test }

  (* facebook specific a little *)
  | "/__tests__/" { Test }

  (* pad specific *)
  | "pleac" { Test }

  | "/docs/"
  | "/doc/" 
      { Doc }

  | "/unittest/" { Unittester }
  (* can not just say "profil" because at facebook profile means
   * something else
   *)
  | "profiling" { Profiler }

  (* False positif for util below *)
  | "binutils" 
  | "coreutils"
  | "diffutils"
  | "findutils"
  | "inetutils"
      { Regular }

  | "stdlib" { Core }
  | "util" { Utils }
(*  | "/base" { Utils } *)
  | "common" { Utils }
  (* Exact "lib", Utils; *)

 | "/conf/haste/" { AutoGenerated }

  (* Can not say just thrift here because we could also want
   * to look at the thrift source itself. So really just
   * want to hide all generated code.
   * 
   * The code is actually in thrift/packages but because the filename
   * is reverse, it's /packages/thrift/ here
   *)
 | "/packages/thrift/" { AutoGenerated }

 | "/thriftdoc/" { AutoGenerated }

  (* thrift auto generated files *)
 | "/gen-" { AutoGenerated }
  (* for some projects I don't remember *)
 | "/gen/" { AutoGenerated }
  (* in android dalvik *)
 | "/out/" { AutoGenerated }


  | "storage" 
  | "/db/"
  | "/fs/"
  | "/database/"

  (* pad specific ... *)
  | "bdb/"
      { Storage }

  (* Exact "data", Storage; *)
  | "constants" { Constants }
  | "mutators"
  | "accessors"
      { GetSet }

  | "logging" { Logging }

  | "third-party"
  | "third_party" 
  | "3rdparty"
      { ThirdParty }

  | "external" { ThirdParty }
  | "legacy" { ThirdParty }
  | "deprecated" { Legacy }
  | "/attic/" { Legacy }

  | "/out/" { Legacy }

  (* pad specfic *)
  | "ocamlextra" { ThirdParty }
  | "/score_parsing" { Data }
  | "/score_tests" { Data }
  | "/archive.org" { Data }

  (* facebook fbcode fsl specifix ... *)

  | "test.txt" { Data }
  | "/big/" { Data }

(* in haskell this is a valid dir
   | "/data/" { Data } 
*)


  (* facebook specific ? *)
  | "/si/"
  | "site_integrity" 
      { Security }

  | "/auth" b 
      { Security }

  (* as in OCaml asmcomp/ directory *)
  | "x86"
  | "i386"
  | "i686"

  | "ia64"
  (* v8 source *)
  | "ia32"
  | b "x64"

  | "mips"
  | "m68k"
  | "sparc"
  | "amd64"
  | b "arm" b
  | "hppa"
  (* linux source *)
  | "parisc"
  | "s390"
  | "blackfin"
  | b "ppc" b
  | "ppc64"
  | "/power/"
  | b "powerpc" b
  | b "alpha" b
  (* gcc source *)
  | "rs6000"
  | "h8300"
  | b "vax" b
  | "sh64"
  | b "cris" b
  | "/frv/"
  (* emacs source *)
  | "386"
  | "hp800"
  | "iris4d"
  | "macppc"
  | "xtensa"

  (* qemu source *)
  | b "sh4" b
  | "microblaze"



      { Architecture }

  (* plan9 source *)
  | "/pc/" 
  | "/alphapc/" 
      { Architecture }

  | "/arch/" 
      { Architecture }

  | "unix"
  | "linux"
  | "macos"
  | "win32"

  | "cygwin"
  | "msdos"
  | b "vms" b
  | b "dos/" b
  | "mswin"
  | "ms-w32"
  (* emacs source *)
  | b "aix" b
  | b "hpux" b
  | b "irix" b
  | "darwin"
  | "freebsd"
  | "netbsd"
  | "openbsd"
  | b "bsd" b

  | b "w32" b

  (* tinyGL *)
  | "/beos"

      { OS }

  | "dns" 
  | "ftp"
  | "ssh" 
  | "http" 
  | "smtp" 
  | "ldap" 
  | b "imap" b  (* because can have files like guimap *)
  | "krb4" 
  | "pop3" 
  | "socks" 
  | "ssl" 
  | "socket" 
  | "mime" 
  | "url." 
  | "uri." 
  | "ipv4"
  | "ipv6"
  | "icmp."
  | "tcp."
      { Network }

  (* scan and gram ? too short ? *)
  | "scanne"
  | "parse"
  | "lexer"
  | "token" (* false positive with security stuff ? *)
  | "/gram."
  | "/scan."
  | "grammar"
  | "/lex"

  (* invent UnParsing category ? do also print ? *)
  | "pretty_print"
      { Parsing }

  | "/ui/"
  | "/gui/" 

  (* too many false positives ? *)
  | "gui"

  | "display"
  | "render"
  | "/video/"
  | "/media/"
  | "screen"
  | "visual"
  | "image"
  | "jpeg"
  | "/ui."
  | "window"
  | "/draw_"
      { Ui }

  (* pad specfici ? *)
  | "/layer_"
      { Ui }

  | "/gtk/"
  | "/qt/"
  | "/tcltk/"
  | "x11"
  (* wxwindows. it's also used in efuns, e.g. toolkit/wX_edit.ml *)
  | "/wx" 
      { Ui }

  | "/intern/" { Intern }

  (* overlay specific, because of all those __xxx__ directories *)
  | b "intern" b { Intern }
  | b "ui/" b
 | "/lib__thrift__packages/" { AutoGenerated }
 | "/lib__thrift__packages__intern/" { AutoGenerated }

  (* as in Linux *)
  | "documentation" { Doc }
  (* todo also  memory ?  so mm/ is colored too  *)
  | "/net/" { Network }

  | "/old/"
  | "/backup/"
      { Legacy }

  | "/tmp/"
      { Legacy }

  (* i18n *)

  | "/af/"
  | "/ar/"
  | "/az/"
  | "/bg/"
  | "/ca/"
  | "/ca-valencia/"
  | "/cs/"
  | "/da/"
  | "/de/"
  | "/de-informal/"
  | "/el/"
  (* I keep this one so at least I can see one | "/en/" *)
  | "/eo/"
  | "/es/"
  | "/et/"
  | "/eu/"
  | "/fa/"
  | "/fi/"
  | "/fo/"
  | "/fr/"
  | "/gl/"
  | "/he/"
  | "/hi/"
  | "/hr/"
  | "/hu/"
  | "/ia/"
  | "/id/"
  | "/id-ni/"
  | "/is/"
  | "/it/"
  | "/ja/"
  | "/km/"
  | "/ko/"
  | "/ku/"
  | "/lb/"
  | "/lt/"
  | "/lv/"
  | "/mg/"
(*  | "/mk/" can be source of mk *)
  | "/mr/"
  | "/ne/"
  | "/nl/"
  | "/no/"
  | "/pl/"
  | "/pt/"
  | "/pt-br/"
  | "/ro/"
  | "/ru/"
  | "/sk/"
  | "/sl/"
  | "/sq/"
  | "/sr/"
  | "/sv/"
  | "/th/"
  | "/tr/"
  | "/uk/"
  | "/vi/"
  | "/zh/"
  | "/zh-tw/"
  | "/la/"
      { I18n }

  | "i18n" 
  | "unicode"
  | "gettext"
  | "/intl/"
      { I18n }
      

  | _ { 
      category lexbuf
    }
  | eof { Regular }
