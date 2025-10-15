# Get Started with Ray Debugger

This extension adds VSCode support for debugging Ray applications with the Ray Debugger.

The Ray Distributed Debugger is designed to streamline the debugging process for Ray open-source users, offering an interactive debugging experience with Visual Studio Code and `Ray >= 2.9.1`. The Ray Debugger enables you to:

* **Break into Remote Tasks**: Set breakpoints anywhere in your Ray cluster. When your code hits the breakpoints, it will pause execution and allow you to connect with VSCode for debugging.

* **Post-Mortem Debugging**: When Ray tasks fail with unhandled exceptions, Ray automatically freezes the failing task and waits for the Ray Debugger to attach, allowing you to investigate and inspect the state of the program at the time of the error.

Say goodbye to the complexities of debugging distributed systems. The Ray Distributed Debugger empowers you to debug Ray applications more efficiently, saving you time and effort in your development workflow.

## How to use
### Prerequisites
- Visual Studio Code
- `ray[default] >= 2.9.1`.
- `debugpy >= 1.8.0`.

### Get Started
- **Setup Environment:** Create a new virtual environment and install dependencies.
    ```bash
    conda create -n myenv python=3.9
    conda activate myenv
    pip install "ray[default]" debugpy
    ```
- **Start a Ray Cluster:** Run `ray start --head` to start a Ray Cluster.
    ```bash
    ray start --head
    ```
- **Register Clusters:** Add the Ray cluster `IP:PORT` to the Cluster list. The default `IP:PORT` is `127.0.0.1:8265`, and you may change it when starting a new cluster. Make sure the IP and port are accessible from your current machine.
    
    ![add cluster image](https://i.imgur.com/ZVn1AHk.gif)
- **Create a Ray Task:** Create a file `job.py` with the following snippet. Add the `RAY_DEBUG` environment variable to enable Ray Debugger and add `breakpoint()` in the ray task.
    ```python
    import ray
    import sys
    
    # Add RAY_DEBUG environment variable to enable Ray Debugger
    ray.init(runtime_env={
        "env_vars": {"RAY_DEBUG": "1"}, 
    })

    @ray.remote
    def my_task(x):
        y = x * x
        breakpoint() # Add a breakpoint in the ray task
        return y

    @ray.remote
    def post_mortem(x):
        x += 1
        raise Exception("An exception is raised")
        return x

    if len(sys.argv) == 1:
        ray.get(my_task.remote(10))
    else:
        ray.get(post_mortem.remote(10))
    ```

- **Setup Debugger Local Folder:** Ray Debugger needs to know the absolute path to the folder you are going to run `job.py`. Use `pwd` command to get the submission path, and set the cluster's local folder to the path. For each cluster, you can set the local folder by clicking on the ⚙️ icon on the cluster item.

    ![Edit the local folder for a cluster](https://i.imgur.com/KzsnMxM.gif)


- **Run Your Ray Application:** Start running your Ray application.
    ```bash
    python job.py
    ```
- **Attach to Paused Tasks:** 
    - The task will enter a paused state once the breakpoint is hit.
    - The terminal will clearly indicate when a task is paused and waiting for debugger to attach.
    - The paused tasks will be listed in the Ray Debugger extension.
    - Click on a paused task to attach the VSCode debugger.

    ![submit a ray task, see the paused tasks, and attach to a paused task](https://i.imgur.com/fpH4XUl.gif)


- **Use the VSCode Debugger:** Debug your Ray application just as you would when developing locally.

### Post-Mortem Debugging
Continuing from the previous section, let's delve into Post-Mortem debugging. This feature becomes essential when Ray tasks encounter unhandled exceptions. In such cases, Ray automatically freezes the failing task, awaiting attachment by the Ray Debugger. This functionality empowers you to thoroughly investigate and inspect the program's state at the time of the error.


- **Run a Ray Task Raised Exception:** Run the same `job.py` created above with an additional argument `raise-exception`.
    ```bash
    python job.py raise-exception
    ```
- **Attach to Paused Tasks:** 
    - The task will be frozen once the exception is thrown.
    - The terminal will clearly indicate when a task is paused and waiting for debugger to attach.
    - The paused tasks will be listed in the Ray Debugger extension.
    - Click on a paused task to attach the VSCode debugger.

    ![demo post-mortem](https://i.imgur.com/GUFKOXu.gif)

- **Use the VSCode Debugger:** Debug your Ray application just as you would when developing locally.
