module L = Llvm
module StringMap = Map.Make(String)


  let context = L.global_context();;
  let the_module = L.create_module context "small test file";;
  let i32_t      = L.i32_type    context;;
  let i1_t       = L.i1_type     context;;
  let float_t    = L.double_type context;;
  let void_t     = L.void_type   context;;
  let main_type = L.function_type i32_t [||];;
  let the_function = L.define_function "main" main_type the_module;;
  let _ = L.const_null void_t;;
  let builder = L.builder_at_end context (L.entry_block the_function);;
  let     func_struct_ptr = L.pointer_type (L.named_struct_type context "coolfunction" )
  let f = (L.declare_global func_struct_ptr "coolfunctionstruct" the_module)
  let so = L.build_global_stringptr "Hello, world!\n" "hi there" builder;;
  let zero = L.const_int i32_t 0;;
  let s = L.build_gep f [| zero |] "" builder;; 
  let _ = L.build_load s "loadinst" builder;;
  (* let _ = L.build_ret (L.undef void_t) builder;; *)
  let _ = print_string (L.string_of_llmodule the_module);;