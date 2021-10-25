(lang dune 2.9)
(name absente)
(generate_opam_files true)

(package 
 (name absente)
 (synopsis "Absente is a shell programming library for OCaml.")
 (description " Absente is a library that (try) defines an higher-level interface on 
                tops of Unix bindings.")
  
 (depends
  extunix
  containers)

  (authors "desumn")
  (maintainers "desumn")
  (source (github desumn/absente))
  (bug_reports "https://github.com/desumn/absente/issues"))


  
 
  

