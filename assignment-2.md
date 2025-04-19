# Hands-on Project: Deploying a Node.js Application with MySQL using systemd

##  Part 1: Application Setup

Create a Node.js project directory and initialize it with npm:
```bash
mkdir demo-node-app
cd demo-node-app
npm init -y
```
Install necessary dependencies (Express and MySQL):
```
npm install express mysql2:
```script
Create a Node.js application that connects to MySQL and Implement the required API endpoints (health and users):
Create a file named *index.js* and paste the following code
```
  GNU nano 7.2                                                                                         index.js                                                                                                  const express = require('express');
const mysql = require('mysql2');
const app = express();
const PORT = 3000;

// MySQL connection setup
const db = mysql.createConnection({
  host: 'localhost',
  user: 'appuser',
  password: 'password',
  database: 'practice_app'
});

db.connect(err => {
  if (err) {
    console.error('MySQL connection failed:', err.stack);
    return;
  }
  console.log('Connected to MySQL');
});

// /health endpoint
app.get('/health', (req, res) => {
  db.ping(err => {
    if (err) return res.status(500).send('Database not connected');
    res.send('Database connected');
  });
});

// /users endpoint
app.get('/users', (req, res) => {
  db.query('SELECT * FROM users', (err, results) => {
    if (err) return res.status(500).send(err.message);
    res.json(results);
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```
##  Part 2: Database Setup
 Install MySQL if not already installed:
```
sudo apt update
sudo apt install mysql-server
```
Secure the MySQL installation:
```
sudo mysql_secure_installation

```
![image](https://github.com/user-attachments/assets/2ab14f3b-d661-4783-bf0a-4605729195d1)

Create the required database, user, and table. Add sample data to the table: 

```
-- Login to MySQL
sudo mysql -u root -p

-- Inside MySQL:
CREATE DATABASE practice_app;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON practice_app.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;

USE practice_app;
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

INSERT INTO users (name, email) VALUES 
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');
```

##  Part 3: systemd Configuration
Create a dedicated system user for running the application:
```
sudo useradd -r -s /bin/false demonodeapp
```
Place your application in an appropriate directory with proper permissions:
```
sudo mkdir -p /opt/demo-node-app
sudo cp -r * /opt/demo-node-app
sudo chown -R demonodeapp:demonodeapp /opt/demo-node-app/
```
Create a systemd service file for your application & Configure appropriate service options (restart policy, dependencies, security):
Create a file in the following location */etc/systemd/system/demo-node-app.service*
```
[Unit]
Description=Practice Node.js App
After=network.target mysql.service

[Service]
Type=simple
User=demonodeapp
WorkingDirectory=/opt/demo-node-app
ExecStart=/usr/bin/node index.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target

```
Enable the service to start at boot time:
```
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable demo_node_app
```
##  Part 4: Testing
Start your service and verify it's running:
start the service:
```
sudo systemctl start demo_node_app
```
verify the status :
```
 sudo systemctl status demo_node_app

```

![image](https://github.com/user-attachments/assets/d987e838-92ca-4d1d-99c5-c255c3ff1f86)

check the log messages in journalctl:
```
journalctl -u node.service -f
```
![image](https://github.com/user-attachments/assets/e3d65f0a-93f2-416c-9e23-acad5dfb2d04)

Test that your application endpoints work correctly:
```
curl http://localhost:3000/health
curl http://localhost:3000/users

```
![image](https://github.com/user-attachments/assets/4294ba28-c827-4c1e-82aa-6d189e0d0aa1)

Test that your service restarts if the application crashes:
```
 sudo pkill -f "node index.js"
 sudo systemctl status demo_node_app
```
![image](https://github.com/user-attachments/assets/057ed737-1473-42ef-9b6e-cc2614eac229)

Reboot your system and verify the service starts automatically:
```
sudo reboot
# After reboot
sudo systemctl status demo_node_app
```
![image](https://github.com/user-attachments/assets/812554b3-7328-4a6a-a062-aaa024cc6bda)


 
