# Docker image for playing with OpenAI Gym, PLE, and Roboschool on Jupyter with Keras
 
## About

A Docker image running OpenAI Gym, PLE, and Roboschool with Keras-rl on jupyter notebook/lab.
This image was developed based on [jaimeps/docker-rl-gym](https://github.com/jaimeps/docker-rl-gym).

**Attention:** CUDA driver is not currently installed.

## Installed Libraries

**1. Basics:** 
- [NumPy](http://www.numpy.org/)
- [Pandas](http://pandas.pydata.org/)
- [Scipy](https://www.scipy.org/)
- [scikit-image](https://scikit-image.org/)
- [Matplotlib](http://matplotlib.org/)
- [Seaborn](https://seaborn.pydata.org/)
- [Jupyter notebook and lab](http://jupyter.org/)

**2. Deep Learning:** 
- [TensorFlow](https://www.tensorflow.org/)
- [Keras](http://keras.io/)

**3. Reinforcement Learning:**
- [Keras-RL](https://keras-rl.readthedocs.io/en/latest/)
- [baselines](https://github.com/openai/baselines)
- [TensorForce](https://github.com/reinforceio/tensorforce)

**4. Environments:**
- [openAI Gym](https://github.com/openai/gym)
	- with [mdp_gridworld](https://github.com/IRLL/reinforcement_learning_class)
	- without MuJoCo and Robotics (prepared Roboschool instead)
- [Roboschool](https://github.com/openai/roboschool)
- [PyGame Learning Environment](http://pygame-learning-environment.readthedocs.io/)

**5. Others:** 
- [scikit-image](https://scikit-image.org/)
- [ipywidgets](https://ipywidgets.readthedocs.io/en/stable/index.html)
- [h5py](http://www.h5py.org/)

## User and Home

User `jovyan` was prepared in the docker image and `/home/jovyan` is mounted to your working directory where you type `docker run`. In other words, the files on the working directory can be easily accessed from the docker.


## GitHub

You can git clone from [jnishii/docker-gym-keras](https://github.com/jnishii/docker-gym-Keras)

## DockerHub

You can pull the [built image from Docker Hub](https://hub.docker.com/r/jnishii/docker-gym-keras/) by 

```
$ docker pull jnishii/docker-gym-keras
```

## Start Docker

Just type `bin/docker-run.sh`, then Jupyter notebook will run.


## Bash login

Just type `bin/docker-run.sh -X`.
Jupyter will start by typing `jupyter.sh` on the bash terminal.

If you use need X forwarding on Mac OS, install XQuartz and socat (`brew install socat`), and run the command below on XQuartz before running the docker image:

```
$ socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"
```


## Rendering animations on Jupyter notebook

I think the best way to render animations of openAI gym on Jupyter notebook is to use virtual frame buffer as introduced by [jaimeps/docker-rl-gym](https://github.com/jaimeps/docker-rl-gym). Here is an example:

```
import gym
from IPython import display
import matplotlib.pyplot as plt
%matplotlib inline

env = gym.make('Breakout-v0')
env.reset()
for _ in range(50):
    plt.imshow(env.render(mode='rgb_array'))
    display.clear_output(wait=True)
    display.display(plt.gcf())
    action=env.action_space.sample()
    env.step(action)
```

