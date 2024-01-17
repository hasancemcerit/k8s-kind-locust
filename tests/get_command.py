from locust import HttpUser, task

class QuickTest(HttpUser):
    @task
    def cs_hello(self):
        self.client.get("/cs/world")

    @task(3)
    def cs_random(self):
        self.client.get("/cs/random")

    @task(2)
    def cs_ping(self):
        self.client.get("/cs/ping")

    @task
    def py_hello(self):
        self.client.get("/py/world")

    @task(3)
    def py_random(self):
        self.client.get("/py/random")

    @task(2)
    def py_ping(self):
        self.client.get("/py/ping")

    def on_stop(self):
        self.environment.runner.quit()