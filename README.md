jumpcloud Cookbook
==================
This cookbook installs the [JumpCloud](https://www.jumpcloud.com/) agent. Once the agent has been successfully installed, it will begin heartbeating to the JumpCloud and will be immediately visible in your systems portfolio.

Requirements
------------

## Platform:

* Ubuntu - 10.04, 12.04, 12.10, and 13.04 (13.10 coming soon)
* RHEL/CentOS - 5 and later
* Amazon® Linux - 2013.03 and later

May work on other platforms with or without modification.

Attributes
----------
See `attributes/default.rb` for default values.

* `node['jumpcloud']['databag_name']` - Sets the name of the data bag that the credentials are stored in
* `node['jumpcloud']['databagitem_name']` - Sets the name of the data bag item that the credentials are stored in

Usage
-----

#### jumpcloud::default

##### Store your JumpCloud credentials securely
First, I created the secret key file that is used to encrypt the contents of the data bag item. This file will not be stored in source control, as it is highly sensitive, and only gets copied to the systems that need it.

```bash
# Create the secret key file
openssl rand -base64 512 > .chef/encrypted_data_bag_secret

# Tell git to ignore this file
echo -e "###\n# Ignore Chef key files and secrets\n###\n.chef/encrypted_data_bag_secret" >> .gitignore
```

Next, I created the actual data bag.

```bash
knife data bag create encrypted_data_bags
```

Next I created the data bag item using the secret key. This is created directly on the Chef Server, rather than a plain text file.
```bash
knife data bag create encrypted_data_bags jumpcloud --secret-file .chef/encrypted_data_bag_secret
```

```json
{
  "id": "jumpcloud",
  "key": "encrypted string here"
}

```

I’m not saving the plain text data bag item, but will store the encrypted item, so I’ll retrieve it from the Chef Server and redirect the output to a JSON file.
```bash
mkdir data_bags/encrypted_data_bags
knife data bag show encrypted_data_bags jumpcloud -Fj > data_bags/encrypted_data_bags/jumpcloud.json
```

##### Add JumpCloud to a role
For example in a base.rb role applied to all nodes:

```rb
name 'base'
description 'Role applied to all systems'
run_list "recipe[jumpcloud]""
```

Or, if you chose to use a different name for the data bag or the data bag item:

```rb
name 'base'
description 'Role applied to all systems'
run_list "recipe[jumpcloud]""
default_attributes(
  'jumpcloud' => {
    'databag_name' => 'secret',
    'databagitem_name' => 'jumpcloud'
  }
)
```

##### Running chef-client
You will need to upload the secret file you used to create the data bag item to the server so that the server can decrypt it.  By default, chef looks in '/etc/chef/encrypted_data_bag_secret'.

If you are bootstrapping a new server, then you can have knife automatically upload the file by using the `secret-file` option:

```bash
knife bootstrap localhost --ssh-user vagrant --ssh-password vagrant --ssh-port 2222 --run-list 'role[base]' --sudo --secret-file='.chef/encrypted_data_bag_secret'
```

#### jumpcloud::uninstall

##### Add JumpCloud Uninstall Recipe to a role
For example in a base.rb role applied to all nodes:

```rb
name 'base'
description 'Role applied to all systems'
run_list "recipe[jumpcloud::uninstall]""
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author:: Nick Henry (<nickh@standingcloud.com>)

Copyright:: 2013, Standing Cloud

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License.
