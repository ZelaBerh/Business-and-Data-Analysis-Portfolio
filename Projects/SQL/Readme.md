# 📉 Layoffs Data Analysis

Welcome to my **Layoffs Data Analysis** project! This project showcases how I transformed raw layoffs data caused by the COVID-19 pandemic into meaningful information and analysis using **SQL**. 🚀  

## 📂 Project Overview
I worked with **layoff data from Kaggle** to explore trends, patterns, and anomalies. Here's what I did:  

### **Data Cleaning**
* Ensured data quality by:  
  * Removing duplicates using `ROW_NUMBER()` and `PARTITION BY`.  
  * Standardizing columns such as **industry**, **country**, and **dates** for consistency.  
  * Handling missing values, like filling null industries by cross-referencing other rows.  
  * Dropping irrelevant or incomplete records.  

### **Exploratory Data Analysis (EDA)**
* Conducted analyses to uncover key insights:  
  * **Identified Trends**: Largest layoffs by year, country, and industry.  
  * **Analyzed Percentages**: Highlighted companies with 100% workforce reductions.  
  * **Ranked Companies**: Top companies by total layoffs, both annually and overall.  
  * **Monthly Insights**: Created rolling totals to analyze layoffs trends over time.  

---

## 🖥️ Key Features  

### **Data Cleaning Highlights**
* Streamlined the dataset by fixing inconsistencies in a few categories, like **Crypto** and **United States.**  
* Converted date strings into SQL `DATE` format for analysis.  
* Simplified missing data handling by filling, standardizing, or dropping where needed.  

### **EDA Highlights**
* Found that **startups** accounted for the highest percentage-based layoffs, often due to complete shutdowns.  
* Revealed that industries like **Consumer** and **Retail** faced the most layoffs throughout the years.  
* Noted patterns of layoffs increasing during specific timeframes or due to specific market trends.  

---

## 📸 Snapshots  

Here are some highlights from the analysis:  

### **1. Total Layovers by Company**

![Screenshot 2024-11-27 233129](https://github.com/user-attachments/assets/de7b1547-ab0c-4881-9380-9231a6d42ac0)

### **2. Rolling Total of Layovers in each month from 2020 to 2023**

![Screenshot 2024-11-27 233806](https://github.com/user-attachments/assets/c6c49f8a-2ec7-42d9-88fc-4a0daa8e3acb)

### **3. Ranking the Companies with the Biggest Layovers for Each Year**

![Screenshot 2024-11-27 233941](https://github.com/user-attachments/assets/bb92d03e-3165-4ad1-9dd5-3f2b7abcb007)


# 🤔 What You'll Learn
By exploring this project, you'll see how SQL can be used for:

* Advanced data cleaning techniques for real-world datasets.
* Using window functions and aggregations to extract meaningful information.
* Transforming raw data into organized, actionable insights.
  
# 🚀 Dive In!
Explore the SQL scripts and insights to see how data analysis helps uncover meaningful trends. Let me know your thoughts and feedback!
