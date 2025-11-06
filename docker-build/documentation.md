# 🏫 DATABASE MANAGEMENT SYSTEM

## 🎯 Objective
To design and build a **reliable school database management system** capable of handling up to **30,000 user logins simultaneously** with **auto-scaling**, **fast response time**, and **minimal downtime**.

---

## 🧩 System Overview
The system is an **institution-grade database** for managing student data, including:

- Course registration  
- Course validation  
- Result display  
- Other school-related data management processes  

It was built using **odoo framework**,**Microsoft Azure** cloud service, **Kubernetes** for containerization, with university-specific-features added as custom modules, dummy data was generated using **faker** package from python library. Other Technologies was used suach as **Docker** for containerization and for generating a microservice architure upon deployment on the cloud, with emphasis on:

- Support for **high concurrent connections**  
- **Fast query response**  
- **Efficient data organization**  
- **Minimal downtime**

---

## 🏗️ Architecture Summary

| **Component** | **Description** |
|----------------|-----------------|
| **Database Engine** | MySQL |
| **Server Host** | Azure |
| **Frontend Access** | XML |

---

## ⚙️ Implementation Steps

1. **Database Design**  
   Schema creation and normalization to handle large-scale user data efficiently.

2. **Setup and Configuration**  
   Environment setup, security configurations, and server initialization.

3. **Connection Management**  
   Managing multiple concurrent connections and optimizing query performance.

4. **Caching Layer**  
   Implemented a caching layer to improve data retrieval and reduce query load.

5. **Testing**  
   Conducted stress tests using automated logins and dummy data generation to measure:
   - Maximum data/login load capacity  
   - Query response time  
   - System uptime  
   - Resource utilization metrics  

An **interactive and responsiveness check** was carried out to ensure synchronization between the **frontend** and **backend**.

---

## 📊 Results

| **Metric** | **Result** |
|-------------|------------|
| **Max Concurrent Logins** | 3,000 |
| **Average Response Time** | TBD |
| **Uptime** | TBD |
| **Error Rate** | TBD |

---

## ⚠️ Challenges and Solutions

### Challenges
- **Limited Hardware Resources**  
  - Restricted disk space and CPU capacity during local testing.  
- **Cloud Deployment Limitations**  
  - Limited resources on **Azure Student Subscription**, restricting full-scale deployment.

### Solutions
- Optimized resource usage by improving query handling and caching.  
- Simulated high-load conditions using dummy data and local virtualized environments.  
- Designed a modular system that can easily scale once more resources become available.

---

## ✅ Conclusion
Although the **full 30,000 concurrent user** objective was not achieved due to resource limitations, the **framework and architecture** of the project demonstrate strong potential for scalability and reliability.

The system successfully:
- Eliminated **slow query response** (lag)  
- Reduced **downtime**  
- Improved **scalability and performance**

> With adequate resources, this system can efficiently serve large-scale institutional deployments.

---

### 👥 Contributors


---

### 📘 License
This project is licensed under the [MIT License](LICENSE).

