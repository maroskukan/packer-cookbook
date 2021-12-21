source "null" "debug" {
  communicator = "none"
}

build {
  sources = ["source.null.debug"]

  provisioner "shell-local" {
    inline = ["echo hi"]
  }

  provisioner "breakpoint" {
    disable = false
    note    = "this is a breakpoint"
  }

  provisioner "shell-local" {
    inline = ["echo hi 2"]
  }

}