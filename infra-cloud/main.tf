terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "yandex_cloud_token" {
  type = string
  description = "Данная переменная потребует ввести секретный токен в консоли при запуске terraform plan/apply"
}

provider "yandex" {
  token     = var.yandex_cloud_token #секретные данные должны быть в сохранности!! Никогда не выкладывайте токен в публичный доступ.
  cloud_id  = "b1g1o5qivg8qirtj8723"
  folder_id = "b1ghpsbumf7efm6d0s33"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "netology" {
  name = "netology"
}

resource "yandex_vpc_subnet" "netology-subnet" {
  name           = "netology-subnet"
  zone           = "ru-central1-a"
  network_id     = "e9b76rj5ee5a3r67t3fi"
  v4_cidr_blocks = ["10.10.0.0/16"]
}


resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o6khjbdv3f1suqf69"
    }
  }

  network_interface {
    subnet_id = "e9b76rj5ee5a3r67t3fi"
    nat       = true
   # nat_ip_address = yandex_vpc_address.netology.external_ipv4_address[0].address
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
   user-data = "${file("./meta.txt")}"
  }

}
