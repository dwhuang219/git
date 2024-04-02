from prefect import flow, get_run_logger, task
import time


@task
def get_name():
    print("running getname")
    return "hdw"


@flow(log_prints=True)
def get_repo_info(repo_name: str = "PrefectHQ/prefect"):
    url = f"https://api.github.com/repos/{repo_name}"
    logger = get_run_logger()
    name = get_name()
    repo = {"1": 1, "2": 2}
    logger.info("%s repository statistics 🤓:", repo_name)
    logger.info(f"Stars 🌠 : %d", repo["1"])
    logger.info(f"Forks 🍴 : %d", repo["2"])
    print("ended")
    time.sleep(30)

if __name__ == "__main__":
    get_repo_info.from_source(
        source="https://github.com/dwhuang219/git/tree/master", 
        entrypoint="test.py:get_repo_info"
    ).deploy(
        name="my-first-deployment", 
        work_pool_name="my-managed-pool", 
    )
