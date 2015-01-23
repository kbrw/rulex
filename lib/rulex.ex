defmodule Rulex do
  @moduledoc """
  Rulex allow you to define rules just as you define functions, a simple macro
  wrapper add the needed code in order to not match the same rule twice.
  It creates a recursive function `apply_rules` which returns the accumulator
  when no rule match.
  
  Example usage : 

      iex> defmodule MyRules do
      ...>   use Rulex
      ...>   defrule my_first_rule("y"<>_,string_desc), do:
      ...>     [:starts_with_y|string_desc]
      ...>   defrule my_second_rule("ya"<>_,string_desc), do:
      ...>     [:starts_with_ya|string_desc]
      ...>   defrule my_third_rule("b"<>_,string_desc), do:
      ...>     [:starts_with_b|string_desc]
      ...> end
      ...> MyRules.apply_rules("yahoo",[])
      [:starts_with_ya,:starts_with_y]
  """
  defmacro __using__(_opts) do
    quote do
      import Rulex
      @rules []
      @before_compile Rulex
    end
  end
  defmacro __before_compile__(_env) do # add to the end of your module (after parsing so before compilation)
    quote do
      def apply_rules(_,_,acc), do: acc # if nothing match return current acc
      def apply_rules(param,acc), do:   # entry point: apply_map to %{rulename1: false, etc.}
        apply_rules(param,for(r<-@rules,do: {r,false})|>Enum.into(%{}),acc)
    end
  end
  @doc false
  def rule_fun(name,param_quote,acc_quote,body,guard_quote \\ true) do
    quote do
      @rules [unquote(name)|@rules]
      def apply_rules(unquote(param_quote)=param,%{unquote(name)=>false}=apply_map,unquote(acc_quote)) when unquote(guard_quote), do:
        apply_rules(param,%{apply_map|unquote(name)=>true},unquote(body))
    end
  end
  @doc false
  defmacro defrule({:when ,_,[{name,_,[param,acc]},guard]},[do: body]), do:
    rule_fun(name,param,acc,body,guard)
  defmacro defrule({name,_,[param,acc]},[do: body]), do:
    rule_fun(name,param,acc,body)
end
