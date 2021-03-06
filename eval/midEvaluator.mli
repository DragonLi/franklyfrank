(***********************************************************************
 * Evaluator defined in terms of a denotational semantics for the
 * mid-level language.
 *
 *
 * Created by Craig McLaughlin on 21/07/2015.
 ***********************************************************************
 *)

open Monad
open ParseTree
open PatternMatching

(*i | k vs
   | command
   | top-level-handler (name)
   | built-in-handler (name)
   | local-handler (handler-def, locals)
   | continuation *)

module type EVALCOMP = sig
  include MONAD

  type comp = value t
  and value =
    | VBool of bool
    | VInt of int
    | VFloat of float
    | VStr of string
    | VCon of string * value list
    | VMultiHandler of (comp list -> comp)

  module type EVALENVT = sig
    include Map.S with type key := string
    type mt = comp t
  end

  module ENV : EVALENVT

  val (>=>) : (value -> 'a t) -> ('a -> 'b t) -> value -> 'b t
  (** Kleisli composition of computations *)

  val sequence : ('a t) list -> ('a list) t
  val command : string -> value list -> comp
  val show : comp -> string
  val vshow : value -> string

  val eval_dtree : ENV.mt -> comp list -> dtree -> comp
  (** [eval_dtree cs t] evaluates the decision tree [t] w.r.t the stack of
      computations [cs] returning a computaton. The stack is assumed to
      initially hold the subject value. *)

  val eval : MidTranslate.HandlerMap.mt -> MidTree.prog -> comp
  (** Evaluation function *)
end

module EvalComp : EVALCOMP
(** Module representing evaluation of mid-level tree to monadic computation
    trees. *)

(* increment function *)
(* command "get" [] >>= (fun (Int x) -> *)
(*   command "put" [return (Int (x+1))]) *)
