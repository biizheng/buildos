#   -mode=...   创建硬盘的类型，有flat、sparse、growing三种。
#   -fd=...     创建软盘
#   -hd=...     创建硬盘。
#   -q  以静默模式创建，创建过程中不会和用户交互。
bximage -hd=60M -imgmode="flat" hd60M.img