# content-hub-farm
Builds a Content Hub Docker Farm of multiple Drupal publishers and subscribers for development purposes using the same codebase.
It allows you to debug on any of the sites without having to switch your IDE code scope. See your code changes automatically on every site in the farm by modifying code in a single location. 

If you need more sites, just add some small changes to 2 YAML files and re-run the farm. That's pretty much all you need to do.
You can make your sites persist next time you restart the farm. 

The purpose of this project is to be able to develop Content Hub without having to spend time on building sites or doing any site configuration.

## Building steps

- Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop).

- Clone this repository.

        $git clone git@github.com:abarriosr/content-hub-farm.git
        $cd content-hub-farm 
         
- Copy and edit your docker-compose.yml file:
 
        $cp docker-compose.yml.dist docker-compose.yml

- Build the containers

        $./built.sh <ACH-BRANCH>
        
  If no argument is provided, it will build using this default branch for Content Hub module: **8.x-2.x**. 
  Use this command every time you need to rebuild your sites' codebase.

- Download and install [Ngrok](https://ngrok.com). You will need a paid version if you want to use multiple domains.
  Go to your [dashboard page](https://dashboard.ngrok.com/auth) and obtain your **ngrok token**. You will need that for the following step.
        
- Run **ngrok** for multiple domains

        $cp ngrok.yml ~/.ngrok2/ngrok.yml
        $ngrok ngrok authtoken <NGROK TOKEN>
        $ngrok start --all
       
- Run the Content Hub Farm

        $docker-compose up
        
  Use this command every time you need to run the farm without any changes to the site codebase.
    
## Adding more publishers/subscribers:

To add more sites just add entries to the **docker-compose.yml** and **ngrok.yml** files. 
Those entries have to paired together. Then run the Content Hub Farm as explained above.

- Add entries into the docker-compose.yml file. For example, a second subscriber could be done by adding the following lines:

    ```  
      subscriber3:
        # The hostname has to match the declaration in **ngrok.yml** 
        hostname: subscriber3.ngrok.io
        build:
          context: .
        environment:
          # There are two sites roles: 'publisher' or 'subscriber'.
          - SITE_ROLE=subscriber
          # If persistent, the site will persist through `docker compose up`
          # Otherwise, the site will be re-installed.
          - PERSISTENT=true
        volumes:
          - html:/var/www/html
        ports:
          # The port has to match the declaration in **ngrok.yml**
          - 8083:80
        networks:
          ch_farm:
            ipv4_address: 192.168.1.12
    ```
- Add more entries into the ngrok.yml file, for example for the second subscriber above, you could do:

    ```     
       subscriber3:
          proto: "http"
          addr: "8083"
          hostname: subscriber3.ngrok.io
          host_header: subscriber3.ngrok.io
    ```