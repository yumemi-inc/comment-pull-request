function raise_error() {
  echo "::error::$1"
  return 1
}

function raise_permission_error() {
  raise_error "May not have 'pull-requests: write' permission."
}
