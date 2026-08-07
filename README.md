# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀

This repository demonstrates an end-to-end data warehousing and analytics solution, from building a modern SQL Server data warehouse to generating actionable business insights. The project showcases industry-standard Data Engineering concepts including ETL pipelines, data modeling, and SQL-based analytics.

---

## 🏗️ Data Architecture

The project follows the **Medallion Architecture** using three layers:

![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer** – Stores raw data ingested from source CSV files into SQL Server.
2. **Silver Layer** – Cleanses, standardizes, and transforms the data for consistency and quality.
3. **Gold Layer** – Provides business-ready data modeled using a Star Schema for reporting and analytics.

---

## 📖 Project Overview

This project includes:

1. Designing a modern Data Warehouse using the Medallion Architecture.
2. Building ETL pipelines to extract, transform, and load data.
3. Creating Fact and Dimension tables using dimensional modeling.
4. Developing SQL-based analytics for business reporting and insights.

### 🎯 Skills Demonstrated

- SQL Development
- Data Engineering
- ETL Pipeline Development
- Data Warehouse Design
- Data Modeling
- Data Analytics

---

## 🛠️ Tools & Technologies

The following tools were used to complete this project:

- **Datasets** – ERP & CRM CSV files
- **SQL Server Express** – Database Engine
- **SQL Server Management Studio (SSMS)** – Database Management
- **Git & GitHub** – Version Control
- **Draw.io** – Architecture & Data Modeling

---

## 🚀 Project Requirements

### Building the Data Warehouse

#### Objective

Develop a modern SQL Server Data Warehouse that consolidates sales data from multiple source systems for analytical reporting and business decision-making.

#### Specifications

- Import ERP and CRM datasets from CSV files.
- Clean and standardize data before analysis.
- Integrate multiple source systems into a unified analytical model.
- Focus on the latest available dataset.
- Document the data model and ETL process.

---

### 📊 Analytics & Reporting

#### Objective

Generate SQL-based analytics to provide insights into:

- Customer Behavior
- Product Performance
- Sales Trends

These insights help stakeholders make informed business decisions.

---

## 📂 Repository Structure

```text
data-warehouse-project/
│
├── datasets/                           # Raw ERP & CRM datasets
│
├── docs/                               # Documentation
│   ├── etl.drawio
│   ├── data_architecture.drawio
│   ├── data_catalog.md
│   ├── data_flow.drawio
│   ├── data_models.drawio
│   ├── naming-conventions.md
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│
├── tests/
│
├── README.md
├── LICENSE
├── .gitignore
└── requirements.txt
```

---

## 🙏 Acknowledgements

This project was completed as part of my learning journey by following the outstanding **SQL Data Warehouse** tutorial series created by **Barra Khatib Salkini Sir (Data With Baraa)**.

I would like to express my sincere gratitude to **Barra Khatib Salkini Sir** for sharing such high-quality educational content with the Data Engineering community. His professionalism, dedication, and ability to explain complex concepts in a simple and practical way have had a significant impact on my learning journey.

This repository represents **my personal implementation** of the project while following his guidance and explanations. Full credit for the original project concept, educational content, and teaching methodology goes to **Barra Khatib Salkini Sir**.

If you're interested in learning SQL, Data Warehousing, and Data Engineering, I highly recommend following his work:

- 📺 YouTube: https://www.youtube.com/@DataWithBaraa
- 💼 LinkedIn: https://www.linkedin.com/in/baraa-khatib-salkini/
- 🌐 Website: https://www.datawithbaraa.com
- 💻 GitHub: https://github.com/DataWithBaraa

---

## 🛡️ License

This project is licensed under the **MIT License**. Feel free to use, modify, and share this project while providing appropriate attribution.

---

# 🌟 About Me

Hi! I'm **Aalok Kumar Singh**, a BCA (AI & Data Science) student passionate about **Data Engineering, SQL, Data Warehousing, Analytics, and Cloud Technologies**.

I'm currently building real-world projects to strengthen my technical skills and prepare for a career as a **Data Engineer**. I enjoy learning modern Data Engineering practices and implementing them through hands-on projects.

I believe the best way to learn is by building projects that solve real-world problems and continuously improving through practice.

## 🤝 Let's Connect

- 💼 LinkedIn: *www.linkedin.com/in/aalok-kr-singh
- 💻 GitHub: *https://github.com/Aalokkrsingh/*
- 📧 Email: *aalokkrsingh27@gmail.com*

Thank you for visiting my repository. I hope you find it useful, and I'm always open to learning, collaboration, and feedback.
