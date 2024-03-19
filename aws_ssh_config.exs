Mix.install([
  {:ex_aws, "~> 2.0"},
  {:configparser_ex, "~> 4.0"},
  {:ex_aws_ec2, "~> 2.0"},
  {:hackney, "~> 1.9"},
  {:sweet_xml, "~> 0.6"}
])

defmodule Generator do
  import SweetXml, only: [sigil_x: 2]

  @profile "default"
  @key_dir "~/.ssh/"
  @key_name "id_ed25519"
  @region "ap-northeast-1"

  def run() do
    Application.put_env(:ex_aws, :access_key_id, [
      {:system, "AWS_ACCESS_KEY_ID"},
      {:awscli, @profile, 30},
      :instance_role
    ])

    Application.put_env(:ex_aws, :secret_access_key, [
      {:system, "AWS_SECRET_ACCESS_KEY"},
      {:awscli, @profile, 30},
      :instance_role
    ])

    query = ExAws.EC2.describe_instances()

    {:ok , %{body: body}} = ExAws.request(query, region: @region)

    content = body
    |> SweetXml.xpath(
      ~x"//DescribeInstancesResponse/reservationSet/item/instancesSet/item"l,
      private_ip: ~x"./privateIpAddress/text()",
      public_ip: ~x"./ipAddress/text()",
      instance_id: ~x"./instanceId/text()",
      key_name: ~x"./keyName/text()"
    )
    |> Enum.map(&config_template(&1))
    |> Enum.join()

    File.write!("config", content)
  end

  defp config_template(instance) do
    %{key_name: key_name} = instance
    host_ip = host_ip(instance)

    """
    Host #{host_ip}
      HostName #{host_ip}
      IdentitiesOnly yes
      IdentityFile #{@key_dir}#{key_name || @key_name}.pem
      User ubuntu

    """
  end

  defp host_ip(%{public_ip: nil} = instance), do: instance.private_ip

  defp host_ip(%{public_ip: public_ip} = _instance), do: public_ip
end

Generator.run()
