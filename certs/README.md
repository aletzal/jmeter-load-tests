# Self-signed certificate
How to create self-signed certificate for local development

- create certificate request .cnf
`openssl req -new -newkey rsa:2048 -nodes -keyout localhost.key -out localhost.csr -config openssl.cnf`
---
- generate certificate
`openssl x509 -req -in localhost.csr -signkey localhost.key -out localhost.crt -days 365 -extensions v3_req -extfile openssl.cnf`
---
- import to keychain localhost.crt and set Trust All
---
- `localhost.crt` and `localhost.key` are ready to use (for ex. add it nginx)

### How to list certificate contents

- `openssl x509 -noout -text -in localhost.crt`