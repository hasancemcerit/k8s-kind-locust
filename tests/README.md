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

`locust.conf` file has some [sensible defaults](https://docs.locust.io/en/stable/configuration.html) to run the load test. You can customize this file, or add command line arguments to overwrite them.

🔥 Be careful not to burn your CPUs. 😉

```
locust -f get_command.py
```

<a href="https://asciinema.org/a/atsqrwnpKEcxmnSL9oh70J9J3?autoplay=1" rel="nofollow"><img src="https://asciinema.org/a/atsqrwnpKEcxmnSL9oh70J9J3.svg" alt="Test Results" data-canonical-src="https://asciinema.org/a/atsqrwnpKEcxmnSL9oh70J9J3.svg" style="max-width: 50%;"></a>