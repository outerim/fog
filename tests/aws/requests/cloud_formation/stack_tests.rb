Shindo.tests('AWS::CloudFormation | stack requests', ['aws', 'cloudformation']) do

  @validate_template_format = {
    'Description' => String,
    'Parameters'  => [
      {
        'DefaultValue'  => Fog::Nullable::String,
        'Description'   => String,
        'NoEcho'        => Fog::Boolean,
        'ParameterKey'  => String,
      }
    ],
    'RequestId'   => String
  }

  @create_stack_format = {
    'RequestId' => String,
    'StackId'   => String
  }

  @get_template_format = {
    'RequestId'     => String,
    'TemplateBody'  => String
  }

  @describe_stacks_format = {
    'RequestId' => String,
    'Stacks'    => [
      {
        'CreationTime'    => Time,
        'DisableRollback' => Fog::Boolean,
        'Outputs'         => [
          {
            'OutputKey'   => String,
            'OutputValue' => String
          }
        ],
        'Parameters'      => [
          {
            'ParameterKey'    => String,
            'ParameterValue'  => String,
          }
        ],
        'StackId'         => String,
        'StackName'       => String,
        'StackStatus'     => String,
      }
    ]
  }

  @describe_stack_events_format = {
    'RequestId'   => String,
    'StackEvents' => [
      {
        'EventId'               => String,
        'LogicalResourceId'     => String,
        'PhysicalResourceId'    => String,
        'ResourceProperties'    => String,
        'ResourceStatus'        => String,
        'ResourceStatusReason'  => String,
        'ResourceType'          => String,
        'StackId'               => String,
        'StackName'             => String,
        'Timestamp'             => Time
      }
    ]
  }

  @describe_stack_resources_format = {
    'RequestId'       => String,
    'StackResources'  => [
      {
        'LogicalResourceId'     => String,
        'PhysicalResourceId'    => String,
        'ResourceStatus'        => String,
        'ResourceType'          => String,
        'StackId'               => String,
        'StackName'             => String,
        'Timestamp'             => Time
      }
    ]
  }

  tests('success') do

    @stack_name = 'fogstack' << Time.now.to_i.to_s
    @keypair = AWS[:compute].key_pairs.create(:name => 'cloudformation')
    @template_url = 'https://s3.amazonaws.com/cloudformation-templates-us-east-1/EC2InstanceSample-1.0.0.template'

    tests("validate_template('TemplateURL' => '#{@template_url}')").formats(@validate_template_format) do
      AWS[:cloud_formation].validate_template('TemplateURL' => @template_url).body
    end

    tests("create_stack('#{@stack_name}', 'TemplateURL' => '#{@template_url}', Parameters => {'KeyName' => 'cloudformation'})").formats(@create_stack_format) do
      AWS[:cloud_formation].create_stack(
        @stack_name,
        'TemplateURL' => @template_url,
        'Parameters'  => {'KeyName' => 'cloudformation'}
      ).body
    end

    tests("get_template('#{@stack_name})").formats(@get_template_format) do
      AWS[:cloud_formation].get_template(@stack_name).body
    end

    tests("describe_stacks").formats(@describe_stacks_format) do
      AWS[:cloud_formation].describe_stacks.body
    end

    tests("describe_stack_events('#{@stack_name}')").formats(@describe_stack_events_format) do
      AWS[:cloud_formation].describe_stack_events(@stack_name).body
    end

    tests("describe_stack_resources('StackName' => '#{@stack_name}')").formats(@describe_stack_resources_format) do
      AWS[:cloud_formation].describe_stack_resources('StackName' => @stack_name).body
    end

    tests("delete_stack('#{@stack_name}')").succeeds do
      AWS[:cloud_formation].delete_stack(@stack_name)
    end

    @keypair.destroy

  end

  tests('failure') do

  end

end
