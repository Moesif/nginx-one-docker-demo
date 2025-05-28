## NGINX One with Moesif

An example Docker application using [Moesif's Lua-based NGINX plugin](https://github.com/Moesif/lua-resty-moesif) to log 
NGINX One API calls to [Moesif API analytics](https://www.moesif.com). 

To learn more about configuration options of the plugin, see 
[Moesif plugin documentation](https://github.com/Moesif/lua-resty-moesif).

## Prerequisites
Before running this example, make sure you complete these steps:

1. Install Docker and Docker Compose.
1. Obtain the SSL certificate, private key, and JWT license files associated with 
your NGINX One subscription. 
2. Log in to the NGINX Container registry using the JWT:

    ```
    docker login private-registry.nginx.com --username=YOUR_NGINX_JWT --password=none
    ```

## How to Run This Example
1. Clone this repository and edit the `nginx.conf.d/main.conf` file to set your Moesif Application ID.

    After you log into [Moesif Portal](https://www.moesif.com/wrap), you can get 
    your Moesif Application ID during the onboarding steps. You can always access 
    the Application ID any time by following these steps from Moesif Portal after logging in:
    
    a. Select the account icon to bring up the settings menu.

    b. Select **Installation** or **API Keys**.

    c. Copy your Moesif Application ID from the **Collector Application ID** field.

2. In the root directory of this repository, place the SSL certificate, private key, 
and JWT license files associated with your NGINX subscription like this:
    ```
    ├── nginx-repo.crt
    ├── nginx-repo.key
    ├── license.jwt
    ```
3. Create a `.env` file and specify your license JWT and NGINX One data plane key:

    ```
    NGINX_LICENSE_JWT="YOUR_NGINX_JWT"
    NGINX_AGENT_SERVER_TOKEN="YOUR_DATA_PLANE_KEY"
    ```
4. Specify the preceding environment variables in the Compose file:

    ```
    version: "2"
    services:
      nginx:
        image: nginx-one-moesif-docker-demo
        build: .
        ports:
          - "8000:80"
        restart: always
        environment:
          - NGINX_LICENSE_JWT=${YOUR_NGINX_JWT}
          - NGINX_AGENT_SERVER_TOKEN=${YOUR_DATA_PLANE_KEY}
          - NGINX_AGENT_SERVER_GRPCPORT=443
          - NGINX_AGENT_SERVER_HOST=agent.connect.nginx.com
          - NGINX_AGENT_TLS_ENABLE=true
    ```
5. Build the Docker image:
    ```bash
    docker build --no-cache -t nginx-one-moesif-docker-demo ./
    ```

6. Start the Docker container:
    ```bash
    docker-compose up -d
    ```

By default, the container starts listening on port 8000. You should now be able to 
make a simple `GET` request to the `/hello` endpoint: 

```bash
curl -X GET http://localhost:8000/hello
```

The server should send a valid response back and the data should be captured in 
the corresponding Moesif account:

```json
{
  "message": "Hello World",
  "completed": true
}

```

## JWT Verification
This demo application contains an example JWT verification script in 
`nginx.conf.d/jwt_verification.lua` that allows you to authorize requests to the 
`/api` endpoint. To see how it works, follow these steps:

1. Specify your JWT secret in the `nginx.conf.d/main.conf` file.
2. Include your JWT token in the `Authorization` header of your HTTP request:

    ```bash
    curl -X POST -H "Content-Type: application/json" -H "Authorization: YOUR_JWT_TOKEN" -d '{"name":"moesif"}' "http://localhost:8000/api?x=2&y=4" -H 'User-Id:123' -H "Company-Id:567"
    ```

The server sends a valid response back:

```json
{
  "message": "Hello World",
  "completed": true
}
```

Without a valid JWT token, the server sends a `401 Unauthorized` error response. 

## Troubleshoot
If you face any issues running this example, see the [Server Troubleshooting Guide](https://www.moesif.com/docs/troubleshooting/server-troubleshooting-guide/) 
that can help you solve common problems.

Other troubleshooting supports:

- [FAQ](https://www.moesif.com/docs/faq/)
- [Moesif support email](mailto:support@moesif.com)
