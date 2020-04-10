# content-hub-farm
Builds a Content Hub Docker Farm of multiple publishers and subscribers. 

## Building steps

- Copy and edit your docker-compose.yml file:
 
        $cp docker-compose.yml.dist docker-compose.yml

- Build the containers

        $./built.sh <ACH-BRANCH>
        
  If no argument is provided, it will build using the default branch **8.x-2.x** 
        
- Run **ngrok** for multiple domains

        $cp ngrok.yml ~/.ngrok2/ngrok.yml
        $ngrok ngrok authtoken <NGROK TOKEN>
        $ngrok start --all
       
- Run the Content Hub Farm

        $docker-compose up
        
  Once Use this command to run the farm without any changes to the site codebase.
    
## Adding more publishers/subscribers:

- Add more entries into the docker-compose.yml file. For example, a second subscriber could be done by adding the following lines:

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