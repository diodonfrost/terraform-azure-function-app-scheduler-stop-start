# [1.0.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.15.0...v1.0.0) (2025-04-14)


### Features

* **terraform:** expose app function key in outputs ([d90b073](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/d90b073fc8c8b5fb9618b934f42a06aa9245ebda))
* **terraform:** refactor application insights configuration ([c9763ad](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/c9763add719ed7927894991aeaac7ab6df734c0d))


# [0.15.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.14.0...v0.15.0) (2025-04-08)


### Bug Fixes

* **deps:** constrain azurerm provider to versions ([246755a](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/246755af9915b16f491e1aa64eaa4ba71d5364d6))
* **scheduler:** handle resources without tags in resource filtering ([4bb3832](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/4bb38327050dd58f763434d16c63f2b242d1b993))


### Features

* **examples:** add diagnostic settings configuration examples ([fee4263](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/fee42638c4b0520b1230d5bf3846a307d350a12a))
* make application insights optional for function App ([22a48b4](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/22a48b454e5b1139367ee0e0d5733ed8a8ef4a9a))
* **monitoring:** add diagnostic settings for function app ([9ff64a3](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/9ff64a3be0011c271aca223fde2bc1ae6ba29f33))
* **outputs:** add resource_group_name output variable ([df42007](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/df4200784afe2c7cf9fbc8396f2a513c4ad25473))
* **scale_set:** suspend or resume automatic repairs ([6ab1304](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/6ab1304fd86e201afcbf6acbeb345f038bd40f51))
* **scheduler:** add container groups scheduler ([3e753dc](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/3e753dc148335f225c438ff4777551b18415e06e))
* **terraform:** make service plan sku configurable ([e832b75](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/e832b75c94d09b2f9734417ecbfbb04dcb43e14f))
* **terraform:** upgrade function app python runtime from 3.9 to 3.11 ([a508955](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/a508955c63aba9e344e344740d35f0c66f081283))


### Code Refactoring

* **vm_handler:** improve scheduler code organization ([72679ef](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/72679ef1fa317d357fbfb08f07f3afc900d710f9))
* **scale_set_handler:** improve scheduler code organization ([36cda38](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/36cda38994bb9988f067884bf28cdb2815e4a4f1))
* **postgresql_handler:** improve scheduler code organization ([4623a1d](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/4623a1dc26f94886e742e18d74ba6277edcfd3c1))
* **mysql_handler:** improve scheduler code organization ([8eb6eda](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/8eb6eda4d227d6c1bcd014974ffa6935df69481b))
* **container_handler:** improve scheduler code organization ([a5f8de7](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/a5f8de717aa5bb07d11689336687bc7736269b16))
* **aks_handler:** improve scheduler code organization ([6e9fb38](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/6e9fb38cf82701507d81669aaf4030aed02453d3))



# [](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.13.0...v) (2025-04-08)


# [0.14.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.13.0...v0.14.0) (2025-04-08)


### Features

* **scale_set:** suspend or resume automatic repairs ([commit](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/6ab1304fd86e201afcbf6acbeb345f038bd40f51))
* **scheduler:** add container groups scheduler ([commit](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/3e753dc148335f225c438ff4777551b18415e06e))



# [0.13.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.11.0...v0.12.0) (2023-09-24)


### Features

* **function:** add python error handling ([6267d99](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/6267d993a71bd64c873665bb0fc3d8ac999b0e0f))



# [0.12.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.11.0...v0.12.0) (2023-09-16)


### Features

* **scheduler:** add aks cluster scheduler ([2c945a7](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/2c945a7e386d05f1617086c3329dd3bc4f249a89))



# [0.11.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.10.0...v0.11.0) (2023-09-14)


### Features

* **scheduler:** add mysql scheduler ([c520942](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/c5209425606765223d41bd9a25a45af030c684b9))
* **scheduler:** add virtual machine scale set scheduler ([f8fc463](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/f8fc463532076956e0a58416c587c7ecfa6dffcf))
* **terraform:** change function app replacement ([3cb8a13](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/3cb8a13876dd1320c881c88b07913a506544d2d4))



# [0.10.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/v0.9.0...v0.10.0) (2023-09-11)


### Features

* **scheduler:** add postgresql scheduler ([894b4c3](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/894b4c358eef2c8c6d756f4d99f1e243fab650b6))



# [0.9.0](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/compare/4694003b0cd094d731dafa7f50cf2ff10a9e1e4b...v0.9.0) (2023-09-10)


### Features

* **function:** add virtual machines scheduler ([6df527f](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/6df527f3ef2c27264fb388d4207d4379c342d468))
* init terraform module ([4694003](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/4694003b0cd094d731dafa7f50cf2ff10a9e1e4b))
* **terraform:** add azure function ([1623d92](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/1623d92abb8a4a943d1c9b814d08bb3e664eb5dd))
* **terraform:** support multiple azure tags scheduler ([0da7241](https://github.com/diodonfrost/terraform-azure-function-app-scheduler-stop-start/commit/0da7241aa8702a6dd541356269ed1cf45a4d942d))



