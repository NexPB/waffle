defmodule Waffle.Transformations.Convert do
  @moduledoc false
  alias Waffle.Transformations.Command

  def apply(cmd, file, args, extension \\ nil) do
    new_path =
      if extension,
        do: Waffle.File.generate_temporary_path(extension),
        else: Waffle.File.generate_temporary_path(file)

    args =
      if is_function(args),
        do: args.(file.path, new_path),
        else: [file.path | String.split(args, " ") ++ [new_path]]

    result = Command.execute(cmd, args_list(args))

    case result do
      {_, 0} ->
        {:ok, %Waffle.File{file | path: new_path, is_tempfile?: true}}

      {error_message, _exit_code} ->
        {:error, error_message}
    end
  end

  defp args_list(args) when is_list(args), do: args
  defp args_list(args), do: ~w(#{args})
end
