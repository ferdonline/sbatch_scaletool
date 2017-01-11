NAME="myproj"
PARTITION="test"
COMMAND="python -c \"print 'Hello world'\""
MAX_TASKS=4096

#Optional params
MIN_TASKS=128  #Default 1
ENV_SETUP="
  module purge
  mkdir some_required_dir
"
START=false   #Default true

