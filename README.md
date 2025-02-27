
# Setup EFK Stack with TLS Communication

## **Configuring TLS Certificates**

### **Elasticsearch + Kibana TLS Communication**

-   In the root directory, run the following command to generate certificates for Elasticsearch, Kibana, etc.:
       
    `cd setup ; docker compose -f docker-compose.yml run --rm certs` 
    
-   Once the command completes, you will find the generated certificates in the `setup/secrets` directory:
    
    ![Certificates location](https://res.cloudinary.com/dgiozc0lj/image/upload/v1740642949/ydfsmyrhqn4dh0ibhaiv.jpg)
    
-   Move the certificates to the appropriate locations as follows:
    
    -   `setup/secrets/elasticsearch.keystore` → `efk/elasticsearch/secret`
    -   `setup/secrets/elasticsearch/*` → `efk/elasticsearch/secret`
    -   `setup/secrets/kibana/*` → `efk/kibana/secret`
    -   `setup/secrets/certificate_authority/ca/ca.crt` → `efk/elasticsearch/secret`
    -   `setup/secrets/certificate_authority/ca/ca.crt` → `efk/kibana/secret`
    -   `setup/secrets/certificate_authority/ca/ca.crt` → `efk/fluentd/secret`
    
    **Note:** Change the default password for Elasticsearch by updating the `ELASTIC_PASSWORD` variable in `setup/.env`.
    
-   After generating and moving the certificates, navigate to each directory (`elasticsearch`, `kibana`, `fluentd`) and build the corresponding images.  
    Example for Kibana:
        
    `cd efk/kibana ; docker build -t <tag> .` 
    
-   Once the images are built, update the `efk/docker-swarm.yml` file with the correct image references for each service.
    
    ✅ **Elasticsearch + Kibana TLS communication setup is now complete.**
    

----------

### **Fluentbit + Fluentd TLS Communication**

-   Run the following command to generate certificates for Fluentbit and Fluentd:
        
    `cd setup/bin ; bash gen_fluent_certs.sh` 
    
    The output should look like this:    
    ![Fluentbit & Fluentd certificates](https://res.cloudinary.com/dgiozc0lj/image/upload/v1740643917/hpzyo3wvr1o11euy5cgs.jpg)
    
-   Move the generated certificates as follows:
    
    -   `setup/bin/client.*` → `efk/fluentbit/secret/client`
    -   `setup/bin/server.*` → `efk/fluentd/secret/server`
    -   `setup/bin/ca-cert.pem` → `efk/fluentbit/secret/client`
    -   `setup/bin/ca-cert.pem` → `efk/fluentd/secret/server`
-   These certificates are referenced in the Fluentbit/Fluentd configuration files inside their respective directories.
    
-   To build images for testing, navigate to `efk/fluent(d | bit)` and run:
        
    `docker build -t <tag> .` 
    

----------

## **Elasticsearch Lifecycle (Auto-delete Indexes After 30 Days)**

-   Inside the `es.lifecycle` folder, there is a file named `autodelete.txt`.
    
-   To apply these settings in Elasticsearch:
    
    1.  Open **Kibana**.
    2.  Go to **Kibana Console**.
    3.  Execute the requests in `autodelete.txt` in sequence.
    
    ![Elasticsearch Lifecycle](https://res.cloudinary.com/dgiozc0lj/image/upload/v1740645131/sctkurhzq0d7l8ohybax.jpg)
    

----------

## **Configuring Log Forwarding with Sidecar on Kubernetes**

-   Since real-world applications generate logs with **many records and fields**, using **JSON parser in Fluentbit** is **not optimal**. Instead, a **Lua script** can be used for greater flexibility in processing complex logs.
    
-   Example of log transformation:
    
    -   Rename and extract required fields such as:
        -   `@t` → **Timestamp**
        -   `@mt` → **MessageTemplate**
        -   `RequestId`
    -   Remove unnecessary fields: `@t`, `@mt`, `RequestId`.
    
    ![Log transformation](https://res.cloudinary.com/dgiozc0lj/image/upload/v1740645883/n5yoo8uc6n1hlntcmpmw.jpg)
    
-   **Lua script configuration explanation:**
    
    -   `json_decode`: Parses a string into a JSON object.
    -   `remove_keys`: Finds and replaces specified fields with `''` (empty).
    -   `transform_log`: The main function called at the **filter stage** in Fluentbit, which applies transformations using the helper functions.
    
    ![Lua script](https://res.cloudinary.com/dgiozc0lj/image/upload/v1740645883/orquqtjj88vk7osoowwf.jpg)