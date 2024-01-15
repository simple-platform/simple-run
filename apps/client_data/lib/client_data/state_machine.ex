defmodule ClientData.StateMachine do
  @moduledoc """
  This module provides the state machine functionality for managing state transitions.
  """

  defmacro __using__(opts) do
    unless Keyword.has_key?(opts, :states) do
      raise ArgumentError, "You must provide :states when using StateMachine."
    end

    unless Keyword.has_key?(opts, :transitions) do
      raise ArgumentError, "You must provide :transitions when using StateMachine."
    end

    states = opts |> Keyword.get(:states, [])
    transitions = opts |> Keyword.get(:transitions, %{})

    quote do
      @states unquote(states)
      @transitions unquote(transitions)

      import ClientData.StateMachine

      @before_compile ClientData.StateMachine
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      unless Module.defines?(__MODULE__, {:pre_transition, 3}, :def) do
        raise "#{__MODULE__} must implement pre_transition/3"
      end

      unless Module.defines?(__MODULE__, {:post_transition, 3}, :def) do
        raise "#{__MODULE__} must implement post_transition/3"
      end

      unless Module.defines?(__MODULE__, {:persist_state_change, 3}, :def) do
        raise "#{__MODULE__} must implement persist_state_change/3"
      end
    end
  end

  def transition_to(struct, module, next_state, metadata \\ %{}) do
    states = module |> Module.get_attribute(:states)

    unless states |> Enum.member?(next_state) do
      raise "Invalid state '#{next_state}' for #{module}"
    end

    transitions = module |> Module.get_attribute(:transitions)

    unless transitions[struct.state] |> Enum.member?(next_state) do
      raise "Transition from '#{struct.state}' to '#{next_state}' is not allowed for #{module}"
    end

    with {:ok, struct} <- module.pre_transition(struct, next_state, metadata),
         {:ok, struct} <- module.persist_state_change(struct, next_state, metadata),
         {:ok, _pid} <- Task.start(fn -> module.post_transition(struct, next_state, metadata) end) do
      {:ok, struct}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
