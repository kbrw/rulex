defmodule Rulex do
  @moduledoc """
  Rulex allow you to define rules just as you define functions, a simple macro
  wrapper add the needed code in order to not match the same rule twice.
  It creates a recursive function `apply_rules` which returns the accumulator
  when no rule match. Each rule can return an error, the rules will continue to
  apply and errors will be listed in the response tuple.

  `defrule rulename(matchingspec,acc) :: {:ok,newacc} | {:error,errorterm}`

  Example usage : 

      iex> defmodule MyRules do
      ...>   use Rulex
      ...>   defrule my_first_rule("y"<>_,string_desc), do:
      ...>     {:ok,[:starts_with_y|string_desc]}
      ...>   defrule my_second_rule("yahoo",_string_desc), do:
      ...>     {:error,:yahoo_is_err}
      ...>   defrule my_third_rule("ya"<>_,string_desc), do:
      ...>     {:ok,[:starts_with_ya|string_desc]}
      ...>   defrule my_fourth_rule("b"<>_,string_desc), do:
      ...>     {:ok,[:starts_with_b|string_desc]}
      ...>   defrule my_fifth_rule(param,string_desc) do
      ...>     false = param == "yahoo"
      ...>     {:ok,string_desc}
      ...>   rescue _->{:error,:yahoo_not_expected}
      ...>   end
      ...> end
      ...> MyRules.apply_rules("yahoo",[])
      {[:starts_with_ya,:starts_with_y],[:yahoo_not_expected,:yahoo_is_err]}
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
      def apply_rules(_,_,errors,acc), do: {acc,errors} # if nothing match return current acc and errors
      def apply_rules(param,acc), do:   # entry point: apply_map to %{rulename1: false, etc.}
        apply_rules(param,for(r<-@rules,do: {r,false})|>Enum.into(%{}),[],acc)
      defp apply_rules_filter(params,rulematch,errors,_acc,{:ok,newacc}), do:
        apply_rules(params,rulematch,errors,newacc)
      defp apply_rules_filter(params,rulematch,errors,acc,{:error,error}), do:
        apply_rules(params,rulematch,[error|errors],acc)
      defp apply_rules_filter(_,_,_,_,_), do:
        raise("defrule functions must return {:ok,newacc} or {:error,errorterm}")
    end
  end
  @doc false
  def rule_fun(name,param_quote,acc_quote,body,guard_quote \\ true) do
    quote location: :keep do
      @rules [unquote(name)|@rules]
      def apply_rules(unquote(param_quote)=param,%{unquote(name)=>false}=apply_map,errors,unquote(acc_quote)=acc) when unquote(guard_quote), do:
        apply_rules_filter(param,%{apply_map|unquote(name)=>true},errors,acc,unquote(body))
    end
  end
  defp blocks_as_body([do: body]), do: body
  defp blocks_as_body(blocks), do: {:try,[],[blocks]}

  @doc false
  defmacro defrule({:when ,_,[{name,_,[param,acc]},guard]},blocks), do:
    rule_fun(name,param,acc,blocks_as_body(blocks),guard)
  defmacro defrule({name,_,[param,acc]},blocks), do:
    rule_fun(name,param,acc,blocks_as_body(blocks))
end
