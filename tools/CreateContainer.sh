#!/bin/bash
 
# 命令行参数
#   - 必须传递第一个参数, 为容器的名称;
#   - 随后的参数是可选的, 将被额外传递给 `docker run` 命令, 通常应该包括
#     : 挂载路径;
#     : 环境变量 (例如 LANG, TERM 等);
#
# 当指定名称的容器已经存在时
#   - 当容器的状态不是 `running` 时, 同名容器将被清理掉;
#   - 当脚本名称包含为 "Remake" 时, 同名容器将被 (无条件) 清理掉;
#   - 否则, 跳过 `docker run` 命令;
#   - 当脚本名称包含 "Only" 时, 不执行 `docker exec` 命令进入容器;
 
ME="$(basename "${0}")"
 
CONTAINER_NAME="${1:?Container Name}"
shift
 
IMAGE_NAME="hub.bilibili.co/aphrodite/manage-cxx:mm"
 
STATUS="$(docker container inspect -f "{{.State.Status}}" "${CONTAINER_NAME}" 2>"/dev/null")"
 
if [ ! -z "${STATUS}" ]; then
  if [ "${STATUS}" != "running" ] || [[ "${ME}" = *Remake* ]]; then
    echo
    read -t "3" -p "即将销毁容器 '${CONTAINER_NAME}', 在三秒内输入 <CTRL-C> 停止 ..."
    echo
 
    docker stop "${CONTAINER_NAME}"
    docker rm "${CONTAINER_NAME}"
 
    STATUS=""
  fi
fi
 
if [ "${STATUS}" != "running" ]; then
#  echo
#  echo "正在更新镜像 '${IMAGE_NAME}' ..."
#  echo
 
#  docker pull "${IMAGE_NAME}"
 
#  echo
#  echo "正在创建容器 '${CONTAINER_NAME}' ..."
#  echo
 
  docker run -d -i -t -p 0.0.0.0:1011:22 -h "$(hostname -s)::${CONTAINER_NAME}" --name "${CONTAINER_NAME}" \
      --restart "unless-stopped" \
      --tmpfs="/cache:rw,exec,size=8g" \
      -w "/workspace" \
      -v "/mnt/storage01/devimagespace/huangdawei_dev/workspace:/workspace" \
      -v "/mnt/storage01/data:/data/src" \
      -v "/mnt/storage01/devimagespace/huangdawei_dev/docker_root:/root" \
      --cap-add "SYS_ADMIN" \
      --cap-add "SYS_PTRACE" \
      --cap-add "NET_ADMIN" \
      --security-opt "seccomp=unconfined" \
      "${@}" "${IMAGE_NAME}" "/bin/rbash" "--login"
fi 


if [[ "${ME}" != *Only* ]]; then
  echo
  echo "正在进入容器 '${CONTAINER_NAME}' ..."
  echo
 
  docker exec -i -t "${CONTAINER_NAME}" "/bin/bash" "--login"
fi
 
# vim: ft=bash
