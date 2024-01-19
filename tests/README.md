- install python
- install pip
- install python-venv

- create and activate virtual environment

```
python -m venv .env/locust-env
source .env/locust-env/bin/activate
```
- install locust

https://docs.locust.io/en/stable/installation.html
```
pip3 install locust
```
- run load test
Customize `locust.conf` file as needed, and run:
```
locust -f get_command.py
```


