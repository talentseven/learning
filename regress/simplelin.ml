(*
 *
 * simplelin.ml
 * Simple linear regression implemented with gradient descent. 
 *
 * Andrei Formiga, 2011-09-09
 *
 *)

(* 

A small test: x is a regular 1d grid of points, y is 3x + 2 plus 
a random gaussian error with mean 0 and sd 1.4

R code to generate y with noise:
x <- c(0:20)
yr <- 3 * x + 2
e <- rnorm(21, 0, 1.4)
y <- yr + e

Try a small alpha for convergence, e.g. 0.01, with around 1000 iterations. 

*)
let x = Array.map float [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 
                           11; 12; 13; 14; 15; 16; 17; 18; 19; 20 |]

let y = [|  1.695703;   4.743485;  5.676318;  9.797812; 15.896629; 16.034265; 
           22.192882;  25.603156; 26.260349; 30.049906; 33.545128; 34.701009; 
           39.821333;  40.454697; 44.220842; 46.516572; 47.734861; 55.097740; 
           55.245841;  58.207056; 62.579173 |]



let linear_h (th0, th1) x = 
  th0 +. th1 *. x

let array_sum a = 
  Array.fold_right (+.) a 0.0

let array_op a1 a2 op = 
  Array.mapi (fun i x -> op x a2.(i)) a1 

let residuals (th0, th1) x y = 
  array_op (Array.map (linear_h (th0, th1)) x) y (-.) 

let sum_abs_residuals (th0, th1) x y = 
  array_sum (Array.map abs_float (residuals (th0, th1) x y))

(* A single step of batch gradient descent *)
let batch_gd_step alpha (th0, th1) x y =
  let m = float (Array.length x) in
  let difs = residuals (th0, th1) x y in                              (* difs = h(x) - y               *)
  let delta0 = (1. /. m) *. (array_sum difs) in                       (* delta0 = 1/m * sum difs       *)
  let delta1 = (1. /. m) *. (array_sum (array_op difs x ( *. ))) in   (* delta1 = 1/m * sum (difs * x) *)
  (th0 -. (alpha *. delta0), th1 -. (alpha *. delta1))

(* Batch gradient descent for linear regression with iters iterations *)
let batch_gd iters alpha (th0, th1) x y = 
  let rec loop i (th0, th1) = 
    if i = 0 then (th0, th1) else loop (i-1) (batch_gd_step alpha (th0, th1) x y) in
  loop iters (th0, th1)

(* Read a vector from a dat file *)
let read_dat fname = 
  let f = open_in fname in
  let rec read_point acc = 
    try 
      let acc' = Scanf.fscanf f " %f " (fun x -> x :: acc) in
      read_point acc'
    with End_of_file -> acc in
  Array.of_list (List.rev (read_point []))

(* Solutions for Exercise 2 in Andrew Ng's Machine Learning course (OpenClassroom version) *)
let ex2 () = 
  let xe = read_dat "ex2x.dat" in
  let ye = read_dat "ex2y.dat" in
  let th01, th11 = batch_gd_step 0.07 (0.0, 0.0) xe ye in
  let th0, th1 = batch_gd 1500 0.07 (0.0, 0.0) xe ye in
  Printf.printf "First iteration: theta0 = %6.4f, theta1 = %6.4f\n" th01 th11; 
  Printf.printf "Final: theta0 = %6.4f, theta1 = %6.4f\n"

