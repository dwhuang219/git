from prefect import flow, get_run_logger, task
from prefect.client.schemas.schedules import CronSchedule
import time

schedule = CronSchedule(cron="10 15 * * *", timezone="Asia/Shanghai")


@task
def get_name():
    print("running getname")
    return "hdw"


@task
def task_1():
    time.sleep(2)
    print("task1 finished")


@task
def task_2(input=0):
    time.sleep(1)
    print("task2 finished")


@task
def task_3(input=0):
    print("task3 finished")


@flow(log_prints=True)
def test_dag():
    first_result = task_1.submit()
    second_result = task_2.submit(first_result)
    third_result = task_3.submit()
    fourth_result = task_2.submit((second_result, third_result))


if __name__ == "__main__":
    test_dag.from_source(
        source="https://github.com/dwhuang219/git.git", 
        entrypoint="test2.py:test_dag"
    ).deploy(
        cron=schedule,
        # timezone="Aisa/Tokyo",
        name="my-second-deployment", 
        work_pool_name="my-managed-pool"
    )

